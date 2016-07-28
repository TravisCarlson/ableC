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
    | _ -> [err(db.location, "expected SqliteDb type")]
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
top::Stmt ::= row::Name query::Expr body::Stmt
{
  {-- want to forward to:
    struct _row_t {
      const unsigned char *one;
      int two;
    };
    sqlite3_reset(${query}.query);
    while (sqlite3_step(${query}.query) == SQLITE_ROW) {
      struct _row_t ${row};
      ${row}.one = sqlite3_column_text(${query}.query, 0);
      ${row}.two = sqlite3_column_int(${query}.query, 1);
      ${body};
    }
  -}

  -- SQLITE_ROW
  local sqlite_row :: Expr =
    -- TODO: don't hardcode value
    mkIntConst(100, builtIn());
--    declRefExpr(
--      name("SQLITE_ROW", location=builtIn()),
--      location=builtIn()
--    );

  -- sqlite3_step(${query}.query)
  local callStep :: Expr =
    directCallExpr(
      name("sqlite3_step", location=builtIn()),
      foldExpr([memberExpr(query, true, name("query", location=builtIn()), location=builtIn())]),
      location=builtIn()
    );

  -- sqlite3_step(${query}.query) == SQLITE_ROW
  local hasRow :: Expr =
    binaryOpExpr(
      callStep,
      compareOp(equalsOp(location=builtIn()), location=builtIn()),
      sqlite_row,
      location=builtIn()
    );

  -- while (sqlite3_step(${query}.query) == SQLITE_ROW) { ${body}; }
  local whileHasRow :: Stmt =
    whileStmt(
      hasRow,
      body
    );

  forwards to whileHasRow;
}

abstract production sqliteQuery
top::SqliteQuery ::= pp::String tables::[Name]
{
  top.pp = pp;
  top.tables = tables;
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

function checkTablesExist
[Message] ::= expectedTables::[SqliteTable] foundTables::[Name]
{
  local foundTable :: Name = head(foundTables);
  local localErrors :: [Message] =
    if tableExistsIn(expectedTables, foundTable) then []
    else [err(foundTable.location, "no such table: " ++ foundTable.name)];

  return if null(foundTables) then []
         else localErrors ++ checkTablesExist(expectedTables, tail(foundTables));
}

function tableExistsIn
Boolean ::= tables::[SqliteTable] table::Name
{
  return if null(tables) then false
         else (head(tables).name.name == table.name) || tableExistsIn(tail(tables), table);
}

