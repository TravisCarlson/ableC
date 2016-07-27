grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:use;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;

abstract production sqliteUse
top::Expr ::= dbname::String
{
  top.typerep = abs:sqliteDbType([]);

  {-- want to forward to:
    _sqlite_db _db;
    sqlite3_open(${dbname}, &_db->db);
  -}

  local db :: Name = name("_db", location=top.location);

  -- _sqlite_db _db;
  local dbDecl :: Stmt =
    declStmt(
      variableDecls(
        [],
        [],
        typedefTypeExpr(
          [],
          name("_sqlite_db", location=top.location)
        ),
        foldDeclarator([
          declarator(
            db,
            baseTypeExpr(),
            [],
            nothingInitializer()
          )
        ])
      )
    );

  -- sqlite3_open(${dbname}, &_db->db);
  local callOpen :: Expr =
    directCallExpr(
      name("sqlite3_open", location=top.location),
      foldExpr([
        stringLiteral(dbname, location=top.location),
        unaryOpExpr(
          addressOfOp(location=top.location),
          memberExpr(
            declRefExpr(db, location=top.location),
            true,
            name("db", location=top.location),
            location=top.location
          ),
          location=top.location
        )
      ]),
      location=top.location
    );

  local fullExpr :: Expr =
    stmtExpr(
      foldStmt([
        dbDecl,
        exprStmt(callOpen)
      ]),

      declRefExpr(
        db,
        location=top.location
      ),
      location=top.location
    );

  forwards to fullExpr;
}

