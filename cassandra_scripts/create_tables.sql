-- liquibase formatted sql

-- changeset liquibase:1 labels:pre,all
CREATE TABLE characters (
    id int PRIMARY KEY,
    name text,
    origin_city text,
    age varint,
    height varint
);
-- rollback drop table characters

-- changeset liquibase:2 labels:pre,all
CREATE TABLE locations (
    id int PRIMARY KEY,
    name text,
    type text,
    pop_size varint,
    dim_size varint
    );
-- rollback drop table locations

-- changeset liquibase:3 labels:post,all
CREATE TABLE supplies (
    id int PRIMARY KEY,
    name text,
    type text
);
-- rollback drop table supplies