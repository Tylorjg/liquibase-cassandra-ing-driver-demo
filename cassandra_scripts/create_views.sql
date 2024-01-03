-- liquibase formatted sql

-- changeset liquibase_view:1 labels:view,all
CREATE MATERIALIZED VIEW viewAllCharacters AS
   SELECT * FROM characters
   WHERE id IS NOT NULL
   PRIMARY KEY (id)
   WITH comment='This is a view';
-- rollback DROP MATERIALIZED VIEW viewAllCharacters
