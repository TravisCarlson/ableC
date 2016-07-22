grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax;

imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
import silver:langutil;

marking terminal Sqlite_t 'sqlite' lexer classes {Ckeyword};

terminal SqliteQuery_t 'query';
terminal SqliteUse_t 'use';
terminal SqliteExit_t 'exit';
terminal SqliteFor_t 'for';

concrete production sqliteUse_c
top::cnc:PrimaryExpr_c ::= Sqlite_t SqliteUse_t dbname::cnc:StringConstant_c
{
  top.ast = abs:sqliteUse(dbname.ast, location=top.location);
}

concrete production sqliteExit_c
top::cnc:PrimaryExpr_c ::= Sqlite_t SqliteExit_t db::cnc:Identifier_t
{
  top.ast = abs:sqliteExit(abs:fromId(db), location=top.location);
}

concrete production sqliteQueryDb_c
top::cnc:PrimaryExpr_c ::= Sqlite_t SqliteQuery_t db::cnc:Identifier_t '{' query::SqliteQuery_c '}'
{
  top.ast = abs:sqliteQuery(abs:fromId(db), query.ast, location=top.location);
}

nonterminal SqliteQuery_c with location, ast<String>;

concrete productions top::SqliteQuery_c
| s::cnc:StringConstant_c
  {
    top.ast = s.ast;
  }

concrete production sqliteForeach_c
top::cnc:Stmt_c ::= Sqlite_t SqliteFor_t '(' row::cnc:Identifier_t ':'
                           stmt::cnc:Identifier_t ')' '{' body::cnc:Stmt_c '}'
{
  top.ast = abs:sqliteForeach(abs:fromId(row), abs:fromId(stmt), body.ast);
}

