grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:sqliteOn:query;

imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
import silver:langutil;

lexer class SqliteKeyword dominates cnc:Identifier_t;

terminal SqliteWith_t 'WITH' lexer classes {SqliteKeyword};
terminal SqliteRecursive_t 'RECURSIVE' lexer classes {SqliteKeyword};
terminal SqliteAs_t 'AS' lexer classes {SqliteKeyword};
terminal SqliteSelect_t 'SELECT' lexer classes {SqliteKeyword};
terminal SqliteDistinct_t 'DISTINCT' lexer classes {SqliteKeyword};
terminal SqliteAll_t 'ALL' lexer classes {SqliteKeyword};
terminal SqliteFrom_t 'FROM' lexer classes {SqliteKeyword};
terminal SqliteGroup_t 'GROUP' lexer classes {SqliteKeyword};
terminal SqliteBy_t 'BY' lexer classes {SqliteKeyword};
terminal SqliteHaving_t 'HAVING' lexer classes {SqliteKeyword};
terminal SqliteNatural_t 'NATURAL' lexer classes {SqliteKeyword};
terminal SqliteLeft_t 'LEFT' lexer classes {SqliteKeyword};
terminal SqliteOuter_t 'OUTER' lexer classes {SqliteKeyword};
terminal SqliteInner_t 'INNER' lexer classes {SqliteKeyword};
terminal SqliteCross_t 'CROSS' lexer classes {SqliteKeyword};
terminal SqliteJoin_t 'JOIN' lexer classes {SqliteKeyword};
terminal SqliteOnConstraint_t 'ON' lexer classes {SqliteKeyword};
terminal SqliteUsing_t 'USING' lexer classes {SqliteKeyword};
terminal SqliteWhere_t 'WHERE' lexer classes {SqliteKeyword};
terminal SqliteValues_t 'VALUES' lexer classes {SqliteKeyword};
terminal SqliteOrder_t 'ORDER' lexer classes {SqliteKeyword};
terminal SqliteAsc_t 'ASC' lexer classes {SqliteKeyword};
terminal SqliteDesc_t 'DESC' lexer classes {SqliteKeyword};
terminal SqliteLimit_t 'LIMIT' lexer classes {SqliteKeyword};
terminal SqliteOffset_t 'OFFSET' lexer classes {SqliteKeyword};
terminal SqliteNull_t 'NULL' lexer classes {SqliteKeyword};
terminal SqliteCurrentTime_t 'CURRENT_TIME' lexer classes {SqliteKeyword};
terminal SqliteCurrentDate_t 'CURRENT_DATE' lexer classes {SqliteKeyword};
terminal SqliteCurrentTimestamp_t 'CURRENT_TIMESTAMP' lexer classes {SqliteKeyword};
terminal SqliteCast_t 'CAST' lexer classes {SqliteKeyword};
terminal SqliteBetween_t 'BETWEEN' lexer classes {SqliteKeyword};

--terminal SqliteDecimalLiteral_t /(([0-9]+(\.[0-9]+)?)|(\.[0-9]+))(E[+-]?[0-9]+)?/;
terminal SqliteDecimalLiteral_t /[0-9]+(\.[0-9]+)?/;
terminal SqliteHexLiteral_t /0x[0-9a-fA-f]+/;
terminal SqliteStringLiteral_t /'.*'/;
terminal SqliteBlobLiteral_t /[xX]'.*'/;

