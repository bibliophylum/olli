-- 16-statcan.sql

create sequence census_year_id_seq;
create table census_year (
       id integer not null default nextval('census_year_id_seq'::regclass),
       value text not null,
       primary key(id)
);

create sequence census_division_id_seq;
create table census_division (
       id integer not null default nextval('census_division_id_seq'::regclass),
       value text not null,
       primary key(id)
);

create sequence census_subdivision_type_id_seq;
create table census_subdivision_type (
       id integer not null default nextval('census_subdivision_type_id_seq'::regclass),
       value text not null,
       primary key(id)
);

create sequence census_subdivision_id_seq;
create table census_subdivision (
       id integer not null default nextval('census_subdivision_id_seq'::regclass),
       value text not null,
       sdtype_id integer,
       primary key(id)
);
alter table census_subdivision add foreign key (sdtype_id) references census_subdivision_type (id);

create table census_div_sub (
       division_id integer not null,
       subdivision_id integer not null,
       primary key(division_id,subdivision_id)
);
alter table census_div_sub add foreign key (division_id) references census_division (id);
alter table census_div_sub add foreign key (subdivision_id) references census_subdivision (id);

create sequence census_topic_id_seq;
create table census_topic (
       id integer not null default nextval('census_topic_id_seq'::regclass),
       value text not null,
       primary key(id)
);

-- Info on to_number() format mask:
-- https://www.techonthenet.com/postgresql/functions/to_number.php
create sequence census_characteristics_id_seq;
create table census_characteristics (
       id integer not null default nextval('census_characteristics_id_seq'::regclass),
       value text not null,
       format_mask text default '999999',
       primary key(id)
);

create sequence census_id_seq;
create table census (
       id integer not null default nextval('census_id_seq'::regclass),
       year_id integer not null,
       division_id integer not null,
       subdivision_id integer not null,
       topic_id integer not null,
       characteristics_id integer not null,
       ord integer not null,  -- turns out that the order of rows in source data is important
       total text not null,
       male text,
       female text,
       primary key(id)
);
alter table census add foreign key (year_id) references census_year (id);
alter table census add foreign key (division_id) references census_division (id);
alter table census add foreign key (subdivision_id) references census_subdivision (id);
alter table census add foreign key (topic_id) references census_topic (id);
alter table census add foreign key (characteristics_id) references census_characteristics (id);
create index on census (year_id,subdivision_id);  -- most common entry point?

create table mun_cen (
       municipality_id integer not null,
       census_division_id integer not null,
       census_subdivision_id integer not null,
       primary key(municipality_id,census_division_id,census_subdivision_id)
);
       
