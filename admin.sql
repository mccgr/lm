-- system("psql < admin.sql")
CREATE SCHEMA lm;
CREATE ROLE lm;
CREATE ROLE lm_access;
GRANT USAGE ON SCHEMA lm TO lm_access ;
GRANT ALL ON SCHEMA lm TO lm;