terminal SqliteCollate_t 'COLLATE' precedence = 8, association = left, lexer classes {SqliteKeyword};
terminal SqliteOr_t 'OR' precedence = 10, association = left, lexer classes {SqliteKeyword};
terminal SqliteAnd_t 'AND' precedence = 12, association = left, lexer classes {SqliteKeyword};
terminal SqliteEquals_t '=' precedence = 14, association = left;
terminal SqliteEquals2_t '==' precedence = 14, association = left;
terminal SqliteNotEqual_t '!=' precedence = 14, association = left;
terminal SqliteNotEqual2_t '<>' precedence = 14, association = left;
terminal SqliteIs_t 'IS' precedence = 14, association = left, lexer classes {SqliteKeyword};
terminal SqliteIn_t 'IN' precedence = 14, association = left, lexer classes {SqliteKeyword};
terminal SqliteLike_t 'LIKE' precedence = 14, association = left, lexer classes {SqliteKeyword};
terminal SqliteGlob_t 'GLOB' precedence = 14, association = left, lexer classes {SqliteKeyword};
terminal SqliteMatch_t 'MATCH' precedence = 14, association = left, lexer classes {SqliteKeyword};
terminal SqliteRegexp_t 'REGEXP' precedence = 14, association = left, lexer classes {SqliteKeyword};
terminal SqliteLt_t '<' precedence = 16, association = left;
terminal SqliteLe_t '<=' precedence = 16, association = left;
terminal SqliteGt_t '>' precedence = 16, association = left;
terminal SqliteGe_t '>=' precedence = 16, association = left;
terminal SqliteSl_t '<<' precedence = 18, association = left;
terminal SqliteSr_t '>>' precedence = 18, association = left;
terminal SqliteAndBit_t '&' precedence = 18, association = left;
terminal SqliteOrBit_t '|' precedence = 18, association = left;
terminal SqlitePlus_t '+' precedence = 20, association = left;
terminal SqliteMinus_t '-' precedence = 20, association = left;
terminal SqliteTimes_t '*' precedence = 22, association = left;
terminal SqliteDiv_t '/' precedence = 22, association = left;
terminal SqliteMod_t '%' precedence = 22, association = left;
terminal SqliteConcat_t '||' precedence = 24, association = left;
terminal SqliteUnaryMinus_t '-' precedence = 26;
terminal SqliteUnaryPlus_t '+' precedence = 26;
terminal SqliteUnaryCollate_t '~' precedence = 26;
terminal SqliteNot_t 'NOT' precedence = 26, lexer classes {SqliteKeyword};

-- see https://www.sqlite.org/lang.html for grammar of SQLite queries
nonterminal SqliteQuery_c with location, ast<abs:SqliteQuery>;
concrete productions top::SqliteQuery_c
| s::SqliteSelectStmt_c
  {
    top.ast = s.ast;
  }

-- TODO: implement the full Select statement, this only supports Simple Select
nonterminal SqliteSelectStmt_c with location, ast<abs:SqliteQuery>, pp;
concrete productions top::SqliteSelectStmt_c
| w::SqliteOptWith_c s::SqliteSelectCore_c o::SqliteOptOrder_c l::SqliteOptLimit_c
  {
    top.pp = w.pp ++ s.pp ++ o.pp ++ l.pp;
    top.ast = abs:sqliteQuery(top.pp);
  }

