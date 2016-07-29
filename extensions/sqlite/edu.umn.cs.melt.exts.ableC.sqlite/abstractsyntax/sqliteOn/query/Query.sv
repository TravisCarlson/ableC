grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn:query;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables;
imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports silver:langutil;

abstract production sqliteQuery
top::SqliteQuery ::= pp::String tables::[Name]
{
  top.pp = pp;
  top.tables = tables;
}

function checkTablesExist
[Message] ::= expectedTables::[SqliteTable] foundTables::[Name]
{
  local foundTable :: Name = head(foundTables);
  local localErrors :: [Message] =
    if tableExistsIn(expectedTables, foundTable) then []
    else [err(foundTable.location, "no such table: " ++ foundTable.name)];

  return if null(foundTables) then []
         else localErrors ++ checkTablesExist(expectedTables, tail(foundTables));
}

function tableExistsIn
Boolean ::= tables::[SqliteTable] table::Name
{
  return if null(tables) then false
         else (head(tables).name.name == table.name) || tableExistsIn(tail(tables), table);
}

