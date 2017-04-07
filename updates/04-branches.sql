-- 04-branches.sql

create sequence branches_id_seq;

create table branches (
       id integer not null default nextval('branches_id_seq'::regclass),
       year char(4) not null,
       library_id integer not null,
       municipality_id integer,  -- null if HQ
       name text not null,
       symbol varchar(10) not null,
       facility_owner text,
       facility_term_expires date,
       annual_rent money,
       floor_space integer,  -- sq.ft.
       is_confirmed boolean default true, -- false == data needs review
       primary key(id)
);

alter table branches add foreign key (library_id) references libraries (id);
create index on branches (library_id);
alter table branches add foreign key (municipality_id) references municipalities (id);
create index on branches (municipality_id);


create sequence hours_of_operation_id_seq;

create table hours_of_operation (
       id integer not null default nextval('hours_of_operation_id_seq'::regclass),
       branch_id integer not null,
       seasonal text,
       season_begins date,
       season_ends date,
       sunday text,
       monday text,
       tuesday text,
       wednesday text,
       thursday text,
       friday text,
       saturday text,
       per_week float,
       is_confirmed boolean default true, -- false == data needs review
       primary key(id)
);

alter table hours_of_operation add foreign key (branch_id) references branches (id);
create index on hours_of_operation (branch_id);

insert into municipalities (year, name) values ('2014','City of Winnipeg');
insert into libraries (year,name) values ('2014','Winnipeg Public Library');

