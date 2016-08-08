grammar edu:umn:cs:melt:exts:ableC:yacc:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;

abstract production yaccGrammar
top::abs:Stmt ::= YaccProductionList
{
  forwards to abs:nullStmt();
}

nonterminal YaccDeclList with decls;
synthesized attribute decls :: [YaccDecl];
abstract production yaccConsDecl
top::YaccDeclList ::= p::YaccDecl ps::YaccDeclList
{
  top.decls = cons(p, ps.decls);
}
abstract production yaccNilDecl
top::YaccDeclList ::=
{
  top.decls = nil();
}

nonterminal YaccDecl;
abstract production yaccTokenDecl
top::YaccDecl ::= n::abs:Name
{
}
abstract production yaccStartDecl
top::YaccDecl ::= n::abs:Name
{
}
abstract production yaccLeftDecl
top::YaccDecl ::= ns::YaccNameList
{
}

nonterminal YaccNameList with names;
synthesized attribute names :: [abs:Name];
abstract production yaccConsName
top::YaccNameList ::= n::abs:Name ns::YaccNameList
{
  top.names = cons(n, ns.names);
}
abstract production yaccNilName
top::YaccNameList ::=
{
  top.names = nil();
}

nonterminal YaccProductionList with prods;
synthesized attribute prods :: [YaccProduction];
abstract production yaccConsProduction
top::YaccProductionList ::= p::YaccProduction ps::YaccProductionList
{
  top.prods = cons(p, ps.prods);
}
abstract production yaccNilProduction
top::YaccProductionList ::=
{
  top.prods = nil();
}

nonterminal YaccProduction with leftNt, prodAlts;
synthesized attribute leftNt :: abs:Name;
synthesized attribute prodAlts :: [YaccProductionAlternative];
abstract production yaccProduction
top::YaccProduction ::= leftNt::abs:Name pas::YaccProductionAlternativeList
{
  top.leftNt = leftNt;
  top.prodAlts = pas.prodAlts;
}

nonterminal YaccProductionAlternativeList with prodAlts;
abstract production yaccConsProductionAlternative
top::YaccProductionAlternativeList ::= pa::YaccProductionAlternative pas::YaccProductionAlternativeList
{
  top.prodAlts = cons(pa, pas.prodAlts);
}

abstract production yaccNilProductionAlternative
top::YaccProductionAlternativeList ::=
{
  top.prodAlts = nil();
}

nonterminal YaccProductionAlternative with symOrActs;
synthesized attribute symOrActs :: [YaccSymbolOrAction];
abstract production yaccProductionAlternative
top::YaccProductionAlternative ::= s::YaccSymbolOrActionList
{
  top.symOrActs = s.symOrActs;
}

nonterminal YaccSymbolOrActionList with symOrActs;
abstract production yaccConsSymbolOrAction
top::YaccSymbolOrActionList ::= sa::YaccSymbolOrAction sas::YaccSymbolOrActionList
{
  top.symOrActs = cons(sa, sas.symOrActs);
}
abstract production yaccNilSymbolOrAction
top::YaccSymbolOrActionList ::=
{
  top.symOrActs = nil();
}

nonterminal YaccSymbolOrAction;
abstract production yaccSymbol
top::YaccSymbolOrAction ::= n::abs:Name
{
}
abstract production yaccSemanticAction
top::YaccSymbolOrAction ::= s::abs:Stmt
{
}

function fromId
abs:Name ::= n::cnc:Identifier_t
{
  return abs:name(n.lexeme, location=n.location);
}

