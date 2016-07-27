#include <sqlite.xh>
#include <stdio.h>

int main(void)
{
  SqliteDb db = use "test.db"
                  with table tbl1 ( one VARCHAR,
                                    two INTEGER );

//  SqliteRows *rows = on db query {
  sqlite3_stmt *rows = on db query {
    SELECT one, two FROM tbl1
  };

  on db for (row : rows) {
//    printf("%s %d\n", row.one, row.two);
    puts("got here");
  }

  on db exit;

  return 0;
}

