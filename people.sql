CREATE DATABASE people;

CREATE TABLE people (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE phones (
  id SERIAL PRIMARY KEY,
  phone_number TEXT NOT NULL,
  person_id INTEGER NOT NULL,
  FOREIGN KEY (person_id) REFERENCES people (id)
);

INSERT INTO people (name) VALUES ('Alice'); 
INSERT INTO people (name) VALUES ('Bob');

INSERT INTO phones (phone_number, person_id) VALUES ('123456789', 1);
INSERT INTO phones (phone_number, person_id) VALUES ('002233445', 1);

/*
array_remove(_, NULL)
get rid of the nulls
*/

SELECT json_build_object('id',people.id,'name',people.name,'panels', array_to_json(array_remove(array_agg(phones), NULL)))
FROM people
LEFT JOIN phones
  ON phones.person_id = people.id
GROUP BY (people.id);
