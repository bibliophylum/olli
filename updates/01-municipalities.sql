-- 01-municipalities.sql

create sequence municipalities_id_seq;

create table municipalities (
       id integer not null default nextval('municipalities_id_seq'::regclass),
       year char(4) not null,
       name text not null,
       population integer,
       is_bilingual boolean default false,
       is_northern boolean default false,
       municipal_number text,                  -- from AMM
       primary key(id)
);

