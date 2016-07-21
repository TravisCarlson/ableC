grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax;

imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
import silver:langutil;

marking terminal SqliteOn_t 'on' lexer classes {Ckeyword};

terminal SqliteQuery_t 'query';

concrete production sqliteQueryDb_c
top::cnc:PrimaryExpr_c ::= SqliteOn_t db::cnc:Identifier_t SqliteQuery_t '{' query::SqliteQuery_c '}'
{
  top.ast = abs:sqliteQueryExpr(abs:fromId(db), query.ast, location=top.location);
}

nonterminal SqliteQuery_c with location, ast<String>;

concrete productions top::SqliteQuery_c
| s::cnc:StringConstant_c
  {
    top.ast = s.ast;
  }

