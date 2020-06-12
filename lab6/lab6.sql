/*1. Добавить внешние ключи*/
ALTER TABLE lesson
ADD FOREIGN KEY (id_teacher) REFERENCES teacher(id_teacher);

ALTER TABLE lesson
ADD FOREIGN KEY (id_subject) REFERENCES subject(id_subject);

ALTER TABLE lesson
ADD FOREIGN KEY (id_group) REFERENCES  "group"(id_group);

ALTER TABLE mark
ADD FOREIGN KEY (id_student) REFERENCES student(id_student);

ALTER TABLE mark
ADD FOREIGN KEY (id_lesson) REFERENCES  lesson(id_lesson);

ALTER TABLE student
ADD FOREIGN KEY (id_group) REFERENCES "group"(id_group);

/*2. Выдать оценки студентов по информатике если они обучаются данному
предмету. Оформить выдачу данных с использованием view.*/
CREATE VIEW students_marks AS
SELECT mark, student.name AS student_name, subject.name AS subject_name FROM subject
INNER JOIN lesson ON subject.id_subject = lesson.id_subject
INNER JOIN mark ON lesson.id_lesson = mark.id_lesson
INNER JOIN student ON mark.id_student = student.id_student;

SELECT mark, student_name
FROM students_marks
WHERE students_marks.subject_name = 'Информатика';

/*3.Дать информацию о должниках с указанием фамилии студента
и названия предмета. Должниками считаются студенты, не имеющие оценки по предмету,
который ведется в группе. Оформить в виде процедуры, на входе идентификатор группы.*/
CREATE FUNCTION get_debtors(group_name varchar)
RETURNS TABLE
(
    name    varchar,
    subject_name varchar
)
LANGUAGE SQL
AS
$$
SELECT student.name, subject.name  FROM student
INNER JOIN "group" ON student.id_group = "group".id_group
INNER JOIN lesson ON "group".id_group = lesson.id_group
LEFT JOIN mark ON mark.id_student = student.id_student AND mark.id_lesson = lesson.id_lesson
INNER JOIN subject ON lesson.id_subject = subject.id_subject
WHERE "group".name = group_name
group by student.id_student, subject.name
having count(mark.mark) = 0;
$$;

SELECT * FROM get_debtors('ПС');

/*4. Дать среднюю оценку студентов по каждому предмету для тех предметов, по
которым занимается не менее 35 студентов */
SELECT subject.name, AVG(mark.mark) FROM subject
INNER JOIN lesson ON subject.id_subject = lesson.id_subject
INNER JOIN mark ON lesson.id_lesson = mark.id_lesson
INNER JOIN student ON mark.id_student = student.id_student
GROUP BY subject.name
HAVING count(distinct student.id_student) >= 35;

/*5.Дать оценки студентов специальности ВМ по всем проводимым предметам с
указанием группы, фамилии, предмета, даты. При отсутствии оценки заполнить
значениями NULL поля оценки */
SELECT "group".name, student.name, subject.name, lesson.date, mark.mark FROM student
inner join "group" ON "group".id_group = student.id_group
inner join lesson ON "group".id_group = lesson.id_group
inner JOIN subject ON lesson.id_subject = subject.id_subject
LEFT JOIN mark ON student.id_student = mark.id_student AND mark.id_lesson = lesson.id_lesson
WHERE "group".name = 'ВМ';

/*6. Всем студентам специальности ПС
, получившим оценки меньшие 5 по предмету
БД до 12.05, повысить эти оценки на 1 балл.*/
BEGIN;
UPDATE mark
SET mark = (mark.mark + 1)
WHERE mark.id_mark IN (
    SELECT id_mark FROM mark
    INNER JOIN lesson ON mark.id_lesson = lesson.id_lesson
    INNER JOIN "group" ON lesson.id_group = "group".id_group
    INNER JOIN subject ON lesson.id_subject = subject.id_subject
    WHERE mark.mark < 5 AND
          lesson.date < '2020-05-12' AND
          "group".name = 'ПС' AND
          subject.name = 'БД'
);
ROLLBACK;

/*7. Добавить необходимые индексы */
CREATE INDEX IX_lesson_subject_id_index
ON lesson (id_subject);

CREATE INDEX IX_lesson_id_group_index
ON lesson (id_group);

CREATE INDEX IX_lesson_date_index
ON lesson(date);

CREATE INDEX IX_mark_lesson_id_index
ON mark (id_lesson);

CREATE INDEX IX_mark_student_id_index
ON mark (id_student);

CREATE INDEX IX_mark_mark_index
ON mark ("mark");

CREATE INDEX IX_group_name_index
ON "group" (name);

CREATE INDEX IX_subject_name_index
ON subject(name);
