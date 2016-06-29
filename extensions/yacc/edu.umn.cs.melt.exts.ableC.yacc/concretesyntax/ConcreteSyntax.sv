grammar edu:umn:cs:melt:exts:ableC:yacc:concretesyntax;

imports edu:umn:cs:melt:ableC:concretesyntax as cnc;

imports edu:umn:cs:melt:exts:ableC:yacc:abstractsyntax as abs;

import silver:langutil;

marking terminal YaccGrammar_t '%%' lexer classes {Ckeyword};
marking terminal YaccToken_t '%token' lexer classes {Ckeyword};
marking terminal YaccStart_t '%start' lexer classes {Ckeyword};
marking terminal YaccLeft_t '%left' lexer classes {Ckeyword};

concrete production yaccGrammar_c
top::cnc:Declaration_c ::= YaccDeclList_c YaccGrammar_t p::YaccProductionList_c YaccGrammar_t
{
  top.ast = abs:yaccGrammar(p.ast);
}

nonterminal YaccDeclList_c with ast<abs:YaccDeclList>, location;

concrete productions top::YaccDeclList_c
| ps::YaccDeclList_c p::YaccDecl_c
    {
      top.ast = abs:yaccDeclList(p.ast, ps.ast);
    }
|
    {
      top.ast = abs:yaccNilDeclList();
    }

nonterminal YaccDecl_c with ast<abs:YaccDecl>, location;

concrete productions top::YaccDecl_c
| YaccToken_t cnc:Identifier_t
  {
    top.ast = abs:yaccDecl();
  }
| YaccStart_t cnc:Identifier_t
  {
    top.ast = abs:yaccDecl();
  }
| YaccLeft_t YaccIdentifierList_c
  {
    top.ast = abs:yaccDecl();
  }

nonterminal YaccIdentifierList_c with ast<abs:YaccNameList>, location;

concrete productions top::YaccIdentifierList_c
| is::YaccIdentifierList_c i::cnc:Identifier_t
  {
    top.ast = abs:yaccNameList(abs:fromId(i), is.ast);
  }
| i::cnc:Identifier_t
  {
    top.ast = abs:yaccNameList(abs:fromId(i), abs:yaccNilNameList());
  }

nonterminal YaccProductionList_c with ast<abs:YaccProductionList>, location;

concrete productions top::YaccProductionList_c
| ps::YaccProductionList_c p::YaccProduction_c
    {
      top.ast = abs:yaccProductionList(p.ast, ps.ast);
    }
|
    {
      top.ast = abs:yaccNilProductionList();
    }

nonterminal YaccProduction_c with ast<abs:YaccProduction>, location;

concrete production yaccProduction_c
top::YaccProduction_c ::= cnc:Identifier_t ':' YaccProductionAlternativeList_c ';'
{
  top.ast = abs:yaccProduction();
}

nonterminal YaccProductionAlternativeList_c with ast<abs:YaccProductionAlternativeList>, location;

concrete productions top::YaccProductionAlternativeList_c
| pas::YaccProductionAlternativeList_c '|' pa::YaccProductionAlternative_c
    {
      top.ast = abs:yaccProductionAlternativeList(pa.ast, pas.ast);
    }
| YaccProductionAlternative_c
    {
      top.ast = abs:yaccNilProductionAlternativeList();
    }

nonterminal YaccProductionAlternative_c with ast<abs:YaccProductionAlternative>, location;

concrete production yaccProductionAlternative_c
top::YaccProductionAlternative_c ::= YaccSymbolOrActionList_c
{
  top.ast = abs:yaccProductionAlternative();
}

nonterminal YaccSymbolOrActionList_c with ast<abs:YaccSymbolOrActionList>, location;

concrete productions top::YaccSymbolOrActionList_c
| sas::YaccSymbolOrActionList_c sa::YaccSymbolOrAction_c
    {
      top.ast = abs:yaccSymbolOrActionList();
    }
|
    {
      top.ast = abs:yaccNilSymbolOrActionList();
    }

nonterminal YaccSymbolOrAction_c with ast<abs:YaccSymbolOrAction>, location;
concrete productions top::YaccSymbolOrAction_c
| cnc:Identifier_t
    {
      top.ast = abs:yaccSymbol();
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
    top.ast = abs:yaccNilSemanticAction();
  }


----marking terminal YaccDefinition_t '%';
--marking terminal YaccDefinition_t 'EXPR' lexer classes {Ckeyword};
--
----terminal YaccToken 'union';
----terminal YaccToken 'token';
----terminal YaccStart 'start';
----terminal YaccLeft  'left';
----terminal YaccRight 'right';
----terminal YaccType  'type';
--
----concrete productions top::Expr_c
------| YaccDefinition_t s::PrimaryExpr_c
----| 'EXPR' s::Expr_c
----    { top.ast = s.ast; }
--
--nonterminal YaccDefinition_c with ast<ast:Expr>;
--
--concrete production yaccDefinition_c
--top::YaccDefinition_c ::= YaccDefinition_t s::Expr_c
----top::cnc:Stmt_c ::= YaccDefinition_t s::Stmt_c
--{
----  top = yaccDefinition(e)
--  top.ast = s.ast
--}

--marking terminal MyExpr_t 'EXPR' lexer classes {Ckeyword};
--
--concrete production myExpr_c
--top::cnc:Expr_c ::= MyExpr_t e::cnc:Expr_c
--{
--  top = MyExpr(e);
--}
--
