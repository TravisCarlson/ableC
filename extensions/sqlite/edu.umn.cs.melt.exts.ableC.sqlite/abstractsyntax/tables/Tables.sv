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

