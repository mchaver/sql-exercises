CREATE DATABASE basics;

CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL
);

CREATE TABLE classes (
  id SERIAL PRIMARY KEY,
  subject TEXT NOT NULL
);

CREATE TABLE attends (
  id serial PRIMARY KEY,
  student_id INTEGER NOT NULL,
  class_id INTEGER NOT NULL,
  FOREIGN KEY (student_id) REFERENCES students (id),
  FOREIGN KEY (class_id) REFERENCES classes (id)
);

INSERT INTO students (first_name, last_name) VALUES ('John','Smith');
INSERT INTO students (first_name, last_name) VALUES ('Deva','Srinivasan');
INSERT INTO students (first_name, last_name) VALUES ('Hassan','Almasi');

INSERT INTO classes (subject) VALUES ('Computer Science');
INSERT INTO classes (subject) VALUES ('Literature');
INSERT INTO classes (subject) VALUES ('Astronomy');
INSERT INTO classes (subject) VALUES ('Mechanical Engineering');
INSERT INTO classes (subject) VALUES ('Philosophy');

INSERT INTO attends (student_id, class_id) VALUES (1,1);
INSERT INTO attends (student_id, class_id) VALUES (1,2);
INSERT INTO attends (student_id, class_id) VALUES (1,3);

INSERT INTO attends (student_id, class_id) VALUES (2,1);
INSERT INTO attends (student_id, class_id) VALUES (2,4);
INSERT INTO attends (student_id, class_id) VALUES (2,5);

INSERT INTO attends (student_id, class_id) VALUES (3,1);
INSERT INTO attends (student_id, class_id) VALUES (3,3);
INSERT INTO attends (student_id, class_id) VALUES (3,5);


/* who attends Computer Science */
SELECT first_name, last_name
FROM students
LEFT JOIN attends
     ON students.id = attends.student_id
LEFT JOIN classes
     ON classes.id = attends.class_id
WHERE classes.subject = 'Computer Science';

/*
 first_name | last_name
------------+------------
 John       | Smith
 Deva       | Srinivasan
 Hassan     | Almasi
*/

/* who attends Literature */
SELECT first_name, last_name
FROM students
LEFT JOIN attends
     ON students.id = attends.student_id
LEFT JOIN classes
     ON classes.id = attends.class_id
WHERE classes.subject = 'Literature';
/*
 first_name | last_name
------------+-----------
 John       | Smith
(1 row)
*/


/* who does not attend Literature */

SELECT first_name, last_name FROM students WHERE students NOT IN
       (
       SELECT students
       FROM students
       LEFT JOIN attends
       	    ON students.id = attends.student_id
       LEFT JOIN classes
       	    ON classes.id = attends.class_id
       WHERE classes.subject = 'Literature'
       );
