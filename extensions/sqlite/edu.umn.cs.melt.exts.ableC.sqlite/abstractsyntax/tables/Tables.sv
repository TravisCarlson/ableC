grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables;

imports edu:umn:cs:melt:ableC:abstractsyntax;

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

nonterminal SqliteTable with tableName, columns;
synthesized attribute tableName :: Name;
synthesized attribute columns :: [SqliteColumn];
abstract production sqliteTable
top::SqliteTable ::= n::Name cs::SqliteColumnList
{
  top.tableName = n;
  top.columns = cs.columns;
}

nonterminal SqliteColumnList with columns;
abstract production sqliteColumnList
top::SqliteColumnList ::= cs::[SqliteColumn]
{
  top.columns = cs;
}
abstract production sqliteConsColumnList
top::SqliteColumnList ::= c::SqliteColumn cs::SqliteColumnList
{
  top.columns = cons(c, cs.columns);
}
abstract production sqliteNilColumnList
top::SqliteColumnList ::=
{
  top.columns = nil();
}

nonterminal SqliteColumn with columnName, typ;
synthesized attribute columnName :: Name;
synthesized attribute typ :: SqliteColumnType;
abstract production sqliteColumn
top::SqliteColumn ::= n::Name t::SqliteColumnType
{
  top.columnName = n;
  top.typ = t;
}

nonterminal SqliteResultColumnName;
abstract production sqliteResultColumnName
top::SqliteResultColumnName ::= mName::Maybe<Name> alias::Maybe<Name>
{
}
abstract production sqliteResultColumnNameStar
top::SqliteResultColumnName ::=
{
}
abstract production sqliteResultColumnNameTableStar
top::SqliteResultColumnName ::= tableName::Name
{
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

function addAliasColumns
[SqliteTable] ::= tables::[SqliteTable] aliasColumns::[SqliteResultColumnName]
{
  return if null(aliasColumns) then tables
         else addAliasColumns(
                addAliasColumn(tables, head(aliasColumns)),
                tail(aliasColumns)
              );
}

function addAliasColumn
[SqliteTable] ::= tables::[SqliteTable] aliasColumn::SqliteResultColumnName
{
  return case aliasColumn of
           sqliteResultColumnName(mName, alias)       ->
             case mName of
               just(n)   -> case alias of
                              just(a)   -> aliasTablesColumn(tables, n, a)
                            | nothing() -> tables
                            end
             | nothing() -> tables
             end
         | sqliteResultColumnNameStar()               -> tables
         | sqliteResultColumnNameTableStar(tableName) -> tables
         end;
}

function aliasTablesColumn
[SqliteTable] ::= tables::[SqliteTable] n::Name a::Name
{
  return if null(tables) then []
         else
           cons(
             aliasTableColumn(head(tables), n, a),
             aliasTablesColumn(tail(tables), n, a)
           );
}

function aliasTableColumn
SqliteTable ::= table::SqliteTable n::Name a::Name
{
  return case findColumn(n, table.columns) of
           just(c)   -> addColumnToTable(table, a, c.typ)
         | nothing() -> table
         end;
}

function findColumn
Maybe<SqliteColumn> ::= colName::Name columns::[SqliteColumn]
{
  local attribute col :: SqliteColumn = head(columns);
  return if null(columns) then nothing()
         else if colName.name == col.columnName.name
              then just(col)
              else findColumn(colName, tail(columns));
}

function addColumnToTable
SqliteTable ::= table::SqliteTable n::Name t::SqliteColumnType
{
  local attribute newColumn :: SqliteColumn = sqliteColumn(n, t);
  return sqliteTable(table.tableName, sqliteColumnList(cons(newColumn, table.columns)));
}

