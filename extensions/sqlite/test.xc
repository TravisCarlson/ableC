#include <sqlite3.h>
#include <stdlib.h>
#include <stdio.h>

int main(void)
{
  sqlite3 *db;
  int status = sqlite3_open("test.db", &db);

  if (status != SQLITE_OK) {
    fprintf(stderr, "could not open `test.db'\n");
    return EXIT_FAILURE;
  }

//  sqlite3_stmt *stmt = on db1 query {
//    select * from tbl1
//  };
  const char query[] = "select * from tbl1";
  sqlite3_stmt *stmt;
  status = sqlite3_prepare(db, query, sizeof(query), &stmt, NULL);
  if (status != SQLITE_OK) {
    fprintf(stderr, "could not run query `%s'\n", query);
    return EXIT_FAILURE;
  }

  while (sqlite3_step(stmt) == SQLITE_ROW) {
    const unsigned char *one = sqlite3_value_text(sqlite3_column_value(stmt, 0));
    int two = sqlite3_value_int(sqlite3_column_value(stmt, 1));
    printf("%s %d\n", one, two);
  }

  status = sqlite3_finalize(stmt);
  if (status != SQLITE_OK) {
    fprintf(stderr, "could not finalize statement `%s'\n", query);
    return EXIT_FAILURE;
  }

  status = sqlite3_close(db);
  if (status != SQLITE_OK) {
    fprintf(stderr, "could not close `test.db'\n");
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}

