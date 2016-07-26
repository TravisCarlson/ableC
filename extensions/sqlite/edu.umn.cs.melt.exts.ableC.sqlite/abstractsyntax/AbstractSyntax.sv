grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;

nonterminal SqliteTableList with tables;
synthesized attribute tables :: [SqliteTable];

abstract production sqliteTableList
top::SqliteTableList ::= t::SqliteTable ts::SqliteTableList
{
  top.tables = cons(t, ts.tables);
}

abstract production sqliteNilTableList
top::SqliteTableList ::=
{
  top.tables = nil();
}

nonterminal SqliteTable with name, columnDecls;
synthesized attribute name :: abs:Name;
synthesized attribute columnDecls :: [SqliteColumnDecl];

abstract production sqliteTable
top::SqliteTable ::= n::abs:Name cs::SqliteColumnDeclList
{
  top.name = n;
  top.columnDecls = cs.columnDecls;
}

nonterminal SqliteColumnDeclList with columnDecls;

abstract production sqliteColumnDeclList
top::SqliteColumnDeclList ::= c::SqliteColumnDecl cs::SqliteColumnDeclList
{
  top.columnDecls = cons(c, cs.columnDecls);
}

abstract production sqliteNilColumnDeclList
top::SqliteColumnDeclList ::=
{
  top.columnDecls = nil();
}

nonterminal SqliteColumnDecl with name, typ;
synthesized attribute typ :: SqliteColumnType;

abstract production sqliteColumnDecl
top::SqliteColumnDecl ::= n::abs:Name t::SqliteColumnType
{
  top.name = n;
  top.typ = t;
}

nonterminal SqliteColumnType;

abstract production sqliteVarchar
top::SqliteColumnType ::=
{
}

abstract production sqliteInteger
top::SqliteColumnType ::=
{
}

abstract production sqliteUse
top::abs:Expr ::= dbname::String
{
  {-- want to forward to:
    sqlite3 *_db;
    sqlite3_open(${dbname}, &_db);
  -}

  local db :: abs:Name = abs:name("_db", location=top.location);

  -- sqlite3 *_db;
  local dbDecl :: abs:Stmt =
    abs:declStmt(
      abs:variableDecls(
        [],
        [],
        abs:typedefTypeExpr(
          [],
          abs:name("sqlite3", location=top.location)
        ),
        abs:foldDeclarator([
          abs:declarator(
            db,
            abs:pointerTypeExpr(
              [],
              abs:baseTypeExpr()
            ),
            [],
            abs:nothingInitializer()
          )
        ])
      )
    );

  -- sqlite3_open(${dbname}, &_db);
  local callOpen :: abs:Expr =
    abs:directCallExpr(
      abs:name("sqlite3_open", location=top.location),
      abs:foldExpr([
        abs:stringLiteral(dbname, location=top.location),
        abs:unaryOpExpr(
          abs:addressOfOp(location=top.location),
          abs:declRefExpr(db, location=top.location),
          location=top.location
        )
      ]),
      location=top.location
    );

  local fullExpr :: abs:Expr =
    abs:stmtExpr(
      abs:foldStmt([
        dbDecl,
        abs:exprStmt(callOpen)
      ]),

      abs:declRefExpr(
        db,
        location=top.location
      ),
      location=top.location
    );

  forwards to fullExpr;
}

abstract production sqliteExit
top::abs:Expr ::= db::abs:Name
{
  {-- want to forward to:
    sqlite3_close(${db});
  -}

  -- sqlite3_close(${db});
  local callClose :: abs:Expr =
    abs:directCallExpr(
      abs:name("sqlite3_close", location=top.location),
      abs:foldExpr([
        abs:declRefExpr(db, location=top.location)
      ]),
      location=top.location
    );

    forwards to callClose;
}

