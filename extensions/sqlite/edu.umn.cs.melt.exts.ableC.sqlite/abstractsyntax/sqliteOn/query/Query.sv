grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn:query;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables;
imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports silver:langutil;

nonterminal SqliteQuery with queryStr, usedTables, resultColumns;
synthesized attribute queryStr :: String;
synthesized attribute usedTables :: [Name];
synthesized attribute resultColumns :: [SqliteColumnName];

abstract production sqliteSelectQuery
top::SqliteQuery ::= s::SqliteSelectStmt queryStr::String
{
  top.queryStr = queryStr;
  top.usedTables = s.usedTables;
  top.resultColumns = s.resultColumns;
}

nonterminal SqliteSelectStmt with usedTables, resultColumns;
abstract production sqliteSelectStmt
top::SqliteSelectStmt ::= mw::Maybe<SqliteWith> s::SqliteSelectCore mo::Maybe<SqliteOrder> ml::Maybe<SqliteLimit>
{
  local attribute wtables :: [Name] =
    case mw of just(w) -> w.usedTables | nothing() -> [] end;
  local attribute otables :: [Name] =
    case mo of just(o) -> o.usedTables | nothing() -> [] end;
  local attribute ltables :: [Name] =
    case ml of just(l) -> l.usedTables | nothing() -> [] end;

  top.usedTables = wtables ++ s.usedTables ++ otables ++ ltables;
  top.resultColumns = s.resultColumns;
}

nonterminal SqliteWith with usedTables;
abstract production sqliteWith
top::SqliteWith ::= isRecursive::Boolean cs::SqliteCommonTableExprList
{
  top.usedTables = cs.usedTables;
}

nonterminal SqliteCommonTableExprList with usedTables;
abstract production sqliteCommonTableExprList
top::SqliteCommonTableExprList ::= c::SqliteCommonTableExpr cs::SqliteCommonTableExprList
{
  top.usedTables = cs.usedTables ++ c.usedTables;
}
abstract production sqliteNilCommonTableExprList
top::SqliteCommonTableExprList ::=
{
  top.usedTables = [];
}

nonterminal SqliteCommonTableExpr with usedTables;
abstract production sqliteCommonTableExpr
top::SqliteCommonTableExpr ::= tableName::Name s::SqliteSelectStmt mcs::Maybe<SqliteColumnNameList>
{
  top.usedTables = [tableName];
}

nonterminal SqliteSelectCore with usedTables, resultColumns;
abstract production sqliteSelectCoreSelect
top::SqliteSelectCore ::= s::SqliteSelect
{
  top.usedTables = s.usedTables;
  top.resultColumns = s.resultColumns;
}
abstract production sqliteSelectCoreValues
top::SqliteSelectCore ::= v::SqliteValues
{
  top.usedTables = v.usedTables;
  top.resultColumns = [];
}

nonterminal SqliteSelect with usedTables, resultColumns;
abstract production sqliteSelect
top::SqliteSelect ::= md::Maybe<SqliteDistinctOrAll> rs::SqliteResultColumnList mf::Maybe<SqliteFrom>
                      mw::Maybe<SqliteWhere> mg::Maybe<SqliteGroup>
{
  local attribute ftables :: [Name] =
    case mf of just(f) -> f.usedTables | nothing() -> [] end;
  local attribute wtables :: [Name] =
    case mw of just(w) -> w.usedTables | nothing() -> [] end;
  local attribute gtables :: [Name] =
    case mg of just(g) -> g.usedTables | nothing() -> [] end;

  top.usedTables = rs.usedTables ++ ftables ++ wtables ++ gtables;
  top.resultColumns = reverse(rs.resultColumns);
}

nonterminal SqliteDistinctOrAll;
abstract production sqliteDistinct
top::SqliteDistinctOrAll ::=
{
}
abstract production sqliteAll
top::SqliteDistinctOrAll ::=
{
}

