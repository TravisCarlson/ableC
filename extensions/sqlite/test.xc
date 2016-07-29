#include <sqlite.xh>
#include <stdio.h>

int main(void)
{
  use "test.db" with {
    table person  ( person_id  INTEGER,
                    first_name VARCHAR,
                    last_name  VARCHAR ),
    table details ( person_id  INTEGER,
                    age        INTEGER,
                    gender     VARCHAR )
  } as db;

  int limit = 18;

  on db query {
    SELECT age, gender, last_name
    FROM   person, details
    WHERE  person.person_id =
           details.person_id
//       AND details.age > limit
       AND details.age > 18
  } as people;

  foreach (person : people) {
    printf("%d %s %s\n", person.age, person.gender, person.last_name);
  }

  on db exit;

  return 0;
}

