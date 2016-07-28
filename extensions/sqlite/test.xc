#include <sqlite.xh>
#include <stdio.h>

int main(void)
{
  use "test.db" as db with {
    table person  ( person_id  INTEGER,
                    first_name VARCHAR,
                    last_name  VARCHAR ),
    table details ( person_id  INTEGER,
                    age        INTEGER,
                    gender     VARCHAR )
  };

  int limit = 25;

//  on db query {
  sqlite3_stmt *people = on db query {
    SELECT age, gender, last_name
    FROM   person, details
    WHERE  person.person_id =
           details.person_id
       AND details.age > limit
//  } as people;
  };

  on db for (person : people) {
//    printf("%d %s %s\n", person.age, person.gender, person.last_name);
    puts("got here");
  }

  on db exit;

  return 0;
}

