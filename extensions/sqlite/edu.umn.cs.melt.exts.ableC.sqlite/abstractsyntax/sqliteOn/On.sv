grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables;
imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports silver:langutil;

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
  local tableErrors :: [Message] =
    case db.typerep of
      abs:sqliteDbType(_, tables) -> checkTablesExist(query.usedTables, tables)
    | errorType() -> []
    | _ -> [err(db.location, "expected _sqlite_db type")]
    end;

  local dbTables :: [SqliteTable] =
    case db.typerep of
      abs:sqliteDbType(_, dbTables) -> dbTables
    | _                           -> []
    end;

  local selectedTables :: [SqliteTable] =
    filterSelectedTables(dbTables, query.selectedTables);

  local selectedTablesWithAliases :: [SqliteTable] =
    addAliasColumns(selectedTables, query.resultColumns);

  local columnErrors :: [Message] =
    case db.typerep of
      abs:sqliteDbType(_, dbTables) ->
        checkColumnsExist(query.usedColumns, selectedTablesWithAliases)
    | errorType() -> []
    | _ -> [err(db.location, "expected _sqlite_db type")]
    end;

  local localErrors :: [Message] =
    tableErrors ++ columnErrors;

--  local resultColumnsPair :: Pair<[SqliteColumn] [Message]> =
--    makeResultColumns(query.resultColumns, dbTables);
--  local resultColumns :: [SqliteColumn] = resultColumnsPair.fst;
--  local columnErrors :: [Message] = resultColumnsPair.snd;
  local resultColumns :: [SqliteColumn] =
    makeResultColumns(query.resultColumns, dbTables);

  {-- want to forward to:
    _sqlite_query ${queryName} = _new_sqlite_query();
    sqlite3_prepare(${db}.db, _query, sizeof(_query), &${queryName}.query, NULL);
    // for each expression parameter:
      sqlite3_bind_int(${queryName}, i, <expr>);
      OR
      sqlite3_bind_text(${queryName}, i, <expr>, -1, NULL);
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
        abs:sqliteQueryTypeExpr(resultColumns),
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
      name("sqlite3_prepare_v2", location=builtIn()),
      foldExpr([
        memberExpr(db, true, name("db", location=builtIn()), location=builtIn()),
        stringLiteral(quote(query.queryStr), location=builtIn()),
        realConstant(
          integerConstant(
            toString(length(query.queryStr)+1),
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
      exprStmt(mkErrorCheck(localErrors, callPrepare)),
      makeBinds(query, queryName)
    ]);

  forwards to fullStmt;
}

abstract production sqliteForeach
top::Stmt ::= row::Name query::Expr body::Stmt
{
  local localErrors :: [Message] =
    case query.typerep of
      abs:sqliteQueryType(_, _) -> []
    | errorType()               -> []
    | _ -> [err(query.location, "expected _sqlite_query type in foreach loop")]
    end;

  local columns :: [SqliteColumn] =
    case query.typerep of
      abs:sqliteQueryType(_, cs) -> cs
    | _ -> []
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
  local columnDecls :: StructItemList = getColumnDecls(columns);

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

function getColumnDecls
StructItemList ::= columns::[SqliteColumn]
{
  return
    if null(columns)
      then nilStructItem()
      else consStructItem(
        getColumnDecl(head(columns)),
        getColumnDecls(tail(columns))
      )
    ;
}

function getColumnDecl
StructItem ::= col::SqliteColumn
{
  local attribute typeExpr :: BaseTypeExpr =
    case col.typ of
      sqliteVarchar() ->
        directTypeExpr(builtinType([constQualifier()], unsignedType(charType())))
    | sqliteInteger() ->
        directTypeExpr(builtinType([], signedType(intType())))
    end;
  local attribute mod :: TypeModifierExpr =
    case col.typ of
      sqliteVarchar() -> pointerTypeExpr([], baseTypeExpr())
    | sqliteInteger() -> baseTypeExpr()
    end;

  return
      structItem(
        [],
        typeExpr,
        foldStructDeclarator([
          structField(col.columnName, mod, [])
        ])
      );
}

function makeBinds
Stmt ::= query::SqliteQuery queryName::Name
{
  {-- want to forward to:
    // for each expression parameter:
      sqlite3_bind_int(${queryName}, i, <expr>);
      OR
      sqlite3_bind_text(${queryName}, i, <expr>, -1, NULL);
  -}
  return
    if   null(query.exprParams)
    then nullStmt()
    else exprStmt(makeBind(head(query.exprParams), queryName, 1));
}

function makeBind
Expr ::= exprParam::Expr queryName::Name i::Integer
{
  return
    directCallExpr(
      name("sqlite3_bind_int", location=builtIn()),
      foldExpr([
        memberExpr(
          declRefExpr(queryName, location=builtIn()),
          true,
          name("query", location=builtIn()),
          location=builtIn()
        ),
        realConstant(
          integerConstant(toString(i), false, noIntSuffix(), location=builtIn()),
          location=builtIn()
        ),
        exprParam
--        realConstant(
--          integerConstant("-1", false, noIntSuffix(), location=builtIn()),
--          location=builtIn()
--        ),
--        realConstant(
--          integerConstant("0", false, noIntSuffix(), location=builtIn()),
--          location=builtIn()
--        )
      ]),
      location=builtIn()
    );
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