nonterminal SqliteOptWith_c with location, pp;
concrete productions top::SqliteOptWith_c
| w::SqliteWith_c
  {
    top.pp = w.pp;
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteWith_c with location, pp;
concrete productions top::SqliteWith_c
| SqliteWith_t r::SqliteOptRecursive_c cs::SqliteCommonTableExprList_c
  {
    top.pp = "WITH " ++ r.pp ++ cs.pp;
  }

nonterminal SqliteOptRecursive_c with location, pp;
concrete productions top::SqliteOptRecursive_c
| SqliteRecursive_t
  {
    top.pp = "RECURSIVE ";
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteCommonTableExprList_c with location, pp;
concrete productions top::SqliteCommonTableExprList_c
| cs::SqliteCommonTableExprList_c ',' c::SqliteCommonTableExpr_c
  {
    top.pp = cs.pp ++ ", " ++ c.pp;
  }
| c::SqliteCommonTableExpr_c
  {
    top.pp = c.pp;
  }

nonterminal SqliteCommonTableExpr_c with location, pp;
concrete productions top::SqliteCommonTableExpr_c
| tableName::cnc:Identifier_t cs::SqliteOptColumnNameList_c SqliteAs_t '(' s::SqliteSelectStmt_c ')'
  {
    top.pp = tableName.lexeme ++ cs.pp ++ " AS (" ++ s.pp ++ ")";
  }

nonterminal SqliteSelectCore_c with location, pp;
synthesized attribute pp :: String;
concrete productions top::SqliteSelectCore_c
| s::SqliteSelect_c
  {
    top.pp = s.pp;
  }
| v::SqliteValues_c
  {
    top.pp = v.pp;
  }

nonterminal SqliteSelect_c with location, pp;
concrete productions top::SqliteSelect_c
| SqliteSelect_t d::SqliteOptDistinctOrAll_c rs::SqliteResultColumnList_c f::SqliteOptFrom_c
      w::SqliteOptWhere_c g::SqliteOptGroup_c
  {
    top.pp = "SELECT " ++ d.pp ++ rs.pp ++ f.pp ++ w.pp ++ g.pp;
  }

nonterminal SqliteOptDistinctOrAll_c with location, pp;
concrete productions top::SqliteOptDistinctOrAll_c
| SqliteDistinct_t
  {
    top.pp = "DISTINCT ";
  }
| SqliteAll_t
  {
    top.pp = "ALL ";
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteResultColumnList_c with location, pp;
concrete productions top::SqliteResultColumnList_c
| rs::SqliteResultColumnList_c ',' r::SqliteResultColumn_c
  {
    top.pp = rs.pp ++ ", " ++ r.pp;
  }
| r::SqliteResultColumn_c
  {
    top.pp = r.pp;
  }

nonterminal SqliteResultColumn_c with location, pp;
concrete productions top::SqliteResultColumn_c
| e::SqliteExpr_c c::SqliteOptAsColumnAlias_c
  {
    top.pp = e.pp ++ c.pp;
  }
| '*'
  {
    top.pp = "*";
  }
| tableName::cnc:Identifier_t '.' '*'
  {
    top.pp = tableName.lexeme ++ ".*";
  }

nonterminal SqliteOptAsColumnAlias_c with location, pp;
concrete productions top::SqliteOptAsColumnAlias_c
| a::SqliteAsColumnAlias_c
  {
    top.pp = a.pp;
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteAsColumnAlias_c with location, pp;
concrete productions top::SqliteAsColumnAlias_c
| SqliteOptAs_c columnAlias::cnc:Identifier_t
  {
    top.pp = " AS " ++ columnAlias.lexeme;
  }

nonterminal SqliteOptAs_c with location;
concrete productions top::SqliteOptAs_c
| SqliteAs_t
  {
  }
|
  {
  }

nonterminal SqliteOptFrom_c with location, pp;
concrete productions top::SqliteOptFrom_c
| f::SqliteFrom_c
  {
    top.pp = f.pp;
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteFrom_c with location, pp;
concrete productions top::SqliteFrom_c
| SqliteFrom_t t::SqliteTableOrSubqueryListOrJoin_c
  {
    top.pp = " FROM " ++ t.pp;
  }

nonterminal SqliteTableOrSubqueryListOrJoin_c with location, pp;
concrete productions top::SqliteTableOrSubqueryListOrJoin_c
-- This seems to be ambiguous with SqliteJoinClause_c?
--| SqliteTableOrSubqueryList_c
--  {
--  }
| j::SqliteJoinClause_c
  {
    top.pp = j.pp;
  }

--nonterminal SqliteTableOrSubqueryList_c with location;
--concrete productions top::SqliteTableOrSubqueryList_c
--| SqliteTableOrSubqueryList_c ',' SqliteTableOrSubquery_c
--  {
--  }
--| SqliteTableOrSubquery_c
--  {
--  }

-- TODO: complete
nonterminal SqliteTableOrSubquery_c with location, pp;
concrete productions top::SqliteTableOrSubquery_c
| tableName::cnc:Identifier_t
  {
    top.pp = tableName.lexeme;
  }

nonterminal SqliteJoinClause_c with location, pp;
concrete productions top::SqliteJoinClause_c
| t::SqliteTableOrSubquery_c j::SqliteOptJoinList_c
  {
    top.pp = t.pp ++ j.pp;
  }

nonterminal SqliteOptJoinList_c with location, pp;
concrete productions top::SqliteOptJoinList_c
| js::SqliteJoinList_c
  {
    top.pp = js.pp;
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteJoinList_c with location, pp;
concrete productions top::SqliteJoinList_c
| js::SqliteJoinList_c j::SqliteJoin_c
  {
    top.pp = js.pp ++ j.pp;
  }
| j::SqliteJoin_c
  {
    top.pp = j.pp;
  }

nonterminal SqliteJoin_c with location, pp;
concrete productions top::SqliteJoin_c
| o::SqliteJoinOperator_c t::SqliteTableOrSubquery_c c::SqliteJoinConstraint_c
  {
    top.pp = o.pp ++ t.pp ++ c.pp;
  }

nonterminal SqliteJoinOperator_c with location, pp;
concrete productions top::SqliteJoinOperator_c
| ','
  {
    top.pp = ", ";
  }
| n::SqliteOptNatural_c l::SqliteOptLeftOrInnerOrCross_c j::SqliteJoin_t
  {
    top.pp = n.pp ++ l.pp ++ " JOIN";
  }

nonterminal SqliteOptNatural_c with location, pp;
concrete productions top::SqliteOptNatural_c
| SqliteNatural_t
  {
    top.pp = " NATURAL";
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteOptLeftOrInnerOrCross_c with location, pp;
concrete productions top::SqliteOptLeftOrInnerOrCross_c
| SqliteLeft_t o::SqliteOptOuter_c
  {
    top.pp = " LEFT" ++ o.pp;
  }
| SqliteInner_t
  {
    top.pp = " INNER";
  }
| SqliteCross_t
  {
    top.pp = " CROSS";
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteOptOuter_c with location, pp;
concrete productions top::SqliteOptOuter_c
| SqliteOuter_t
  {
    top.pp = " OUTER";
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteJoinConstraint_c with location, pp;
concrete productions top::SqliteJoinConstraint_c
| SqliteOnConstraint_t e::SqliteExpr_c
  {
    top.pp = " ON " ++ e.pp;
  }
| SqliteUsing_t '(' cs::SqliteColumnNameList_c ')'
  {
    top.pp = "(" ++ cs.pp ++ ")";
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteOptWhere_c with location, pp;
concrete productions top::SqliteOptWhere_c
| w::SqliteWhere_c
  {
    top.pp = w.pp;
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteWhere_c with location, pp;
concrete productions top::SqliteWhere_c
| SqliteWhere_t e::SqliteExpr_c
  {
    top.pp = " WHERE " ++ e.pp;
  }

nonterminal SqliteOptGroup_c with location, pp;
concrete productions top::SqliteOptGroup_c
| g::SqliteGroup_c
  {
    top.pp = g.pp;
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteGroup_c with location, pp;
concrete productions top::SqliteGroup_c
| SqliteGroup_t SqliteBy_t es::SqliteExprList_c h::SqliteOptHaving_c
  {
    top.pp = "GROUP BY " ++ es.pp ++ h.pp;
  }

nonterminal SqliteOptHaving_c with location, pp;
concrete productions top::SqliteOptHaving_c
| h::SqliteHaving_c
  {
    top.pp = h.pp;
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteHaving_c with location, pp;
concrete productions top::SqliteHaving_c
| SqliteHaving_t e::SqliteExpr_c
  {
    top.pp = " HAVING " ++ e.pp;
  }

nonterminal SqliteValues_c with location, pp;
concrete productions top::SqliteValues_c
| SqliteValues_t es::SqliteExprListList_c
  {
    top.pp = "VALUES " ++ es.pp;
  }

nonterminal SqliteExprListList_c with location, pp;
concrete productions top::SqliteExprListList_c
| es::SqliteExprListList_c ',' '(' e::SqliteExprList_c ')'
  {
    top.pp = es.pp ++ ", (" ++ e.pp ++ ")";
  }
| '(' e::SqliteExprList_c ')'
  {
    top.pp = "(" ++ e.pp ++ ")";
  }

nonterminal SqliteExprList_c with location, pp;
concrete productions top::SqliteExprList_c
| es::SqliteExprList_c ',' e::SqliteExpr_c
  {
    top.pp = es.pp ++ ", " ++ e.pp;
  }
| e::SqliteExpr_c
  {
    top.pp = e.pp;
  }

-- TODO: fully implement expressions
nonterminal SqliteExpr_c with location, pp;
concrete productions top::SqliteExpr_c
| l::SqliteLiteralValue_c
  {
    top.pp = l.pp;
  }
--| SqliteBindParameter_c
--  {
--  }
| n::SqliteSchemaTableColumnName_c
  {
    top.pp = n.pp;
  }
| e1::SqliteExpr_c SqliteOr_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " OR " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteAnd_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " AND " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteEquals_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " = " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteEquals2_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " == " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteNotEqual_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " != " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteNotEqual2_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " <> " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteIs_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " IS " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteIn_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " IN " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteLike_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " LIKE " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteGlob_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " GLOB " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteMatch_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " MATCH " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteRegexp_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " REGEXP " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteLt_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " < " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteLe_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " <= " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteGt_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " > " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteGe_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " >= " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteSl_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " << " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteSr_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " >> " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteAndBit_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " & " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteOrBit_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " | " ++ e2.pp;
  }
| e1::SqliteExpr_c SqlitePlus_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " + " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteMinus_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " - " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteTimes_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " * " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteDiv_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " / " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteMod_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " % " ++ e2.pp;
  }
| e1::SqliteExpr_c SqliteConcat_t e2::SqliteExpr_c
  {
    top.pp = e1.pp ++ " || " ++ e2.pp;
  }
| SqliteUnaryMinus_t e::SqliteExpr_c
  {
    top.pp = "-" ++ e.pp;
  }
| SqliteUnaryPlus_t e::SqliteExpr_c
  {
    top.pp = "+" ++ e.pp;
  }
| SqliteUnaryCollate_t e::SqliteExpr_c
  {
    top.pp = "~" ++ e.pp;
  }
| SqliteNot_t e::SqliteExpr_c
  {
    top.pp = "NOT " ++ e.pp;
  }
| functionName::cnc:Identifier_t '(' a::SqliteOptFunctionArgs_c ')'
  {
    top.pp = functionName.lexeme ++ "(" ++ a.pp ++ ")";
  }
| '(' e::SqliteExpr_c ')'
  {
    top.pp = "(" ++ e.pp ++ ")";
  }
--| SqliteCast_t '(' SqliteExpr_c SqliteAs_t SqliteTypeName_c ')'
--  {
--  }
--| SqliteExpr_c SqliteCollate_t collationName::cnc:Identifier_t
--  {
--  }
--| SqliteExpr_c SqliteOptNot_c SqliteLikeGlobRegExpOrMatch_c SqliteExpr_c SqliteOptEscapedExpr_c
--  {
--  }
--| SqliteExpr_c SqliteIsOrNotNull_c
--  {
--  }
--| SqliteExpr_c SqliteOptNot_c SqliteBetween_t SqliteExpr_c SqliteAnd_t SqliteExpr_c
--  {
--  }
--| SqliteExpr_c SqliteOptNot_c SqliteIn_t SqliteSelectOrExprOrSchemaTableName_c
--  {
--  }
--| SqliteOptOptNotExists_c '(' SqliteSelectStmt_c ')'
--  {
--  }
--| SqliteCase_t SqliteOptExpr_c SqliteWhenThenList_c SqliteOptElseExpr_c SqliteEnd_t
--  {
--  }
--| SqliteRaiseFunction_c
--  {
--  }

nonterminal SqliteSchemaTableColumnName_c with location, pp;
concrete productions top::SqliteSchemaTableColumnName_c
| schemaName::cnc:Identifier_t '.' tableName::cnc:Identifier_t '.' columnName::cnc:Identifier_t
  {
    top.pp = schemaName.lexeme ++ "." ++ tableName.lexeme ++ "." ++ columnName.lexeme;
  }
| tableName::cnc:Identifier_t '.' columnName::cnc:Identifier_t
  {
    top.pp = tableName.lexeme ++ "." ++ columnName.lexeme;
  }
| columnName::cnc:Identifier_t
  {
    top.pp = columnName.lexeme;
  }

nonterminal SqliteLiteralValue_c with location, pp;
concrete productions top::SqliteLiteralValue_c
| l::SqliteNumericLiteral_c
  {
    top.pp = l.pp;
  }
| l::SqliteStringLiteral_t
  {
    top.pp = l.lexeme;
  }
| l::SqliteBlobLiteral_t
  {
    top.pp = l.lexeme;
  }
| SqliteNull_t
  {
    top.pp = "NULL";
  }
| SqliteCurrentTime_t
  {
    top.pp = "CURRENT_TIME";
  }
| SqliteCurrentDate_t
  {
    top.pp = "CURRENT_DATE";
  }
| SqliteCurrentTimestamp_t
  {
    top.pp = "CURRENT_TIMESTAMP";
  }

nonterminal SqliteNumericLiteral_c with location, pp;
concrete productions top::SqliteNumericLiteral_c
| l::SqliteDecimalLiteral_t
  {
    top.pp = l.lexeme;
  }
| l::SqliteHexLiteral_t
  {
    top.pp = l.lexeme;
  }

nonterminal SqliteOptFunctionArgs_c with location, pp;
concrete productions top::SqliteOptFunctionArgs_c
| d::SqliteOptDistinct_c es::SqliteExprList_c
  {
    top.pp = d.pp ++ es.pp;
  }
| '*'
  {
    top.pp = "*";
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteOptDistinct_c with location, pp;
concrete productions top::SqliteOptDistinct_c
| SqliteDistinct_t
  {
    top.pp = "DISTINCT ";
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteOptColumnNameList_c with location, pp;
concrete productions top::SqliteOptColumnNameList_c
| '(' cs::SqliteColumnNameList_c ')'
  {
    top.pp = "(" ++ cs.pp ++ ")";
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteColumnNameList_c with location, pp;
concrete productions top::SqliteColumnNameList_c
| cs::SqliteColumnNameList_c ',' c::cnc:Identifier_t
  {
    top.pp = cs.pp ++ ", " ++ c.lexeme;
  }
| c::cnc:Identifier_t
  {
    top.pp = c.lexeme;
  }

nonterminal SqliteOptOrder_c with location, pp;
concrete productions top::SqliteOptOrder_c
| o::SqliteOrder_c
  {
    top.pp = o.pp;
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteOrder_c with location, pp;
concrete productions top::SqliteOrder_c
| SqliteOrder_t SqliteBy_t os::SqliteOrderingTermList_c
  {
    top.pp = " ORDER BY " ++ os.pp;
  }

nonterminal SqliteOrderingTermList_c with location, pp;
concrete productions top::SqliteOrderingTermList_c
| os::SqliteOrderingTermList_c ',' o::SqliteOrderingTerm_c
  {
    top.pp = os.pp ++ ", " ++ o.pp;
  }
| o::SqliteOrderingTerm_c
  {
    top.pp = o.pp;
  }

nonterminal SqliteOrderingTerm_c with location, pp;
concrete productions top::SqliteOrderingTerm_c
| e::SqliteExpr_c c::SqliteOptCollate_c
  {
    top.pp = e.pp ++ c.pp;
  }

nonterminal SqliteOptCollate_c with location, pp;
concrete productions top::SqliteOptCollate_c
| c::SqliteCollate_c
  {
    top.pp = c.pp;
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteCollate_c with location, pp;
concrete productions top::SqliteCollate_c
| SqliteCollate_t collationName::cnc:Identifier_t a::SqliteOptAscOrDesc_c
  {
    top.pp = " COLLATE " ++ collationName.lexeme ++ a.pp;
  }

nonterminal SqliteOptAscOrDesc_c with location, pp;
concrete productions top::SqliteOptAscOrDesc_c
| a::SqliteAscOrDesc_c
  {
    top.pp = a.pp;
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteAscOrDesc_c with location, pp;
concrete productions top::SqliteAscOrDesc_c
| SqliteAsc_t
  {
    top.pp = " ASC";
  }
| SqliteDesc_t
  {
    top.pp = " DESC";
  }

nonterminal SqliteOptLimit_c with location, pp;
concrete productions top::SqliteOptLimit_c
| l::SqliteLimit_c
  {
    top.pp = l.pp;
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteLimit_c with location, pp;
concrete productions top::SqliteLimit_c
| SqliteLimit_t e::SqliteExpr_c o::SqliteOptOffsetExpr_c
  {
    top.pp = " LIMIT " ++ e.pp ++ o.pp;
  }

nonterminal SqliteOptOffsetExpr_c with location, pp;
concrete productions top::SqliteOptOffsetExpr_c
| o::SqliteOffsetExpr_c
  {
    top.pp = o.pp;
  }
|
  {
    top.pp = "";
  }

nonterminal SqliteOffsetExpr_c with location, pp;
concrete productions top::SqliteOffsetExpr_c
| o::SqliteOffsetOrComma_c e::SqliteExpr_c
  {
    top.pp = o.pp ++ e.pp;
  }

nonterminal SqliteOffsetOrComma_c with location, pp;
concrete productions top::SqliteOffsetOrComma_c
| SqliteOffset_t
  {
    top.pp = " OFFSET ";
  }
| ','
  {
    top.pp = ", ";
  }

