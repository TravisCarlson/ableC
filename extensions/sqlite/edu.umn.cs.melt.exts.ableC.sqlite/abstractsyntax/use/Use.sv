grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:use;

imports edu:umn:cs:melt:ableC:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;

abstract production sqliteUse
top::abs:Expr ::= dbname::String
{
--  top.typerep = sqliteDbType();

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

