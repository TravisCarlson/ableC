grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:sqliteOn;

imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
import silver:langutil;
import edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:sqliteOn:query;

marking terminal SqliteOn_t 'on' lexer classes {Ckeyword};

terminal SqliteExit_t 'exit';
terminal SqliteFor_t 'for';
terminal SqliteQuery_t 'query';

concrete production sqliteExit_c
top::cnc:PrimaryExpr_c ::= SqliteOn_t db::cnc:Expr_c SqliteExit_t
{
  top.ast = abs:sqliteExit(db.ast, location=top.location);
}

concrete production sqliteForeach_c
top::cnc:Stmt_c ::= SqliteOn_t db::cnc:Expr_c SqliteFor_t '(' row::cnc:Identifier_t ':'
                           stmt::cnc:Expr_c ')' '{' body::cnc:Stmt_c '}'
{
  top.ast = abs:sqliteForeach(abs:fromId(row), stmt.ast, body.ast);
}

concrete production sqliteQueryDb_c
top::cnc:PrimaryExpr_c ::= SqliteOn_t db::cnc:Expr_c SqliteQuery_t '{' query::SqliteQuery_c '}'
{
  top.ast = abs:sqliteQueryDb(db.ast, query.pp, location=top.location);
}

