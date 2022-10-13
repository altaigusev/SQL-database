# SQL-database
Example of database. See details in Readme.md file

## English
This project based on School21 (powered by Sber) task Info21. This is example of my skills in creating databases, tables, queries, functions, triggers,  procedures and constraints.

This project shows some internal circumstances in educational process in School21. In abstract style database contains records about students, their mutual checks, autotest results, recommendations of checking peers and quantity of XP depending on checks results.

How to use the project:
1) You need to execute part1.sql and part1_insert.sql scripts to create and populate database with data.
2) In part2 folder there are some functions and triggers, that able to make databse usage easer and make less mistakes during insertion of new rows in tables.
3) In part3 folder there are 25 queries showing different useful information from this database, such as:
 - Student with highest rank
 - Calculation of learning time in campus
 - Common staistics of educational results
 
I recommed you to repeat step 1 after step 2, because at step 3 some results may look incorrectly. But this kind of work noticed only on ArchLinux/Manjaro operating systems.
In part1 folder you can find data.zip archive, which contains *.csv files to populate database. To do it, you need to copy this files in PostgreSQL root folder (for example /var/lib/postgresql/14/). After that start par1_import.sql script.

part1_export.sql respectively export data from database in PostgreSQL rot folder.

## Русский
Этот проект основан на задании Школы 21 (школа программирования от Сбера) под названием Info21. Это пример моих навыков в создании баз данных, таблиц, функций, триггеров, процедур и ограничений.

В этом проекте содержатся некоторые внутренние события образовательного процесса в Школе21. В абстрактном виде база данных содержит записи о студентах, их взамных проверках, резульатов автотестов, рекомендаций проверяющих пиров и количество получаемых баллов в зависимости от результатов проверок.

Как пользоваться проектом:
1) Вам следует выполнить скрипты part1.sql и part1_insert.sql для создания базы и наполнения ее данными.
2) В папке part2 содержатся некоторые функции и триггеры, которые облегчают использование базы данных и делать меньше ошибок при добавлении новых строк.
3) В папке part3 содержатся функции и процедуры, содержащие 25 запросов, показывающих различную полезную информацию из этой базы данных, например:
 - Студентов с наивысшим рейтингом
 - Вычисление учебного времени в кампусе
 - Общая статистика по учебным результатам
 
Я рекомендую Вам повторить шаг 1 после шага 2, поскольку если выполнить сразу шаг 3, то результаты могут выглядеть некорректными. Но такое поведение замечено только на системах ArchLinux/Manjaro
В папке part1 вы можете обнаружить архив data.zip, который содержит *.csv файлы для наполнения базы данными. Чтобы это сделать, Вам надо скопировать эти файлы в корневой каталог Postgres (например /var/lib/postgresql/14/). После этого запустите скрипт part1_import.sql.

Скрипт part1_export.csv соответственно выгружает данные из таблиц в корневую папку PostgreSQL.