nonterminal SqliteResultColumnList with usedTables, resultColumns;
abstract production sqliteResultColumnList
top::SqliteResultColumnList ::= r::SqliteResultColumn rs::SqliteResultColumnList
{
  top.usedTables = rs.usedTables ++ r.usedTables;
  top.resultColumns = cons(r.resultColumn, rs.resultColumns);
}
abstract production sqliteNilResultColumnList
top::SqliteResultColumnList ::=
{
  top.usedTables = [];
  top.resultColumns = [];
}

nonterminal SqliteResultColumn with usedTables, resultColumn;
synthesized attribute resultColumn :: SqliteColumnName;
abstract production sqliteResultColumnExpr
top::SqliteResultColumn ::= e::SqliteExpr mc::Maybe<SqliteAsColumnAlias>
{
  local attribute colName :: Maybe<Name> =
    case e of
      sqliteSchemaTableColumnNameExpr(n) -> just(n.colName)
    | _                                  -> nothing()
    end;
  local attribute columnAlias :: Maybe<Name> =
    case mc of
      just(c)   -> just(c.columnAlias)
    | nothing() -> nothing()
  end;

  top.usedTables = e.usedTables;
  top.resultColumn = sqliteColumnName(colName, columnAlias);
}
abstract production sqliteResultColumnStar
top::SqliteResultColumn ::=
{
  top.usedTables = [];
}
abstract production sqliteResultColumnTableStar
top::SqliteResultColumn ::= tableName::Name
{
  top.usedTables = [tableName];
}

nonterminal SqliteAsColumnAlias with columnAlias;
synthesized attribute columnAlias :: Name;
abstract production sqliteAsColumnAlias
top::SqliteAsColumnAlias ::= columnAlias::Name
{
  top.columnAlias = columnAlias;
}

nonterminal SqliteFrom with usedTables;
abstract production sqliteFrom
top::SqliteFrom ::= t::SqliteTableOrSubqueryListOrJoin
{
  top.usedTables = t.usedTables;
}

nonterminal SqliteTableOrSubqueryListOrJoin with usedTables;
abstract production sqliteTableOrSubqueryListOrJoin
top::SqliteTableOrSubqueryListOrJoin ::= j::SqliteJoinClause
{
  top.usedTables = j.usedTables;
}

nonterminal SqliteTableOrSubquery with table;
synthesized attribute table :: Name;
abstract production sqliteTableOrSubquery
top::SqliteTableOrSubquery ::= tableName::Name
{
  top.table = tableName;
}

nonterminal SqliteJoinClause with usedTables;
abstract production sqliteJoinClause
top::SqliteJoinClause ::= t::SqliteTableOrSubquery mj::Maybe<SqliteJoinList>
{
  top.usedTables =
    case mj of
      just(j)   -> cons(t.table, j.usedTables)
    | nothing() -> [t.table]
    end;
}

nonterminal SqliteJoinList with usedTables;
abstract production sqliteJoinList
top::SqliteJoinList ::= j::SqliteJoin js::SqliteJoinList
{
  top.usedTables = js.usedTables ++ j.usedTables;
}

abstract production sqliteNilJoinList
top::SqliteJoinList ::=
{
  top.usedTables = [];
}

nonterminal SqliteJoin with usedTables;
abstract production sqliteJoin
top::SqliteJoin ::= o::SqliteJoinOperator t::SqliteTableOrSubquery mc::Maybe<SqliteJoinConstraint>
{
  local attribute ctables :: [Name] =
    case mc of just(c) -> c.usedTables | nothing() -> []
    end;

  top.usedTables = cons(t.table, ctables);
}

nonterminal SqliteJoinOperator;
abstract production sqliteJoinOperator
top::SqliteJoinOperator ::= isNatural::Boolean ml::Maybe<SqliteLeftOrInnerOrCross>
{
}

