grammar edu:umn:cs:melt:exts:ableC:yacc:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;

abstract production yaccGrammar
top::abs:Decl ::= YaccProductionList
{
  forwards to abs:decls(abs:nilDecl());
}

nonterminal YaccDeclList with decls;
synthesized attribute decls :: [YaccDecl];

abstract production yaccDeclList
top::YaccDeclList ::= p::YaccDecl ps::YaccDeclList
{
  top.decls = cons(p, ps.decls);
}

abstract production yaccNilDeclList
top::YaccDeclList ::=
{
  top.decls = nil();
}

nonterminal YaccDecl;

abstract production yaccDecl
top::YaccDecl ::=
{
}

nonterminal YaccNameList with names;
synthesized attribute names :: [abs:Name];

abstract production yaccNameList
top::YaccNameList ::= n::abs:Name ns::YaccNameList
{
  top.names = cons(n, ns.names);
}

abstract production yaccNilNameList
top::YaccNameList ::=
{
  top.names = nil();
}

function fromId
abs:Name ::= n::cnc:Identifier_t
{
  return abs:name(n.lexeme, location=n.location);
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

nonterminal YaccProductionAlternativeList with prodAlts;
synthesized attribute prodAlts :: [YaccProductionAlternative];

abstract production yaccProductionAlternativeList
top::YaccProductionAlternativeList ::= pa::YaccProductionAlternative pas::YaccProductionAlternativeList
{
  top.prodAlts = cons(pa, pas.prodAlts);
}

abstract production yaccNilProductionAlternativeList
top::YaccProductionAlternativeList ::=
{
  top.prodAlts = nil();
}

nonterminal YaccProductionAlternative;

abstract production yaccProductionAlternative
top::YaccProductionAlternative ::=
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
