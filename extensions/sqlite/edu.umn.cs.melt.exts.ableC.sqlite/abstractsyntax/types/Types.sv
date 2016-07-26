grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:types;

imports edu:umn:cs:melt:ableC:abstractsyntax as abs;

abstract production sqliteDbTypeExpr
top::abs:BaseTypeExpr ::=
{
--  top.typerep = sqliteDbType();
  forwards to
        abs:typedefTypeExpr(
          [],
          abs:name("sqlite3", location=builtIn())
        );
}

abstract production sqliteDbType
top::abs:Type ::=
{
  forwards to abs:builtinType([], abs:boolType());
}

-- TODO: don't duplicate this
-- New location for expressions which don't have real locations
abstract production builtIn
top::Location ::=
{
  forwards to loc("Built In", 0, 0, 0, 0, 0, 0);
}

