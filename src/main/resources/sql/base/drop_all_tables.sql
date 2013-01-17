DECLARE
cursor drops is
 select 'drop table ' || table_name || ' cascade constraints purge' drop_query
 from user_tables;
begin
for table_drop in drops
loop
 execute immediate table_drop.drop_query;
end loop;
end; 
/
DECLARE
cursor drops is
 select 'drop sequence ' || sequence_name drop_query
 from user_sequences;
begin
for table_drop in drops
loop
 execute immediate table_drop.drop_query;
end loop;
end; 
/
