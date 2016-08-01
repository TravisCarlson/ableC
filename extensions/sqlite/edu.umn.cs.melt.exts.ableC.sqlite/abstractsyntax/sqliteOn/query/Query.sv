grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn:query;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:sqliteOn;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables;
imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports silver:langutil;

nonterminal SqliteQuery with queryStr, tables, columns;
synthesized attribute queryStr :: String;
synthesized attribute tables :: [Name];
synthesized attribute columns :: [SqliteColumn];

abstract production sqliteSelectQuery
top::SqliteQuery ::= s::SqliteSelectStmt queryStr::String
{
  top.queryStr = queryStr;
  top.tables = s.tables;
  top.columns = [
      sqliteColumn(name("age",       location=builtIn()), sqliteInteger()),
      sqliteColumn(name("gender",    location=builtIn()), sqliteVarchar()),
      sqliteColumn(name("last_name", location=builtIn()), sqliteVarchar())
    ];
}

nonterminal SqliteSelectStmt with tables;
abstract production sqliteSelectStmt
top::SqliteSelectStmt ::= mw::Maybe<SqliteWith> s::SqliteSelectCore mo::Maybe<SqliteOrder> ml::Maybe<SqliteLimit>
{
  local attribute wtables :: [Name] =
    case mw of just(w) -> w.tables | nothing() -> [] end;
  local attribute otables :: [Name] =
    case mo of just(o) -> o.tables | nothing() -> [] end;
  local attribute ltables :: [Name] =
    case ml of just(l) -> l.tables | nothing() -> [] end;

  top.tables = wtables ++ s.tables ++ otables ++ ltables;
}

nonterminal SqliteWith with tables;
abstract production sqliteWith
top::SqliteWith ::= isRecursive::Boolean cs::SqliteCommonTableExprList
{
  top.tables = cs.tables;
}

nonterminal SqliteCommonTableExprList with tables;
abstract production sqliteCommonTableExprList
top::SqliteCommonTableExprList ::= c::SqliteCommonTableExpr cs::SqliteCommonTableExprList
{
  top.tables = cs.tables ++ c.tables;
}
abstract production sqliteNilCommonTableExprList
top::SqliteCommonTableExprList ::=
{
  top.tables = [];
}

nonterminal SqliteCommonTableExpr with tables;
abstract production sqliteCommonTableExpr
top::SqliteCommonTableExpr ::= tableName::Name s::SqliteSelectStmt mcs::Maybe<SqliteColumnNameList>
{
  top.tables = [tableName];
}

nonterminal SqliteSelectCore with tables;
abstract production sqliteSelectCoreSelect
top::SqliteSelectCore ::= s::SqliteSelect
{
  top.tables = s.tables;
}
abstract production sqliteSelectCoreValues
top::SqliteSelectCore ::= v::SqliteValues
{
  top.tables = v.tables;
}

