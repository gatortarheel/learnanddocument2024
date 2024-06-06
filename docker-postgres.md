
```
docker run --name my-postgres -v /path/to/data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=mysecretpassword -d postgres

docker exec -it my-postgres psql -U postgres


CREATE DATABASE sample_db;

\c sample_db

CREATE TABLE sample_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    age INTEGER
);


```

---
Certainly! Based on the context you provided, it seems like you want to create a sample PostgreSQL database and table. Here are the PostgreSQL commands to achieve that:

    Create a sample database:

CREATE DATABASE sample_db;

This command will create a new database named "sample_db".

Connect to the newly created database:

\c sample_db

This command will switch the connection to the "sample_db" database.

Create a sample table:

    CREATE TABLE sample_table (
        id SERIAL PRIMARY KEY,
        name VARCHAR(50),
        age INTEGER
    );

    This command will create a new table named "sample_table" with three columns: "id" (auto-incrementing serial primary key), "name" (varchar with a maximum length of 50), and "age" (integer).

After running these commands, you should have a sample PostgreSQL database named "sample_db" with a table named "sample_table" containing the specified columns.

Insert a row of data into the "sample_table":

INSERT INTO sample_table (name, age) VALUES ('Alice', 30);

This command will insert a new row into the "sample_table" table with the values 'Alice' for the name column and 30 for the age column.

Select the inserted data from the "sample_table":

SELECT * FROM sample_table;

This command will retrieve all rows and columns from the "sample_table" table. You should see the row you inserted with the name 'Alice' and age 30.

![image](https://github.com/gatortarheel/learnanddocument2024/assets/11463852/2ef2395e-eaec-457d-9a1d-bece47ee695b)


credit: https://codeium.com/live/general
