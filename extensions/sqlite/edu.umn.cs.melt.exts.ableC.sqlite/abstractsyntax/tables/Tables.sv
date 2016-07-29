grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables;

imports edu:umn:cs:melt:ableC:abstractsyntax as abs;

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

nonterminal SqliteTable with name, columns;
synthesized attribute name :: abs:Name;
synthesized attribute columns :: [SqliteColumn];

abstract production sqliteTable
top::SqliteTable ::= n::abs:Name cs::SqliteColumnList
{
  top.name = n;
  top.columns = cs.columns;
}

nonterminal SqliteColumnList with columns;

abstract production sqliteColumnList
top::SqliteColumnList ::= c::SqliteColumn cs::SqliteColumnList
{
  top.columns = cons(c, cs.columns);
}

abstract production sqliteNilColumnList
top::SqliteColumnList ::=
{
  top.columns = nil();
}

nonterminal SqliteColumn with name, typ;
synthesized attribute typ :: SqliteColumnType;

abstract production sqliteColumn
top::SqliteColumn ::= n::abs:Name t::SqliteColumnType
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

