create or replace view v_diff as
  select '++' as diff,'table' as obj_diff,table_name as obj_name
  from 
  (
    select table_name from all_tables
    where owner = upper('${user_from_diff}')
    minus
    select table_name from all_tables
    where owner = upper('${user_from_scratch}')
  )
union
  select '--' as diff,'table' as obj_diff,table_name as obj_name
  from 
  (
  select table_name from all_tables
  where owner = upper('${user_from_scratch}')
  minus
  select table_name from all_tables
  where owner = upper('${user_from_diff}')
  )
union
select '++' as diff,'column' as obj_diff,table_name || '.' || column_name as obj_name
  from (
select column_name,table_name from all_tab_columns
where owner = upper('${user_from_diff}')
minus
select column_name,table_name from all_tab_columns
where owner = upper('${user_from_scratch}')
)
union
select '--' as diff,'column' as obj_diff,table_name || '.' || column_name as obj_name
from (
select column_name,table_name from all_tab_columns
where owner = upper('${user_from_scratch}')
minus
select column_name,table_name from all_tab_columns
where owner = upper('${user_from_diff}')
)
union
    select '--' as diff,'type' as obj_diff,table_name || '.' || column_name || ' ' 
    || data_type ||  '(' || data_length || '-' || data_precision || '-' || data_scale || ') null=' ||nullable  as obj_name
    from (
    select table_name,column_name,data_type,char_length,data_length , data_precision , data_scale, nullable
    from all_tab_columns
    where owner = upper('${user_from_diff}')
  minus
    select table_name,column_name,data_type,char_length,data_length , data_precision , data_scale, nullable
    from all_tab_columns
    where owner = upper('${user_from_scratch}')
    )
  union
    select '++' as diff,'type' as obj_diff,table_name || '.' || column_name || ' ' 
    || data_type ||  '(' || data_length || '-' || data_precision || '-' || data_scale || ') null=' ||nullable  as obj_name
    from (
    select table_name,column_name,data_type,char_length,data_length , data_precision , data_scale, nullable
    from all_tab_columns
    where owner = upper('${user_from_scratch}')
  minus
    select table_name,column_name,data_type,char_length,data_length , data_precision , data_scale, nullable
    from all_tab_columns
    where owner = upper('${user_from_diff}')
    )
union
select '--' as diff,'fk' as obj_diff,foreign_key || '<->' || refs as obj_name
from (
select
    col.table_name || '.' || col.column_name as foreign_key,
    rel.table_name || '.' || rel.column_name as refs
from all_tab_columns col
    join all_cons_columns con
      on col.table_name = con.table_name and col.column_name = con.column_name and col.owner = con.owner
    join all_constraints cc
      on con.constraint_name = cc.constraint_name and con.owner = cc.owner
    join all_cons_columns rel
      on cc.r_constraint_name = rel.constraint_name and con.position = rel.position
     and con.owner = rel.owner and cc.owner = rel.owner
where
    cc.constraint_type = 'R'
    and col.owner = upper('${user_from_diff}')
minus
select
    col.table_name || '.' || col.column_name as foreign_key,
    rel.table_name || '.' || rel.column_name as refs
from all_tab_columns col
    join all_cons_columns con
      on col.table_name = con.table_name and col.column_name = con.column_name and col.owner = con.owner
    join all_constraints cc
      on con.constraint_name = cc.constraint_name and con.owner = cc.owner
    join all_cons_columns rel
      on cc.r_constraint_name = rel.constraint_name and con.position = rel.position
     and con.owner = rel.owner and cc.owner = rel.owner
where
    cc.constraint_type = 'R'
    and col.owner = upper('${user_from_scratch}')
  )
  union
