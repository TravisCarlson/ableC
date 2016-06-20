grammar edu:umn:cs:melt:exts:ableC:yacc:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;

abstract production yaccGrammar
top::abs:Decl ::= YaccProductionList
{
  forwards to abs:decls(abs:nilDecl());
}

nonterminal YaccProductionList with prods;
synthesized attribute prods :: [YaccProduction];

abstract production yaccProductionList
top::YaccProductionList ::= p::YaccProduction ps::YaccProductionList
{
  top.prods = cons(p, ps.prods);
}

abstract production yaccNilProductionList
top::YaccProductionList ::=
{
  top.prods = nil();
}

nonterminal YaccProduction;

abstract production yaccProduction
top::YaccProduction ::=
{
}

nonterminal YaccSymbolOrActionList;

abstract production yaccSymbolOrActionList
top::YaccSymbolOrActionList ::=
{
}

abstract production yaccNilSymbolOrActionList
top::YaccSymbolOrActionList ::=
{
}

nonterminal YaccSymbolOrAction;

abstract production yaccSymbol
top::YaccSymbolOrAction ::=
{
}

abstract production yaccSemanticAction
top::YaccSymbolOrAction ::= s::abs:Stmt
{
}

abstract production yaccNilSemanticAction
top::YaccSymbolOrAction ::=
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
