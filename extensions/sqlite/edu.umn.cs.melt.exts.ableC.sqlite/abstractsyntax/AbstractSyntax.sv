grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;

abstract production sqliteQueryExpr
top::abs:Expr ::= db::abs:Name query::String
{
{-- want to forward to this
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
        abs:stringLiteral(query, location=top.location),
        abs:realConstant(
          abs:integerConstant(
            toString(length(query)-2),
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

-- TODO: can this be used from ableC:abstractsyntax instead of copied?
function fromId
abs:Name ::= n::cnc:Identifier_t
{
  return abs:name(n.lexeme, location=n.location);
}

