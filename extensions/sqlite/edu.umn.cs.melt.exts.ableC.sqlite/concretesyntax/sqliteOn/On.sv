grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:sqliteOn;

imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
import silver:langutil;
import edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:sqliteOn:query;

marking terminal SqliteOn_t 'on' lexer classes {Ckeyword};

terminal SqliteExit_t 'exit';
terminal SqliteQuery_t 'query';
terminal SqliteAs_t 'as';

concrete production sqliteExit_c
top::cnc:PrimaryExpr_c ::= 'on' db::cnc:Expr_c 'exit'
{
  top.ast = abs:sqliteExit(db.ast, location=top.location);
}

concrete production sqliteQueryDb_c
top::cnc:Stmt_c ::= 'on' db::cnc:Expr_c 'query' '{' query::SqliteQuery_c
                            '}' 'as' queryName::cnc:Identifier_t
{
  top.ast = abs:sqliteQueryDb(db.ast, query.ast, abs:fromId(queryName));
}

