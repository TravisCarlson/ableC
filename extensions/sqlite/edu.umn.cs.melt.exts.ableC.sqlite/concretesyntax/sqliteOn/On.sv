grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:sqliteOn;

imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
import silver:langutil;

--marking terminal SqliteDb_t 'SqliteDb' lexer classes {Ckeyword};
--marking terminal SqliteRows_t 'SqliteRows' lexer classes {Ckeyword};
marking terminal SqliteOn_t 'on' lexer classes {Ckeyword};

terminal SqliteExit_t 'exit';
terminal SqliteFor_t 'for';
terminal SqliteQuery_t 'query';

concrete production sqliteExit_c
top::cnc:PrimaryExpr_c ::= SqliteOn_t db::cnc:Identifier_t SqliteExit_t
{
  top.ast = abs:sqliteExit(abs:fromId(db), location=top.location);
}

concrete production sqliteForeach_c
top::cnc:Stmt_c ::= SqliteOn_t db::cnc:Identifier_t SqliteFor_t '(' row::cnc:Identifier_t ':'
                           stmt::cnc:Identifier_t ')' '{' body::cnc:Stmt_c '}'
{
  top.ast = abs:sqliteForeach(abs:fromId(row), abs:fromId(stmt), body.ast);
}

concrete production sqliteQueryDb_c
top::cnc:PrimaryExpr_c ::= SqliteOn_t db::cnc:Identifier_t SqliteQuery_t '{' query::SqliteQuery_c '}'
{
  top.ast = abs:sqliteQueryDb(abs:fromId(db), query.ast, location=top.location);
}

