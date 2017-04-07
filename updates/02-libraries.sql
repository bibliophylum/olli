-- 02-libraries.sql

create sequence libraries_id_seq;

create table libraries (
       id integer not null default nextval('libraries_id_seq'::regclass),
       year char(4) not null,
       name text not null,
       established date,
       is_registered_charity boolean default false,
       has_access_copyright_license boolean default false,
       has_board_minutes_on_website boolean default false,
       strategic_plan_start date,
       strategic_plan_end date,
       has_technology_plan boolean default false,
       is_confirmed boolean default true, -- false == data needs review
       primary key(id)
);

create index on libraries (year,name);
