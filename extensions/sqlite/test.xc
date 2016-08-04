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
  const char except_surname[] = "Adams";

  on db query {
    SELECT   age, gender, last_name AS surname
    FROM     person JOIN details
                      ON person.person_id = details.person_id
    WHERE    age > ${limit} AND surname <> ${except_surname}
    ORDER BY surname DESC
  } as people;

  foreach (person : people) {
    printf("%d %s %s\n", person.age, person.gender, person.surname);
  }

  on db exit;

  return 0;
}

