grammar edu:umn:cs:melt:exts:ableC:yacc:concretesyntax;

imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:ableC:abstractsyntax as ableCabs;
imports edu:umn:cs:melt:exts:ableC:yacc:abstractsyntax as abs;
import silver:langutil;

marking terminal YaccGrammar_t '%%' lexer classes {Ckeyword};
marking terminal YaccToken_t '%token' lexer classes {Ckeyword};
marking terminal YaccStart_t '%start' lexer classes {Ckeyword};
marking terminal YaccLeft_t '%left' lexer classes {Ckeyword};

concrete production yaccGrammar_c
top::cnc:Stmt_c ::= YaccDeclList_c '%%' p::YaccProductionList_c '%%'
{
  top.ast = abs:yaccGrammar(p.ast);
}

nonterminal YaccDeclList_c with ast<abs:YaccDeclList>, location;
concrete productions top::YaccDeclList_c
| ps::YaccDeclList_c p::YaccDecl_c
    {
      top.ast = abs:yaccConsDecl(p.ast, ps.ast);
    }
|
    {
      top.ast = abs:yaccNilDecl();
    }

nonterminal YaccDecl_c with ast<abs:YaccDecl>, location;
concrete productions top::YaccDecl_c
| '%token' n::cnc:Identifier_t
  {
    top.ast = abs:yaccTokenDecl(abs:fromId(n));
  }
| '%start' n::cnc:Identifier_t
  {
    top.ast = abs:yaccStartDecl(abs:fromId(n));
  }
| '%left' ns::YaccIdentifierList_c
  {
    top.ast = abs:yaccLeftDecl(ns.ast);
  }

nonterminal YaccIdentifierList_c with ast<abs:YaccNameList>, location;
concrete productions top::YaccIdentifierList_c
| is::YaccIdentifierList_c i::cnc:Identifier_t
  {
    top.ast = abs:yaccConsName(abs:fromId(i), is.ast);
  }
| i::cnc:Identifier_t
  {
    top.ast = abs:yaccConsName(abs:fromId(i), abs:yaccNilName());
  }

nonterminal YaccProductionList_c with ast<abs:YaccProductionList>, location;
concrete productions top::YaccProductionList_c
| ps::YaccProductionList_c p::YaccProduction_c
    {
      top.ast = abs:yaccConsProduction(p.ast, ps.ast);
    }
|
    {
      top.ast = abs:yaccNilProduction();
    }

nonterminal YaccProduction_c with ast<abs:YaccProduction>, location;
concrete production yaccProduction_c
top::YaccProduction_c ::= leftNt::cnc:Identifier_t ':' pas::YaccProductionAlternativeList_c ';'
{
  top.ast = abs:yaccProduction(abs:fromId(leftNt), pas.ast);
}

nonterminal YaccProductionAlternativeList_c with ast<abs:YaccProductionAlternativeList>, location;
concrete productions top::YaccProductionAlternativeList_c
| pas::YaccProductionAlternativeList_c '|' pa::YaccProductionAlternative_c
    {
      top.ast = abs:yaccConsProductionAlternative(pa.ast, pas.ast);
    }
| YaccProductionAlternative_c
    {
      top.ast = abs:yaccNilProductionAlternative();
    }

nonterminal YaccProductionAlternative_c with ast<abs:YaccProductionAlternative>, location;

concrete production yaccProductionAlternative_c
top::YaccProductionAlternative_c ::= s::YaccSymbolOrActionList_c
{
  top.ast = abs:yaccProductionAlternative(s.ast);
}

nonterminal YaccSymbolOrActionList_c with ast<abs:YaccSymbolOrActionList>, location;

concrete productions top::YaccSymbolOrActionList_c
| sas::YaccSymbolOrActionList_c sa::YaccSymbolOrAction_c
    {
      top.ast = abs:yaccConsSymbolOrAction(sa.ast, sas.ast);
    }
|
    {
      top.ast = abs:yaccNilSymbolOrAction();
    }

nonterminal YaccSymbolOrAction_c with ast<abs:YaccSymbolOrAction>, location;
concrete productions top::YaccSymbolOrAction_c
| s::cnc:Identifier_t
    {
      top.ast = abs:yaccSymbol(abs:fromId(s));
    }
| '{' sa::YaccSemanticAction_c '}'
    {
      top.ast = sa.ast;
    }

nonterminal YaccSemanticAction_c with ast<abs:YaccSymbolOrAction>, location;
concrete productions top::YaccSemanticAction_c
| s::cnc:Stmt_c
  {
    top.ast = abs:yaccSemanticAction(s.ast);
  }
|
  {
    top.ast = abs:yaccSemanticAction(ableCabs:nullStmt());
  }

