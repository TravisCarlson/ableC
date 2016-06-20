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

nonterminal YaccSymbolList with ids;
synthesized attribute ids :: [cnc:Identifier_t];

abstract production yaccSymbolList
top::YaccSymbolList ::= id::cnc:Identifier_t ids::YaccSymbolList
{
  top.ids = cons(id, ids.ids);
}

abstract production yaccNilSymbolList
top::YaccSymbolList ::=
{
  top.ids = nil();
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
