#include <sqlite.xh>
#include <stdio.h>

struct person_and_details_t {
  const char *first_name;
  const char *last_name;
  int age;
  const char *gender;
};

struct person_and_details_t c_people[] = {
  {"Aaron",    "Allen",  10, "M"},
  {"Abigail",  "Adams",  20, "F"},
  {"Benjamin", "Brown",  30, "M"},
  {"Belle",    "Bailey", 40, "F"},
};

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

//  on db query {
//    DELETE from person
//  } as clear_people;
//  finalize(clear_people);
//
//  on db query {
//    DELETE from details
//  } as clear_details;
//  finalize(clear_details);

  int i;
  for (i=0; i < sizeof(c_people) / sizeof(struct person_and_details_t); ++i) {
    on db query {
      INSERT INTO person VALUES
        (${i}, ${c_people[i].first_name}, ${c_people[i].last_name})
    } as populate_people;
    finalize(populate_people);

    on db query {
      INSERT INTO details VALUES
        (${i}, ${c_people[i].age}, ${c_people[i].gender})
    } as populate_details;
    finalize(populate_details);
  }

  on db query {
    SELECT * FROM person
  } as all_people;

  foreach (person : all_people) {
    printf("%d %s %s\n", person.person_id, person.first_name, person.last_name);
  }

  finalize(all_people);

  int min_age = 18;
  const char except_surname[] = "Adams";

  on db query {
    SELECT   age, gender, last_name AS surname
    FROM     person JOIN details
                      ON person.person_id = details.person_id
    WHERE    age >= ${min_age} AND surname <> ${except_surname}
    ORDER BY surname DESC
  } as selected_people;

  foreach (person : selected_people) {
    printf("%s %d %s\n", person.surname, person.age, person.gender);
  }

  finalize(selected_people);

  on db exit;

  return 0;
}

