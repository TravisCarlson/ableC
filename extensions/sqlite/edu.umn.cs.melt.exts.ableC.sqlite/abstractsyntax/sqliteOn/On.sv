grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports silver:langutil;

abstract production sqliteExit
top::Expr ::= db::Expr
{
  local localErrors :: [Message] =
    case db.typerep of
      abs:sqliteDbType(_) -> []
    | errorType() -> []
    | _ -> [err(db.location, "expected SqliteDb type")]
    end;

  {-- want to forward to:
    sqlite3_close(${db}.db);
  -}

  -- sqlite3_close(${db}.db);
  local callClose :: Expr =
    directCallExpr(
      name("sqlite3_close", location=top.location),
      foldExpr([
        memberExpr(db, true, name("db", location=top.location), location=top.location)
      ]),
      location=top.location
    );

    forwards to mkErrorCheck(localErrors, callClose);
}

abstract production sqliteQueryDb
top::Expr ::= db::Expr query::String
{
  {-- want to forward to:
    const char *_query = ${query};
    sqlite3_stmt *_stmt;
    sqlite3_prepare(${db}.db, _query, sizeof(query), &_stmt, NULL);
  -}

  local stmt :: Name = name("_stmt", location=top.location);

  -- sqlite3_stmt *_stmt;
  local stmtDecl :: Stmt =
    declStmt(
      variableDecls(
        [],
        [],
        typedefTypeExpr(
          [],
          name("sqlite3_stmt", location=top.location)
        ),
        foldDeclarator([
          declarator(
            stmt,
            pointerTypeExpr(
              [],
              baseTypeExpr()
            ),
            [],
            nothingInitializer()
          )
        ])
      )
    );

  -- sqlite3_prepare(${db}.db, _query, sizeof(query), &_stmt, NULL);
  local callPrepare :: Expr =
    directCallExpr(
      name("sqlite3_prepare", location=top.location),
      foldExpr([
        memberExpr(db, true, name("db", location=top.location), location=top.location),
        stringLiteral(quote(query), location=top.location),
        realConstant(
          integerConstant(
            toString(length(query)),
            false,
            noIntSuffix(),
            location=top.location
          ),
          location=top.location
        ),
        unaryOpExpr(
          addressOfOp(location=top.location),
          declRefExpr(stmt, location=top.location),
          location=top.location
        ),
        realConstant(
          integerConstant("0", false, noIntSuffix(), location=top.location),
          location=top.location
        )
      ]),
      location=top.location
    );

  local fullExpr :: Expr =
    stmtExpr(
      foldStmt([
        stmtDecl,
        exprStmt(callPrepare)
      ]),

      declRefExpr(
        stmt,
        location=top.location
      ),
      location=top.location
    );

  forwards to fullExpr;
}

abstract production sqliteForeach
top::Stmt ::= row::Name stmt::Expr body::Stmt
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
  local sqlite_row :: Expr =
    -- TODO: don't hardcode value
    mkIntConst(100, builtIn());
--    declRefExpr(
--      name("SQLITE_ROW", location=builtIn()),
--      location=builtIn()
--    );

  -- sqlite3_step(${stmt})
  local callStep :: Expr =
    directCallExpr(
      name("sqlite3_step", location=builtIn()),
      foldExpr([stmt]),
      location=builtIn()
    );

  -- sqlite3_step(${stmt}) == SQLITE_ROW
  local hasRow :: Expr =
    binaryOpExpr(
      callStep,
      compareOp(equalsOp(location=builtIn()), location=builtIn()),
      sqlite_row,
      location=builtIn()
    );

  -- while (sqlite3_step(${stmt}) == SQLITE_ROW) { ${body}; }
  local whileHasRow :: Stmt =
    whileStmt(
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
Name ::= n::cnc:Identifier_t
{
  return name(n.lexeme, location=n.location);
}

function quote
String ::= s::String
{
  return "\"" ++ s ++ "\"";
}

