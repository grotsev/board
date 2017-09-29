create schema live;

alter default privileges for role board in schema live revoke execute on functions from public;

--grant usage on schema live to public; -- TODO remove or uncomment

