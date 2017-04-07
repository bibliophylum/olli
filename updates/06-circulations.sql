-- 06-circulations.sql

create sequence circulations_id_seq;

create table circulations (
       id integer not null default nextval('circulations_id_seq'::regclass),
       branch_id integer not null,
       adult integer,
       children integer,
       audio_visual integer,
       ebooks integer,
       is_confirmed boolean default true, -- false == data needs review
       primary key(id)
);

alter table circulations add foreign key (branch_id) references branches (id);
create index on circulations (branch_id);
