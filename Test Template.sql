-- Test Template

CREATE TABLE accounts (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);


INSERT INTO accounts(username, password, email)
VALUES('jbourne','temp$123','jbourne@gmail.com');


INSERT INTO accounts(username, password, email)
VALUES('hbosch','temp$123','hbosch@gmail.com');

SELECT * FROM accounts;


CREATE USER jbourne WITH PASSWORD '123';

CREATE DATABASE test0
WITH OWNER=jbourne;


CREATE USER hbosch WITH PASSWORD '123';

CREATE DATABASE test1
WITH OWNER=hbosch;
