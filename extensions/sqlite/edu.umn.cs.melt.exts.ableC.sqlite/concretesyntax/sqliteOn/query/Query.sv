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
nonterminal SqliteSelectStmt_c with location, ast<abs:SqliteQuery>;
concrete productions top::SqliteSelectStmt_c
| w::SqliteOptWith_c s::SqliteSelectCore_c o::SqliteOptOrder_c l::SqliteOptLimit_c
  {
    top.ast = abs:sqliteQuery();
  }

nonterminal SqliteOptWith_c with location;
concrete productions top::SqliteOptWith_c
| SqliteWith_c
  {
  }
|
  {
  }

nonterminal SqliteWith_c with location;
concrete productions top::SqliteWith_c
| SqliteWith_t SqliteOptRecursive_c SqliteCommonTableExprList_c
  {
  }

nonterminal SqliteOptRecursive_c with location;
concrete productions top::SqliteOptRecursive_c
| SqliteRecursive_t
  {
  }
|
  {
  }

nonterminal SqliteCommonTableExprList_c with location;
concrete productions top::SqliteCommonTableExprList_c
| cs::SqliteCommonTableExprList_c ',' c::SqliteCommonTableExpr_c
  {
  }
| c::SqliteCommonTableExpr_c
  {
  }

nonterminal SqliteCommonTableExpr_c with location;
concrete productions top::SqliteCommonTableExpr_c
| tableName::cnc:Identifier_t SqliteOptColumnNameList_c SqliteAs_t '(' SqliteSelectStmt_c ')'
  {
  }

nonterminal SqliteSelectCore_c with location;
concrete productions top::SqliteSelectCore_c
| SqliteSelect_c
  {
  }
| SqliteValues_c
  {
  }

nonterminal SqliteSelect_c with location;
concrete productions top::SqliteSelect_c
| SqliteSelect_t SqliteOptDistinctOrAll_c SqliteResultColumnList_c SqliteOptFrom_c
      SqliteOptWhere_c SqliteOptGroup_c
  {
  }

nonterminal SqliteOptDistinctOrAll_c with location;
concrete productions top::SqliteOptDistinctOrAll_c
| SqliteDistinct_t
  {
  }
| SqliteAll_t
  {
  }
|
  {
  }

nonterminal SqliteResultColumnList_c with location;
concrete productions top::SqliteResultColumnList_c
| rs::SqliteResultColumnList_c ',' r::SqliteResultColumn_c
  {
  }
| r::SqliteResultColumn_c
  {
  }

nonterminal SqliteResultColumn_c with location;
concrete productions top::SqliteResultColumn_c
| SqliteExpr_c SqliteOptAsColumnAlias_c
  {
  }
| '*'
  {
  }
| tableName::cnc:Identifier_t '.' '*'
  {
  }

nonterminal SqliteOptAsColumnAlias_c with location;
concrete productions top::SqliteOptAsColumnAlias_c
| SqliteAsColumnAlias_c
  {
  }
|
  {
  }

nonterminal SqliteAsColumnAlias_c with location;
concrete productions top::SqliteAsColumnAlias_c
| SqliteOptAs_c columnAlias::cnc:Identifier_t
  {
  }

nonterminal SqliteOptAs_c with location;
concrete productions top::SqliteOptAs_c
| SqliteAs_t
  {
  }
|
  {
  }

nonterminal SqliteOptFrom_c with location;
concrete productions top::SqliteOptFrom_c
| SqliteFrom_c
  {
  }
|
  {
  }

nonterminal SqliteFrom_c with location;
concrete productions top::SqliteFrom_c
| SqliteFrom_t SqliteTableOrSubqueryListOrJoin_c
  {
  }

