/*Elliot Randall - 43569175 - INFS200 assignment*/

/*Task 0 - Database*/ 

@C:\INFS2200/prjScript.sql

/*Task 1 - Constraints*/ 

/*a)*/
SELECT CONSTRAINT_NAME
FROM USER_CONSTRAINTS
WHERE TABLE_NAME = 'FILM'
OR TABLE_NAME = 'ACTOR'
OR TABLE_NAME = 'FILM_ACTOR'
OR TABLE_NAME = 'CATEGORY'
OR TABLE_NAME = 'language'
OR TABLE_NAME = 'FILM_CATEGORY';

/*b)*/
ALTER TABLE actor 
ADD CONSTRAINT PK_ACTORID PRIMARY KEY (actor_id);

ALTER TABLE category 
ADD CONSTRAINT PK_CATEGORYID PRIMARY KEY (category_id); 

ALTER TABLE actor  
ADD CONSTRAINT CK_FNAME 
CHECK(first_name IS NOT NULL); 

ALTER TABLE actor 
ADD CONSTRAINT CK_LNAME
CHECK(last_name IS NOT NULL); 

ALTER TABLE film 
ADD CONSTRAINT CK_TITLE
CHECK(title IS NOT NULL); 

ALTER TABLE category 
ADD CONSTRAINT CK_CATNAME
CHECK(category IS NOT NULL); 

ALTER TABLE film 
ADD CONSTRAINT CK_RENTALRATE 
CHECK(rental_rate IS NOT NULL); 

ALTER TABLE film
ADD CONSTRAINT CK_RATING
CHECK (rating IN ('G', 'PG', 'PG-13', 'R', 'NC-17'));

ALTER TABLE film
ADD CONSTRAINT CK_SPLFEATURES
CHECK (special_features IN (NULL, 'Trailers', 'Commentaries', 'Deleted Scenes', 'Behind the Scenes'));

ALTER TABLE film 
ADD CONSTRAINT FK_LANGUAGEID 
FOREIGN KEY (language_id) REFERENCES "language"(language_id); 

ALTER TABLE film 
ADD CONSTRAINT FK_ORLANGUAGEID
FOREIGN KEY (original_language_id) REFERENCES "language"(language_id); 

ALTER TABLE film_actor  
ADD CONSTRAINT FK_ACTORID
FOREIGN KEY (actor_id) REFERENCES actor(actor_id);

ALTER TABLE film 
ADD CONSTRAINT CK_RELEASEYR
CHECK (release_year <= '2014'); 


/*Task 2 - Triggers*/

/*a)*/
SELECT F.title, F.rental_rate 
FROM film F, film_category FC, Category C 
WHERE F.rental_rate IN(
SELECT max(rental_rate)
FROM film)
AND F.film_id = FC.film_id
AND FC.category_id = C.category_id
AND C.name = 'Documentary';
		


/*b)*/
SELECT A.actor_id, A.first_name, A.last_name
FROM actor A, film_actor FA, film F, film_category FC, category C
WHERE A.actor_id = FA.actor_id 
AND FA.film_id = F.film_id 
AND F.film_id = FC.film_id 
AND FC.category_id = C.category_id 
AND C.name = 'Documentary'
AND F.rental_rate IN(
SELECT max(rental_rate) 
FROM film); 

/*

	c)  In Report
		
*/

/*d)*/
create or replace TRIGGER CH_RENTALS
BEFORE INSERT
ON FILM
FOR EACH ROW
BEGIN 
IF :new.special_features = 'Commentaries' THEN
:new.rental_rate := :new.rental_rate + 0.5;
ELSIF :new.special_features = 'Deleted Scenes' THEN
:new.rental_rate := :new.rental_rate + 0.2;
ELSIF :new.special_features = 'Behind the Scenes' THEN
:new.rental_rate := :new.rental_rate - 0.2;
ELSE
:new.rental_rate := :new.rental_rate + 0.1;
END IF;
END;
/


/*Task 3 - Views*/

/*a)*/
CREATE VIEW V_DETAILS_BY_ACTOR AS
SELECT * 
FROM(
SELECT count(*), A.actor_id, A.first_name, A.last_name, avg(F.rental_rate)
FROM actor A, film F, film_actor FA
WHERE A.actor_id = FA.actor_id 
AND FA.film_id = F.film_id 
GROUP BY A.actor_id, A.first_name, A.last_name
ORDER BY count(*) DESC)
WHERE rownum <= 100; 

/*b)*/
CREATE MATERIALIZED VIEW MV_DETAILS_BY_ACTOR
BUILD IMMEDIATE AS
SELECT * 
FROM(
SELECT count(*), A.actor_id, A.first_name, A.last_name, avg(F.rental_rate)
FROM actor A, film F, film_actor FA
WHERE A.actor_id = FA.actor_id 
AND FA.film_id = F.film_id 
GROUP BY A.actor_id, A.first_name, A.last_name
ORDER BY count(*) DESC)
WHERE rownum <= 100; 

/*Task 4 - Indexes*/

/*a)*/
SELECT DISTINCT(substr(title,1,instr(title,' ',1,1)-1)) AS first_word, COUNT(*)
FROM film
GROUP BY (substr(title,1,instr(title,' ',1,1)-1))
HAVING COUNT(*) >= 20;

/*b)*/
CREATE INDEX TITLE_FIRSTWORD
ON film(substr(title,1,instr(title,' ',1,1)-1));


/*Task 5 - Execution Plan*/

/*a)*/
EXPLAIN PLAN FOR SELECT /*+RULE*/ * FROM film WHERE 
film_id = 1734;

SELECT PLAN_TABLE_OUTPUT 
FROM TABLE(DBMS_XPLAN.DISPLAY);

/*b)*/
ALTER TABLE film drop constraint PK_FILMID;

EXPLAIN PLAN FOR SELECT /*+RULE*/ * FROM film WHERE 
film_id = 1734;

SELECT PLAN_TABLE_OUTPUT 
FROM TABLE(DBMS_XPLAN.DISPLAY);




	



      