nonterminal SqliteLeftOrInnerOrCross;
abstract production sqliteLeft
top::SqliteLeftOrInnerOrCross ::= isOuter::Boolean
{
}
abstract production sqliteInner
top::SqliteLeftOrInnerOrCross ::=
{
}
abstract production sqliteCross
top::SqliteLeftOrInnerOrCross ::=
{
}

nonterminal SqliteJoinConstraint with usedTables;
abstract production sqliteOnConstraint
top::SqliteJoinConstraint ::= e::SqliteExpr
{
  top.usedTables = e.usedTables;
}
abstract production sqliteUsingConstraint
top::SqliteJoinConstraint ::= cs::SqliteColumnNameList
{
  top.usedTables = [];
}

nonterminal SqliteWhere with usedTables;
abstract production sqliteWhere
top::SqliteWhere ::= e::SqliteExpr
{
  top.usedTables = e.usedTables;
}

nonterminal SqliteGroup with usedTables;
abstract production sqliteGroup
top::SqliteGroup ::= es::SqliteExprList mh::Maybe<SqliteHaving>
{
  local attribute htables :: [Name] =
    case mh of just(h) -> h.usedTables | nothing() -> [] end;
  top.usedTables = es.usedTables ++ htables;
}

nonterminal SqliteHaving with usedTables;
abstract production sqliteHaving
top::SqliteHaving ::= e::SqliteExpr
{
  top.usedTables = e.usedTables;
}

nonterminal SqliteValues with usedTables;
abstract production sqliteValues
top::SqliteValues ::= es::SqliteExprListList
{
  top.usedTables = es.usedTables;
}

nonterminal SqliteExprListList with usedTables;
abstract production sqliteExprListList
top::SqliteExprListList ::= e::SqliteExprList es::SqliteExprListList
{
  top.usedTables = es.usedTables ++ e.usedTables;
}
abstract production sqliteNilExprListList
top::SqliteExprListList ::=
{
  top.usedTables = [];
}

nonterminal SqliteExprList with usedTables;
abstract production sqliteExprList
top::SqliteExprList ::= e::SqliteExpr es::SqliteExprList
{
  top.usedTables = es.usedTables ++ e.usedTables;
}
abstract production sqliteNilExprList
top::SqliteExprList ::=
{
  top.usedTables = [];
}

nonterminal SqliteExpr with usedTables;
abstract production sqliteLiteralValueExpr
top::SqliteExpr ::=
{
  top.usedTables = [];
}
abstract production sqliteSchemaTableColumnNameExpr
top::SqliteExpr ::= n::SqliteSchemaTableColumnName
{
  top.usedTables = n.usedTables;
}
abstract production sqliteBinaryExpr
top::SqliteExpr ::= e1::SqliteExpr e2::SqliteExpr
{
  top.usedTables = e1.usedTables ++ e2.usedTables;
}
abstract production sqliteUnaryExpr
top::SqliteExpr ::= e::SqliteExpr
{
  top.usedTables = e.usedTables;
}
abstract production sqliteFunctionCallExpr
top::SqliteExpr ::= functionName::Name ma::Maybe<SqliteFunctionArgs>
{
  local attribute atables :: [Name] =
    case ma of just(a) -> a.usedTables | nothing() -> [] end;
  top.usedTables = atables;
}

nonterminal SqliteSchemaTableColumnName with usedTables, colName;
synthesized attribute colName :: Name;
abstract production sqliteSchemaTableColumnName
top::SqliteSchemaTableColumnName ::= schemaName::Name tableName::Name colName::Name
{
  top.usedTables = [tableName];
  top.colName = colName;
}
abstract production sqliteTableColumnName
top::SqliteSchemaTableColumnName ::= tableName::Name colName::Name
{
  top.usedTables = [tableName];
  top.colName = colName;
}
abstract production sqliteSColumnName
top::SqliteSchemaTableColumnName ::= colName::Name
{
  top.usedTables = [];
  top.colName = colName;
}

