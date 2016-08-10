grammar edu:umn:cs:melt:exts:ableC:yacc:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
import silver:langutil;

abstract production yaccGrammar
top::abs:Decl ::= ds::YaccDeclList ps::YaccProductionList
{
  forwards to
    abs:decls(abs:nilDecl());
--    abs:warnDecl([wrn(builtIn(), mkCopperSpec(ds, ps))]);
}

nonterminal YaccDeclList with decls;
synthesized attribute decls :: [YaccDecl];
abstract production yaccConsDecl
top::YaccDeclList ::= d::YaccDecl ds::YaccDeclList
{
  top.decls = cons(d, ds.decls);
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

abstract production builtIn
top::Location ::=
{
  forwards to loc("Built In", 0, 0, 0, 0, 0, 0);
}

function mkCopperSpec
String ::= ds::YaccDeclList ps::YaccProductionList
{
  return
s"""
<?xml version="1.0" encoding=UTF-8"?>
<CopperSpec xmlns="http://melt.cs.umn.edu/copper/xmlns">
  <Parser id="YaccGenGrammarParser" isUnitary="true">
    <Grammars><GrammarRef id="YaccGenGrammar"/></Grammars>
    <StartSymbol><NonterminalRef id="Root" grammar="YaccGenGrammar" /></StartSymbol>
    <Package>ableC</Package>
    <ClassName>YaccGenGrammarParser</ClassName>
    <PostParseCode>
      <Code><![CDATA[ System.out.println(root); ]]></Code>
    </PostParseCode>
  </Parser>
</CopperSpec>
""";
}

