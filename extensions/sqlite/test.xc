#include <sqlite3.h>
#include <stdlib.h>
#include <stdio.h>

int main(void)
{
//  sqlite3 *db = sqlite use "test.db";
////    with table tbl1 [ one VARCHAR,
////                      two INTEGER ];
//
//  sqlite3_stmt *results = sqlite query db {
//    "select * from tbl1"
//  };
//
//  sqlite for (row : results) {
////    printf("%s %d\n", row.one, row.two);
//    puts("got here");
//  }
//
//  sqlite exit db;
//
//  return EXIT_SUCCESS;
//
//
//// --------------------------------------------------
//
//  sqlite3 *db;
//
//  on db use "test.db";
////    with table tbl1 [ one VARCHAR,
////                      two INTEGER ];
//
//  sqlite3_stmt *results = on db query {
//    "select * from tbl1"
//  };
//
//  on db for (row : results) {
////    printf("%s %d\n", row.one, row.two);
//    puts("got here");
//  }
//
//  on db exit;
//
//  return EXIT_SUCCESS;
//
//// --------------------------------------------------
//  SqliteDb db = use "test.db"
//                  with table tbl1 [ one VARCHAR,
//                                    two INTEGER ];
//  SqliteRows rows = on db query {
//    select * from tbl1
//  };
//
//  on db for (row : rows) {
//    printf("%s %d\n", row.one, row.two);
//  }
//
//  on db exit;

  sqlite3 *db = use "test.db"
                  with table tbl1 [ one VARCHAR,
                                    two INTEGER ];

  sqlite3_stmt *results = on db query {
    "select * from tbl1"
  };

  on db for (row : results) {
//    printf("%s %d\n", row.one, row.two);
    puts("got here");
  }

  on db exit;

  return EXIT_SUCCESS;
}