nonterminal SqliteSelect with tables;
abstract production sqliteSelect
top::SqliteSelect ::= md::Maybe<SqliteDistinctOrAll> rs::SqliteResultColumnList mf::Maybe<SqliteFrom>
                      mw::Maybe<SqliteWhere> mg::Maybe<SqliteGroup>
{
  local attribute ftables :: [Name] =
    case mf of just(f) -> f.tables | nothing() -> [] end;
  local attribute wtables :: [Name] =
    case mw of just(w) -> w.tables | nothing() -> [] end;
  local attribute gtables :: [Name] =
    case mg of just(g) -> g.tables | nothing() -> [] end;

    top.tables = rs.tables ++ ftables ++ wtables ++ gtables;
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

nonterminal SqliteResultColumnList with tables;
abstract production sqliteResultColumnList
top::SqliteResultColumnList ::= r::SqliteResultColumn rs::SqliteResultColumnList
{
  top.tables = rs.tables ++ r.tables;
}

abstract production sqliteNilResultColumnList
top::SqliteResultColumnList ::=
{
  top.tables = [];
}

nonterminal SqliteResultColumn with tables;
abstract production sqliteResultColumnExpr
top::SqliteResultColumn ::= e::SqliteExpr mc::Maybe<SqliteAsColumnAlias>
{
  top.tables = e.tables;
}
abstract production sqliteResultColumnStar
top::SqliteResultColumn ::=
{
  top.tables = [];
}
abstract production sqliteResultColumnTableStar
top::SqliteResultColumn ::= tableName::Name
{
  top.tables = [tableName];
}

nonterminal SqliteAsColumnAlias;
abstract production sqliteAsColumnAlias
top::SqliteAsColumnAlias ::= columnAlias::Name
{
}

nonterminal SqliteFrom with tables;
abstract production sqliteFrom
top::SqliteFrom ::= t::SqliteTableOrSubqueryListOrJoin
{
  top.tables = t.tables;
}

nonterminal SqliteTableOrSubqueryListOrJoin with tables;
abstract production sqliteTableOrSubqueryListOrJoin
top::SqliteTableOrSubqueryListOrJoin ::= j::SqliteJoinClause
{
  top.tables = j.tables;
}

nonterminal SqliteTableOrSubquery with table;
synthesized attribute table :: Name;
abstract production sqliteTableOrSubquery
top::SqliteTableOrSubquery ::= tableName::Name
{
  top.table = tableName;
}

nonterminal SqliteJoinClause with tables;
abstract production sqliteJoinClause
top::SqliteJoinClause ::= t::SqliteTableOrSubquery mj::Maybe<SqliteJoinList>
{
  top.tables =
    case mj of
      just(j)   -> cons(t.table, j.tables)
    | nothing() -> [t.table]
    end;
}

nonterminal SqliteJoinList with tables;
abstract production sqliteJoinList
top::SqliteJoinList ::= j::SqliteJoin js::SqliteJoinList
{
  top.tables = js.tables ++ j.tables;
}

abstract production sqliteNilJoinList
top::SqliteJoinList ::=
{
  top.tables = [];
}

nonterminal SqliteJoin with tables;
abstract production sqliteJoin
top::SqliteJoin ::= o::SqliteJoinOperator t::SqliteTableOrSubquery mc::Maybe<SqliteJoinConstraint>
{
  local attribute ctables :: [Name] =
    case mc of just(c) -> c.tables | nothing() -> []
    end;

  top.tables = cons(t.table, ctables);
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

nonterminal SqliteJoinConstraint with tables;
abstract production sqliteOnConstraint
top::SqliteJoinConstraint ::= e::SqliteExpr
{
  top.tables = e.tables;
}
abstract production sqliteUsingConstraint
top::SqliteJoinConstraint ::= cs::SqliteColumnNameList
{
  top.tables = [];
}

nonterminal SqliteWhere with tables;
abstract production sqliteWhere
top::SqliteWhere ::= e::SqliteExpr
{
  top.tables = e.tables;
}

nonterminal SqliteGroup with tables;
abstract production sqliteGroup
top::SqliteGroup ::= es::SqliteExprList mh::Maybe<SqliteHaving>
{
  local attribute htables :: [Name] =
    case mh of just(h) -> h.tables | nothing() -> [] end;
  top.tables = es.tables ++ htables;
}

nonterminal SqliteHaving with tables;
abstract production sqliteHaving
top::SqliteHaving ::= e::SqliteExpr
{
  top.tables = e.tables;
}

nonterminal SqliteValues with tables;
abstract production sqliteValues
top::SqliteValues ::= es::SqliteExprListList
{
  top.tables = es.tables;
}

nonterminal SqliteExprListList with tables;
abstract production sqliteExprListList
top::SqliteExprListList ::= e::SqliteExprList es::SqliteExprListList
{
  top.tables = es.tables ++ e.tables;
}
abstract production sqliteNilExprListList
top::SqliteExprListList ::=
{
  top.tables = [];
}

nonterminal SqliteExprList with tables;
abstract production sqliteExprList
top::SqliteExprList ::= e::SqliteExpr es::SqliteExprList
{
  top.tables = es.tables ++ e.tables;
}
abstract production sqliteNilExprList
top::SqliteExprList ::=
{
  top.tables = [];
}

nonterminal SqliteExpr with tables;
abstract production sqliteLiteralValueExpr
top::SqliteExpr ::=
{
  top.tables = [];
}
abstract production sqliteSchemaTableColumnNameExpr
top::SqliteExpr ::= n::SqliteSchemaTableColumnName
{
  top.tables = n.tables;
}
abstract production sqliteBinaryExpr
top::SqliteExpr ::= e1::SqliteExpr e2::SqliteExpr
{
  top.tables = e1.tables ++ e2.tables;
}
abstract production sqliteUnaryExpr
top::SqliteExpr ::= e::SqliteExpr
{
  top.tables = e.tables;
}
abstract production sqliteFunctionCallExpr
top::SqliteExpr ::= functionName::Name ma::Maybe<SqliteFunctionArgs>
{
  local attribute atables :: [Name] =
    case ma of just(a) -> a.tables | nothing() -> [] end;
  top.tables = atables;
}

nonterminal SqliteSchemaTableColumnName with tables;
abstract production sqliteSchemaTableColumnName
top::SqliteSchemaTableColumnName ::= schemaName::Name tableName::Name columnName::Name
{
  top.tables = [tableName];
}
abstract production sqliteTableColumnName
top::SqliteSchemaTableColumnName ::= tableName::Name columnName::Name
{
  top.tables = [tableName];
}
abstract production sqliteColumnName
top::SqliteSchemaTableColumnName ::= columnName::Name
{
  top.tables = [];
}

nonterminal SqliteFunctionArgs with tables;
abstract production sqliteFunctionArgs
top::SqliteFunctionArgs ::= isDistinct::Boolean es::SqliteExprList
{
  top.tables = es.tables;
}
abstract production sqliteFunctionArgsStar
top::SqliteFunctionArgs ::=
{
  top.tables = [];
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

nonterminal SqliteOrder with tables;
abstract production sqliteOrder
top::SqliteOrder ::= os::SqliteOrderingTermList
{
  top.tables = os.tables;
}

nonterminal SqliteOrderingTermList with tables;
abstract production sqliteOrderingTermList
top::SqliteOrderingTermList ::= o::SqliteOrderingTerm os::SqliteOrderingTermList
{
  top.tables = o.tables ++ os.tables;
}
abstract production sqliteNilOrderingTermList
top::SqliteOrderingTermList ::=
{
  top.tables = [];
}

nonterminal SqliteOrderingTerm with tables;
abstract production sqliteOrderingTerm
top::SqliteOrderingTerm ::= e::SqliteExpr mc::Maybe<SqliteCollate>
{
  top.tables = e.tables;
}

nonterminal SqliteCollate;
abstract production sqliteCollate
top::SqliteCollate ::= collationName::Name
{
}

nonterminal SqliteLimit with tables;
abstract production sqliteLimit
top::SqliteLimit ::= e::SqliteExpr mo::Maybe<SqliteOffsetExpr>
{
  local attribute otables :: [Name] =
    case mo of just(o) -> o.tables | nothing() -> [] end;
  top.tables = e.tables ++ otables;
}

nonterminal SqliteOffsetExpr with tables;
abstract production sqliteOffsetExpr
top::SqliteOffsetExpr ::= e::SqliteExpr
{
  top.tables = e.tables;
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

