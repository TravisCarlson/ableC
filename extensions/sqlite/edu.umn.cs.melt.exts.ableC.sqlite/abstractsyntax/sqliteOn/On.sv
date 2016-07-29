grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables;
imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports silver:langutil;

nonterminal SqliteQuery with pp, tables;
synthesized attribute pp :: String;
synthesized attribute tables :: [Name];

abstract production sqliteExit
top::Expr ::= db::Expr
{
  local localErrors :: [Message] =
    case db.typerep of
      abs:sqliteDbType(_, _) -> []
    | errorType() -> []
    | _ -> [err(db.location, "expected _sqlite_db type")]
    end;

  -- _delete_sqlite_db(${db});
  local callClose :: Expr =
    directCallExpr(
      name("_delete_sqlite_db", location=top.location),
      foldExpr([db]),
      location=top.location
    );

    forwards to mkErrorCheck(localErrors, callClose);
}

abstract production sqliteQueryDb
top::Stmt ::= db::Expr query::SqliteQuery queryName::Name
{
  local localErrors :: [Message] =
    case db.typerep of
      abs:sqliteDbType(_, tables) -> checkTablesExist(tables, query.tables)
    | errorType() -> []
    | _ -> [err(db.location, "expected _sqlite_db type")]
    end;

  {-- want to forward to:
    _sqlite_query ${queryName} = _new_sqlite_query();
    sqlite3_prepare(${db}.db, _query, sizeof(_query), &${queryName}.query, NULL);
  -}

  -- _new_sqlite_query();
  local callNew :: Expr =
    directCallExpr(
      name("_new_sqlite_query", location=builtIn()),
      nilExpr(),
      location=builtIn()
    );

  -- _sqlite_query ${queryName} = _new_sqlite_query();
  local queryDecl :: Stmt =
    declStmt(
      variableDecls(
        [],
        [],
        abs:sqliteQueryTypeExpr(),
        foldDeclarator([
          declarator(
            queryName,
            baseTypeExpr(),
            [],
            justInitializer(exprInitializer(callNew))
          )
        ])
      )
    );

  -- sqlite3_prepare(${db}.db, _query, sizeof(_query), &${queryName}.query, NULL);
  local callPrepare :: Expr =
    directCallExpr(
      name("sqlite3_prepare", location=builtIn()),
      foldExpr([
        memberExpr(db, true, name("db", location=builtIn()), location=builtIn()),
        stringLiteral(quote(query.pp), location=builtIn()),
        realConstant(
          integerConstant(
            toString(length(query.pp)),
            false,
            noIntSuffix(),
            location=builtIn()
          ),
          location=builtIn()
        ),
        unaryOpExpr(
          addressOfOp(location=builtIn()),
          memberExpr(
            declRefExpr(queryName, location=builtIn()),
            true,
            name("query", location=builtIn()),
            location=builtIn()
          ),
          location=builtIn()
        ),
        realConstant(
          integerConstant("0", false, noIntSuffix(), location=builtIn()),
          location=builtIn()
        )
      ]),
      location=builtIn()
    );

  local fullStmt :: Stmt =
    foldStmt([
      queryDecl,
      exprStmt(mkErrorCheck(localErrors, callPrepare))
    ]);

  forwards to fullStmt;
}

