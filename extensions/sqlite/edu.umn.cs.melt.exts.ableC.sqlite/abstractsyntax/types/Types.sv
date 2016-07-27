grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:types;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables as tbls;
import edu:umn:cs:melt:ableC:abstractsyntax;
import edu:umn:cs:melt:ableC:abstractsyntax:env;
import edu:umn:cs:melt:ableC:abstractsyntax:overload;

abstract production sqliteDbTypeExpr
top::BaseTypeExpr ::=
{
  top.typerep = sqliteDbType([], []);
--    [
--      tbls:sqliteTable(
--        name("tbl1", location=builtIn()),
--        tbls:sqliteNilColumnDeclList()
--      )
--    ]
--  );

  forwards to
    typedefTypeExpr(
      [],
      name("_sqlite_db", location=builtIn())
    );
}

abstract production sqliteDbType
top::Type ::= qs::[Qualifier] tables::[tbls:SqliteTable]
{
--  top.lAssignProd =
--    case top.otherType of
--      sqliteDbType(_, _) -> just(assignSqliteDb(_, _, location=_))
--    | _ -> nothing()
--    end;

  forwards to
    noncanonicalType(
      typedefType(
        qs,
        "_sqlite_db",
        pointerType(
          [],
          tagType(
            [],
            refIdTagType(
              structSEU(),
              "_sqlite_db_s",
              "edu:umn:cs:melt:exts:ableC:sqlite:_sqlite_db_s"
            )
          )
        )
      )
    );
}

--abstract production assignSqliteDb
--top::Expr ::= e1::Expr e2::Expr
--{
--  top.typerep = e1.typerep;
--
--  forwards to
--    binaryOpExpr(
--      e1,
--      assignOp(eqOp(location=builtIn()), location=builtIn()),
--      e2,
--      location=builtIn());
--}

-- TODO: don't duplicate this
-- New location for expressions which don't have real locations
abstract production builtIn
top::Location ::=
{
  forwards to loc("Built In", 0, 0, 0, 0, 0, 0);
}