nonterminal SqliteFunctionArgs with usedTables;
abstract production sqliteFunctionArgs
top::SqliteFunctionArgs ::= isDistinct::Boolean es::SqliteExprList
{
  top.usedTables = es.usedTables;
}
abstract production sqliteFunctionArgsStar
top::SqliteFunctionArgs ::=
{
  top.usedTables = [];
}

nonterminal SqliteColumnNameList;
abstract production sqliteColumnNameList
top::SqliteColumnNameList ::= c::Name cs::SqliteColumnNameList
{
}
abstract production sqliteNilColumnNameList
top::SqliteColumnNameList ::=
{
}

nonterminal SqliteOrder with usedTables;
abstract production sqliteOrder
top::SqliteOrder ::= os::SqliteOrderingTermList
{
  top.usedTables = os.usedTables;
}

nonterminal SqliteOrderingTermList with usedTables;
abstract production sqliteOrderingTermList
top::SqliteOrderingTermList ::= o::SqliteOrderingTerm os::SqliteOrderingTermList
{
  top.usedTables = o.usedTables ++ os.usedTables;
}
abstract production sqliteNilOrderingTermList
top::SqliteOrderingTermList ::=
{
  top.usedTables = [];
}

nonterminal SqliteOrderingTerm with usedTables;
abstract production sqliteOrderingTerm
top::SqliteOrderingTerm ::= e::SqliteExpr mc::Maybe<SqliteCollate>
{
  top.usedTables = e.usedTables;
}

nonterminal SqliteCollate;
abstract production sqliteCollate
top::SqliteCollate ::= collationName::Name
{
}

nonterminal SqliteLimit with usedTables;
abstract production sqliteLimit
top::SqliteLimit ::= e::SqliteExpr mo::Maybe<SqliteOffsetExpr>
{
  local attribute otables :: [Name] =
    case mo of just(o) -> o.usedTables | nothing() -> [] end;
  top.usedTables = e.usedTables ++ otables;
}

nonterminal SqliteOffsetExpr with usedTables;
abstract production sqliteOffsetExpr
top::SqliteOffsetExpr ::= e::SqliteExpr
{
  top.usedTables = e.usedTables;
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

function makeResultColumns
[SqliteColumn] ::= columnNames::[SqliteColumnName] tables::[SqliteTable]
{
  local attribute rest :: [SqliteColumn] =
    makeResultColumns(tail(columnNames), tables);
  return if null(columnNames) then []
         else
           case makeResultColumn(head(columnNames), tables) of
             just(c)   -> cons(c, rest)
           | nothing() -> rest
           end;
}

function makeResultColumn
Maybe<SqliteColumn> ::= columnName::SqliteColumnName tables::[SqliteTable]
{
  return
    case columnName.mName of
      just(n)   -> just(sqliteColumn(columnName, lookupColumnTypeInTables(n, tables)))
    | nothing() -> nothing()
    end;
}

function lookupColumnTypeInTables
SqliteColumnType ::= n::Name tables::[SqliteTable]
{
  return
    if null(tables) then error("no such column: " ++ n.name)
    else case lookupColumnTypeInColumns(n, head(tables).columns) of
           just(t)   -> t
         | nothing() -> lookupColumnTypeInTables(n, tail(tables))
         end;
}

function lookupColumnTypeInColumns
Maybe<SqliteColumnType> ::= n::Name columns::[SqliteColumn]
{
  local attribute nextColumn :: SqliteColumn = head(columns);
  local attribute lookupRest :: Maybe<SqliteColumnType> =
    lookupColumnTypeInColumns(n, tail(columns));

  return
    if null(columns) then nothing()
    else case nextColumn.columnName.mName of
           just(name(n2)) -> if n.name == n2
                             then just(nextColumn.typ)
                             else lookupRest
         | nothing()      -> lookupRest
         end;
}