abstract production sqliteForeach
top::Stmt ::= row::Name query::Expr body::Stmt columns::[SqliteColumn]
{
  local localErrors :: [Message] =
    case query.typerep of
      abs:sqliteQueryType(_) -> []
    | errorType() -> []
    | _ -> [err(query.location, "expected _sqlite_query type in foreach loop")]
    end;

  {-- want to forward to:
    sqlite3_reset(${query}.query);
    while (sqlite3_step(${query}.query) == SQLITE_ROW) {
      struct {
        <column declarations>;
      } ${row};
      <column initializations>;
      ${body};
    }
  -}

  -- sqlite3_reset(${query}.query)
  local callReset :: Expr =
    directCallExpr(
      name("sqlite3_reset", location=builtIn()),
      foldExpr([memberExpr(query, true, name("query", location=builtIn()), location=builtIn())]),
      location=builtIn()
    );

  -- sqlite3_step(${query}.query)
  local callStep :: Expr =
    directCallExpr(
      name("sqlite3_step", location=builtIn()),
      foldExpr([memberExpr(query, true, name("query", location=builtIn()), location=builtIn())]),
      location=builtIn()
    );

  -- SQLITE_ROW
  local sqliteRow :: Expr =
    -- TODO: don't hardcode value
    mkIntConst(100, builtIn());
--    declRefExpr(
--      name("SQLITE_ROW", location=builtIn()),
--      location=builtIn()
--    );

  -- sqlite3_step(${query}.query) == SQLITE_ROW
  local hasRow :: Expr =
    binaryOpExpr(
      callStep,
      compareOp(equalsOp(location=builtIn()), location=builtIn()),
      sqliteRow,
      location=builtIn()
    );

  -- for example: const unsigned char *name; int age;
  local columnDecls :: StructItemList =
    foldStructItem([
      structItem(
        [],
        directTypeExpr(builtinType([], signedType(intType()))),
        foldStructDeclarator([
          structField(
            name("age", location=builtIn()),
            baseTypeExpr(),
            []
          )
        ])
      ),
      structItem(
        [],
        directTypeExpr(builtinType([constQualifier()], unsignedType(charType()))),
        foldStructDeclarator([
          structField(
            name("gender", location=builtIn()),
            pointerTypeExpr([], baseTypeExpr()),
            []
          )
        ])
      ),
      structItem(
        [],
        directTypeExpr(builtinType([constQualifier()], unsignedType(charType()))),
        foldStructDeclarator([
          structField(
            name("last_name", location=builtIn()),
            pointerTypeExpr([], baseTypeExpr()),
            []
          )
        ])
      )
    ]);

  -- struct { <column declarations> }
  local rowTypeExpr :: BaseTypeExpr =
    structTypeExpr(
      [constQualifier()],
      structDecl(
        [],
        nothingName(),
        columnDecls,
        location=builtIn()
      )
    );

  {- for example:
      { sqlite3_column_text(${query}.query, 0),
        sqlite3_column_int(${query}.query, 1) }
  -}
  local rowInit :: Initializer =
    objectInitializer(
      foldInit([
        init(
          exprInitializer(
            directCallExpr(
              name("sqlite3_column_int", location=builtIn()),
              foldExpr([
                memberExpr(query, true, name("query", location=builtIn()), location=builtIn()),
                realConstant(
                  integerConstant("0", true, noIntSuffix(), location=builtIn()),
                  location=builtIn())
              ]),
              location=builtIn()
            )
          )
        ),
        init(
          exprInitializer(
            directCallExpr(
              name("sqlite3_column_text", location=builtIn()),
              foldExpr([
                memberExpr(query, true, name("query", location=builtIn()), location=builtIn()),
                realConstant(
                  integerConstant("1", true, noIntSuffix(), location=builtIn()),
                  location=builtIn())
              ]),
              location=builtIn()
            )
          )
        ),
        init(
          exprInitializer(
            directCallExpr(
              name("sqlite3_column_text", location=builtIn()),
              foldExpr([
                memberExpr(query, true, name("query", location=builtIn()), location=builtIn()),
                realConstant(
                  integerConstant("2", true, noIntSuffix(), location=builtIn()),
                  location=builtIn())
              ]),
              location=builtIn()
            )
          )
        )
      ])
    );

  -- struct { <column declarations> } ${row} = { <column initializations> } ;
  local rowDecl :: Stmt =
    declStmt(
      variableDecls(
        [],
        [],
        rowTypeExpr,
        foldDeclarator([
          declarator(
            row,
            baseTypeExpr(),
            [],
            justInitializer(rowInit)
          )
        ])
      )
    );

  local whileHasRow :: Stmt =
    whileStmt(
      mkErrorCheck(localErrors, hasRow),
      foldStmt([
        rowDecl,
        body
      ])
    );

  local fullStmt :: Stmt =
    foldStmt([
      exprStmt(callReset),
      whileHasRow
    ]);

  forwards to fullStmt;
}

-- New location for expressions which don't have real locations
abstract production builtIn
top::Location ::=
{
  forwards to loc("Built In", 0, 0, 0, 0, 0, 0);
}

-- TODO: can this be used from ableC:abstractsyntax instead of copied?
function fromId
Name ::= n::cnc:Identifier_t
{
  return name(n.lexeme, location=n.location);
}

function quote
String ::= s::String
{
  return "\"" ++ s ++ "\"";
}

