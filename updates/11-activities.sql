-- 11-activities.sql

create sequence activities_id_seq;

create table activities (
       id integer not null default nextval('activities_id_seq'::regclass),
       branch_id integer not null,
       is_confirmed boolean default true, -- false == data needs review
       informational_transactions integer,
       gate_count integer,
       program_attendance integer,
       primary key(id)
);

alter table activities add foreign key (branch_id) references branches (id);
create index on activities (branch_id);