select '++' as diff,'fk' as obj_diff,foreign_key || '<->' || refs as obj_name
from (
select
    col.table_name || '.' || col.column_name as foreign_key,
    rel.table_name || '.' || rel.column_name as refs
from all_tab_columns col
    join all_cons_columns con
      on col.table_name = con.table_name and col.column_name = con.column_name and col.owner = con.owner
    join all_constraints cc
      on con.constraint_name = cc.constraint_name and con.owner = cc.owner
    join all_cons_columns rel
      on cc.r_constraint_name = rel.constraint_name and con.position = rel.position
     and con.owner = rel.owner and cc.owner = rel.owner
where
    cc.constraint_type = 'R'
    and col.owner = upper('${user_from_scratch}')
minus
select
    col.table_name || '.' || col.column_name as foreign_key,
    rel.table_name || '.' || rel.column_name as refs
from all_tab_columns col
    join all_cons_columns con
      on col.table_name = con.table_name and col.column_name = con.column_name and col.owner = con.owner
    join all_constraints cc
      on con.constraint_name = cc.constraint_name and con.owner = cc.owner
    join all_cons_columns rel
      on cc.r_constraint_name = rel.constraint_name and con.position = rel.position
     and con.owner = rel.owner and cc.owner = rel.owner
where
    cc.constraint_type = 'R'
    and col.owner = upper('${user_from_diff}')
  )
union
select '--' as diff,'cons' as obj_diff,table_name || '.' || column_name || ' (' || constraint_type || ') ' || idx as obj_name
from (
select cc.table_name,cc.column_name,ct.constraint_type,nvl2(ct.index_name,'has_idx','no_idx') idx
from all_cons_columns cc, all_constraints ct
where cc.constraint_name = ct.constraint_name
and ct.constraint_type != 'R'
and cc.owner = ct.owner
and cc.owner = upper('${user_from_diff}')
minus
select cc.table_name,cc.column_name,ct.constraint_type,nvl2(ct.index_name,'has_idx','no_idx') idx
from all_cons_columns cc, all_constraints ct
where cc.constraint_name = ct.constraint_name
and ct.constraint_type != 'R'
and cc.owner = ct.owner
and cc.owner = upper('${user_from_scratch}')
)
union
select '++' as diff,'cons' as obj_diff, table_name || '.' || column_name || ' (' || constraint_type || ') '|| idx as obj_name
from (
select cc.table_name,cc.column_name,ct.constraint_type,nvl2(ct.index_name,'has_idx','no_idx') idx
from all_cons_columns cc, all_constraints ct
where cc.constraint_name = ct.constraint_name
and ct.constraint_type != 'R'
and cc.owner = ct.owner
and cc.owner = upper('${user_from_scratch}')
minus
select cc.table_name,cc.column_name,ct.constraint_type,nvl2(ct.index_name,'has_idx','no_idx') idx
from all_cons_columns cc, all_constraints ct
where cc.constraint_name = ct.constraint_name
and ct.constraint_type != 'R'
and cc.owner = ct.owner
and cc.owner = upper('${user_from_diff}')
)
/

declare 
cursor cdiff is select * from v_diff order by obj_diff,obj_name;
msg varchar2(32767);
nb_sys_privs integer;
nbdiff integer;
begin

  begin
    select count(*)
    into nb_sys_privs
    from all_tables where owner = upper('${user_from_diff}');

    if nb_sys_privs = 0 then
	  msg:= 'not enough power from user ${user_diff} on user ${user_from_diff}';
	  raise_application_error(-20001,msg);
    end if;

    select count(*)
    into nb_sys_privs
    from all_tables where owner = upper('${user_from_scratch}');

    if nb_sys_privs = 0 then
	  msg:= 'not enough power from user ${user_diff} on ${user_from_scratch}';
	  raise_application_error(-20001,msg);
    end if;
  end;

select count(*)
into nbdiff
from v_diff
where obj_name not like 'BIN$%';

if nbdiff > 0 then
  msg := 'There was ' || nbdiff || ' difference(s)';
  for ndiff in cdiff
    loop
      msg := msg || chr(10) || ndiff.diff || ' - ' || ndiff.obj_diff || ' - ' || ndiff.obj_name;
    end loop;
  raise_application_error(-20000,msg);
end if;
  exception
    when others then
      msg := msg || chr(10) || '...';
      raise_application_error(-20000,msg);
end;
/