abstract production sqliteQueryDb
top::abs:Expr ::= db::abs:Name query::String
{
  {-- want to forward to:
    const char *_query = ${query};
    sqlite3_stmt *_stmt;
    sqlite3_prepare(${db}, _query, sizeof(query), &_stmt, NULL);
  -}

  local stmt :: abs:Name = abs:name("_stmt", location=top.location);

  -- sqlite3_stmt *_stmt;
  local stmtDecl :: abs:Stmt =
    abs:declStmt(
      abs:variableDecls(
        [],
        [],
        abs:typedefTypeExpr(
          [],
          abs:name("sqlite3_stmt", location=top.location)
        ),
        abs:foldDeclarator([
          abs:declarator(
            stmt,
            abs:pointerTypeExpr(
              [],
              abs:baseTypeExpr()
            ),
            [],
            abs:nothingInitializer()
          )
        ])
      )
    );

  -- sqlite3_prepare(${db}, _query, sizeof(query), &_stmt, NULL);
  local callPrepare :: abs:Expr =
    abs:directCallExpr(
      abs:name("sqlite3_prepare", location=top.location),
      abs:foldExpr([
        abs:declRefExpr(db, location=top.location),
        abs:stringLiteral(quote(query), location=top.location),
        abs:realConstant(
          abs:integerConstant(
            toString(length(query)),
            false,
            abs:noIntSuffix(),
            location=top.location
          ),
          location=top.location
        ),
        abs:unaryOpExpr(
          abs:addressOfOp(location=top.location),
          abs:declRefExpr(stmt, location=top.location),
          location=top.location
        ),
        abs:realConstant(
          abs:integerConstant("0", false, abs:noIntSuffix(), location=top.location),
          location=top.location
        )
      ]),
      location=top.location
    );

  local fullExpr :: abs:Expr =
    abs:stmtExpr(
      abs:foldStmt([
        stmtDecl,
        abs:exprStmt(callPrepare)
      ]),

      abs:declRefExpr(
        stmt,
        location=top.location
      ),
      location=top.location
    );

  forwards to fullExpr;
}

abstract production sqliteForeach
top::abs:Stmt ::= row::abs:Name stmt::abs:Name body::abs:Stmt
{
  {-- want to forward to:
    struct _row_t {
      const unsigned char *one;
      int two;
    };
    sqlite3_reset(${stmt});
    while (sqlite3_step(${stmt}) == SQLITE_ROW) {
      struct _row_t ${row};
      ${row}.one = sqlite3_column_text(${stmt}, 0);
      ${row}.two = sqlite3_column_int(${stmt}, 1);
      ${body};
    }
  -}

  -- SQLITE_ROW
  local sqlite_row :: abs:Expr =
    -- TODO: don't hardcode value
    abs:mkIntConst(100, builtIn());
--    abs:declRefExpr(
--      abs:name("SQLITE_ROW", location=builtIn()),
--      location=builtIn()
--    );

  -- sqlite3_step(${stmt})
  local callStep :: abs:Expr =
    abs:directCallExpr(
      abs:name("sqlite3_step", location=builtIn()),
      abs:foldExpr([
        abs:declRefExpr(stmt, location=builtIn())
      ]),
      location=builtIn()
    );

  -- sqlite3_step(${stmt}) == SQLITE_ROW
  local hasRow :: abs:Expr =
    abs:binaryOpExpr(
      callStep,
      abs:compareOp(abs:equalsOp(location=builtIn()), location=builtIn()),
      sqlite_row,
      location=builtIn()
    );

  -- while (sqlite3_step(${stmt}) == SQLITE_ROW) { ${body}; }
  local whileHasRow :: abs:Stmt =
    abs:whileStmt(
      hasRow,
      body
    );

  forwards to whileHasRow;
}

-- TODO: can this be used from ableC:abstractsyntax instead of copied?
function fromId
abs:Name ::= n::cnc:Identifier_t
{
  return abs:name(n.lexeme, location=n.location);
}

-- New location for expressions which don't have real locations
abstract production builtIn
top::Location ::=
{
  forwards to loc("Built In", 0, 0, 0, 0, 0, 0);
}


function quote
String ::= s::String
{
  return "\"" ++ s ++ "\"";
}

