grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:use;

imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:ableC:abstractsyntax as abs;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
import silver:langutil;

marking terminal SqliteUse_t 'use' lexer classes {Ckeyword};

terminal SqliteAs_t 'as';
terminal SqliteWith_t 'with' lexer classes {Ckeyword};
terminal SqliteTable_t 'table';
terminal SqliteVarchar_t 'VARCHAR';
terminal SqliteInteger_t 'INTEGER';

concrete production sqliteUse_c
top::cnc:Stmt_c ::= 'use' dbFilename::cnc:StringConstant_c 'as'
                            dbName::cnc:Identifier_t tables::SqliteOptWithTables_c
{
  top.ast = abs:sqliteUse(dbFilename.ast, abs:fromId(dbName), tables.ast);
}

nonterminal SqliteOptWithTables_c with ast<abs:SqliteTableList>, location;
concrete productions top::SqliteOptWithTables_c
| 'with' '{' t::SqliteTableList_c '}'
  {
    top.ast = t.ast;
  }
|
  {
    top.ast = abs:sqliteNilTableList();
  }

nonterminal SqliteTableList_c with ast<abs:SqliteTableList>, location;
concrete productions top::SqliteTableList_c
| ts::SqliteTableList_c ',' t::SqliteTable_c
  {
    top.ast = abs:sqliteTableList(t.ast, ts.ast);
  }
| t::SqliteTable_c
  {
    top.ast = abs:sqliteTableList(t.ast, abs:sqliteNilTableList());
  }

nonterminal SqliteTable_c with ast<abs:SqliteTable>, location;
concrete productions top::SqliteTable_c
| 'table' n::cnc:Identifier_t '(' cs::SqliteColumnDeclList_c ')'
  {
    top.ast = abs:sqliteTable(abs:fromId(n), cs.ast);
  }

nonterminal SqliteColumnDeclList_c with ast<abs:SqliteColumnDeclList>, location;
concrete productions top::SqliteColumnDeclList_c
| cs::SqliteColumnDeclList_c ',' c::SqliteColumnDecl_c
  {
    top.ast = abs:sqliteColumnDeclList(c.ast, cs.ast);
  }
| c::SqliteColumnDecl_c
  {
    top.ast = abs:sqliteColumnDeclList(c.ast, abs:sqliteNilColumnDeclList());
  }
|
  {
    top.ast = abs:sqliteNilColumnDeclList();
  }

nonterminal SqliteColumnDecl_c with ast<abs:SqliteColumnDecl>, location;
concrete productions top::SqliteColumnDecl_c
| n::cnc:Identifier_t t::SqliteColumnType_c
  {
    top.ast = abs:sqliteColumnDecl(abs:fromId(n), t.ast);
  }

nonterminal SqliteColumnType_c with ast<abs:SqliteColumnType>, location;
concrete productions top::SqliteColumnType_c
| 'VARCHAR'
  {
    top.ast = abs:sqliteVarchar();
  }
| 'INTEGER'
  {
    top.ast = abs:sqliteInteger();
  }

