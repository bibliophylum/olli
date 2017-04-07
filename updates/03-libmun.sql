-- 03-libmun.sql
-- this table relates libraries and municipalities, and holds any data
-- specific to an individual library-municipality relationship
-- (e.g. that municipality's financial contribution to that library)

create table libmun (
       library_id integer not null,
       municipality_id integer not null,
       contribution money,
       primary key(library_id,municipality_id)
);
alter table libmun add foreign key (library_id) references libraries (id);
alter table libmun add foreign key (municipality_id) references municipalities (id);
