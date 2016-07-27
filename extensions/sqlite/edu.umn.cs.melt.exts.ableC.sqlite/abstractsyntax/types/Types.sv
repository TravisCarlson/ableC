grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:types;

import edu:umn:cs:melt:ableC:abstractsyntax;
import edu:umn:cs:melt:ableC:abstractsyntax:env;

abstract production sqliteDbTypeExpr
top::BaseTypeExpr ::=
{
  top.typerep = sqliteDbType([]);
  forwards to
    typedefTypeExpr(
      [],
      name("_sqlite_db", location=builtIn())
    );
}

abstract production sqliteDbType
top::Type ::= qs::[Qualifier]
{
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

-- TODO: don't duplicate this
-- New location for expressions which don't have real locations
abstract production builtIn
top::Location ::=
{
  forwards to loc("Built In", 0, 0, 0, 0, 0, 0);
}

