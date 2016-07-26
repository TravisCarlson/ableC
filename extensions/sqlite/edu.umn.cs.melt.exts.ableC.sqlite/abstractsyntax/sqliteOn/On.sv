grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn;

imports edu:umn:cs:melt:ableC:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;

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

-- New location for expressions which don't have real locations
abstract production builtIn
top::Location ::=
{
  forwards to loc("Built In", 0, 0, 0, 0, 0, 0);
}

-- TODO: can this be used from ableC:abstractsyntax instead of copied?
function fromId
abs:Name ::= n::cnc:Identifier_t
{
  return abs:name(n.lexeme, location=n.location);
}

function quote
String ::= s::String
{
  return "\"" ++ s ++ "\"";
}

