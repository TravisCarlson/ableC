grammar edu:umn:cs:melt:exts:ableC:yacc:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax as abs;

abstract production yaccGrammar
top::abs:Decl ::= YaccProductionList
{
  forwards to abs:decls(abs:nilDecl());
}

nonterminal YaccProductionList;

abstract production yaccProductionList
top::YaccProductionList ::= p::YaccProduction ps::YaccProductionList
{
}

abstract production yaccNilProductionList
top::YaccProductionList ::=
{
}

nonterminal YaccProduction;

abstract production yaccProduction
top::YaccProduction ::=
{
}

--abstract production yaccDefinitionSection
--top::abs:Expr ::= l1::String
--{
----  forwards to Expr(l1);
--}

--abstract production yaccDefinition
--top::abs:expr ::= e::expr
--{
--  forwards to expr(e);
--}

--abstract production myExpr
--top::abs:Expr ::= e::abs:expr
--{
--  forwards to expr(e);
--}
--