nonterminal SqliteTableOrSubqueryListOrJoin_c with location;
concrete productions top::SqliteTableOrSubqueryListOrJoin_c
-- This seems to be ambiguous with SqliteJoinClause_c?
--| SqliteTableOrSubqueryList_c
--  {
--  }
| SqliteJoinClause_c
  {
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
nonterminal SqliteTableOrSubquery_c with location;
concrete productions top::SqliteTableOrSubquery_c
| tableName::cnc:Identifier_t
  {
  }

nonterminal SqliteJoinClause_c with location;
concrete productions top::SqliteJoinClause_c
| SqliteTableOrSubquery_c SqliteOptJoinList_c
  {
  }

nonterminal SqliteOptJoinList_c with location;
concrete productions top::SqliteOptJoinList_c
| SqliteJoinList_c
  {
  }
|
  {
  }

nonterminal SqliteJoinList_c with location;
concrete productions top::SqliteJoinList_c
| es::SqliteJoinList_c e::SqliteJoin_c
  {
  }
| e::SqliteJoin_c
  {
  }

nonterminal SqliteJoin_c with location;
concrete productions top::SqliteJoin_c
| SqliteJoinOperator_c SqliteTableOrSubquery_c SqliteJoinConstraint_c
  {
  }

nonterminal SqliteJoinOperator_c with location;
concrete productions top::SqliteJoinOperator_c
| ','
  {
  }
| SqliteOptNatural_c SqliteOptLeftOrInnerOrCross_c SqliteJoin_t
  {
  }

nonterminal SqliteOptNatural_c with location;
concrete productions top::SqliteOptNatural_c
| SqliteNatural_t
  {
  }
|
  {
  }

nonterminal SqliteOptLeftOrInnerOrCross_c with location;
concrete productions top::SqliteOptLeftOrInnerOrCross_c
| SqliteLeft_t SqliteOptOuter_c
  {
  }
| SqliteInner_t
  {
  }
| SqliteCross_t
  {
  }
|
  {
  }

nonterminal SqliteOptOuter_c with location;
concrete productions top::SqliteOptOuter_c
| SqliteOuter_t
  {
  }
|
  {
  }

nonterminal SqliteJoinConstraint_c with location;
concrete productions top::SqliteJoinConstraint_c
| SqliteOnConstraint_t SqliteExpr_c
  {
  }
| SqliteUsing_t '(' SqliteColumnNameList_c ')'
  {
  }
|
  {
  }

nonterminal SqliteOptWhere_c with location;
concrete productions top::SqliteOptWhere_c
| SqliteWhere_c
  {
  }
|
  {
  }

nonterminal SqliteWhere_c with location;
concrete productions top::SqliteWhere_c
| SqliteWhere_t SqliteExpr_c
  {
  }

nonterminal SqliteOptGroup_c with location;
concrete productions top::SqliteOptGroup_c
| SqliteGroup_c
  {
  }
|
  {
  }

nonterminal SqliteGroup_c with location;
concrete productions top::SqliteGroup_c
| SqliteGroup_t SqliteBy_t SqliteExprList_c SqliteOptHaving_c
  {
  }

nonterminal SqliteOptHaving_c with location;
concrete productions top::SqliteOptHaving_c
| SqliteHaving_c
  {
  }
|
  {
  }

nonterminal SqliteHaving_c with location;
concrete productions top::SqliteHaving_c
| SqliteHaving_t SqliteExpr_c
  {
  }

nonterminal SqliteValues_c with location;
concrete productions top::SqliteValues_c
| SqliteValues_t SqliteExprListList_c
  {
  }

nonterminal SqliteExprListList_c with location;
concrete productions top::SqliteExprListList_c
| es::SqliteExprListList_c ',' '(' e::SqliteExprList_c ')'
  {
  }
| '(' e::SqliteExprList_c ')'
  {
  }

nonterminal SqliteExprList_c with location;
concrete productions top::SqliteExprList_c
| es::SqliteExprList_c ',' e::SqliteExpr_c
  {
  }
| e::SqliteExpr_c
  {
  }

-- TODO: fully implement expressions
nonterminal SqliteExpr_c with location;
concrete productions top::SqliteExpr_c
| SqliteLiteralValue_c
  {
  }
--| SqliteBindParameter_c
--  {
--  }
| SqliteSchemaTableColumnName_c
  {
  }
| SqliteExpr_c SqliteOr_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteAnd_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteEquals_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteEquals2_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteNotEqual_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteNotEqual2_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteIs_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteIn_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteLike_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteGlob_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteMatch_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteRegexp_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteLt_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteLe_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteGt_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteGe_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteSl_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteSr_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteAndBit_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteOrBit_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqlitePlus_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteMinus_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteTimes_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteDiv_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteMod_t SqliteExpr_c
  {
  }
| SqliteExpr_c SqliteConcat_t SqliteExpr_c
  {
  }
| SqliteUnaryMinus_t SqliteExpr_c
  {
  }
| SqliteUnaryPlus_t SqliteExpr_c
  {
  }
| SqliteUnaryCollate_t SqliteExpr_c
  {
  }
| SqliteNot_t SqliteExpr_c
  {
  }
| functionName::cnc:Identifier_t '(' SqliteOptFunctionArgs_c ')'
  {
  }
| '(' SqliteExpr_c ')'
  {
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

nonterminal SqliteSchemaTableColumnName_c with location;
concrete productions top::SqliteSchemaTableColumnName_c
| schemaName::cnc:Identifier_t '.' tableName::cnc:Identifier_t '.' columnName::cnc:Identifier_t
  {
  }
| tableName::cnc:Identifier_t '.' columnName::cnc:Identifier_t
  {
  }
| columnName::cnc:Identifier_t
  {
  }

nonterminal SqliteLiteralValue_c with location;
concrete productions top::SqliteLiteralValue_c
| SqliteNumericLiteral_c
  {
  }
| SqliteStringLiteral_t
  {
  }
| SqliteBlobLiteral_t
  {
  }
| SqliteNull_t
  {
  }
| SqliteCurrentTime_t
  {
  }
| SqliteCurrentDate_t
  {
  }
| SqliteCurrentTimestamp_t
  {
  }

nonterminal SqliteNumericLiteral_c with location;
concrete productions top::SqliteNumericLiteral_c
| SqliteDecimalLiteral_t
  {
  }
| SqliteHexLiteral_t
  {
  }

nonterminal SqliteOptFunctionArgs_c with location;
concrete productions top::SqliteOptFunctionArgs_c
| SqliteOptDistinct_c SqliteExprList_c
  {
  }
| '*'
  {
  }
|
  {
  }

nonterminal SqliteOptNot_c with location;
concrete productions top::SqliteOptNot_c
| SqliteNot_t
  {
  }
|
  {
  }

nonterminal SqliteOptDistinct_c with location;
concrete productions top::SqliteOptDistinct_c
| SqliteDistinct_t
  {
  }
|
  {
  }

nonterminal SqliteOptColumnNameList_c with location;
concrete productions top::SqliteOptColumnNameList_c
| '(' SqliteColumnNameList_c ')'
  {
  }
|
  {
  }

nonterminal SqliteColumnNameList_c with location;
concrete productions top::SqliteColumnNameList_c
| cs::SqliteColumnNameList_c ',' c::cnc:Identifier_t
  {
  }
| c::cnc:Identifier_t
  {
  }

nonterminal SqliteOptOrder_c with location;
concrete productions top::SqliteOptOrder_c
| SqliteOrder_c
  {
  }
|
  {
  }

nonterminal SqliteOrder_c with location;
concrete productions top::SqliteOrder_c
| SqliteOrder_t SqliteBy_t SqliteOrderingTermList_c
  {
  }

nonterminal SqliteOrderingTermList_c with location;
concrete productions top::SqliteOrderingTermList_c
| os::SqliteOrderingTermList_c ',' o::SqliteOrderingTerm_c
  {
  }
| o::SqliteOrderingTerm_c
  {
  }

nonterminal SqliteOrderingTerm_c with location;
concrete productions top::SqliteOrderingTerm_c
| SqliteExpr_c SqliteOptCollate_c
  {
  }

nonterminal SqliteOptCollate_c with location;
concrete productions top::SqliteOptCollate_c
| SqliteCollate_c
  {
  }
|
  {
  }

nonterminal SqliteCollate_c with location;
concrete productions top::SqliteCollate_c
| SqliteCollate_t collationName::cnc:Identifier_t SqliteOptAscOrDesc_c
  {
  }

nonterminal SqliteOptAscOrDesc_c with location;
concrete productions top::SqliteOptAscOrDesc_c
| SqliteAscOrDesc_c
  {
  }
|
  {
  }

nonterminal SqliteAscOrDesc_c with location;
concrete productions top::SqliteAscOrDesc_c
| SqliteAsc_t
  {
  }
| SqliteDesc_t
  {
  }

nonterminal SqliteOptLimit_c with location;
concrete productions top::SqliteOptLimit_c
| SqliteLimit_c
  {
  }
|
  {
  }

nonterminal SqliteLimit_c with location;
concrete productions top::SqliteLimit_c
| SqliteLimit_t SqliteExpr_c SqliteOptOffsetExpr_c
  {
  }

nonterminal SqliteOptOffsetExpr_c with location;
concrete productions top::SqliteOptOffsetExpr_c
| SqliteOffsetExpr_c
  {
  }
|
  {
  }

nonterminal SqliteOffsetExpr_c with location;
concrete productions top::SqliteOffsetExpr_c
| SqliteOffsetOrComma_c SqliteExpr_c
  {
  }

nonterminal SqliteOffsetOrComma_c with location;
concrete productions top::SqliteOffsetOrComma_c
| SqliteOffset_t
  {
  }
| ','
  {
  }

