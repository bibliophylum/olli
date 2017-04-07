-- 05-collections.sql

create sequence collections_id_seq;

create table collections (
       id integer not null default nextval('collections_id_seq'::regclass),
       branch_id integer not null,
       english integer,
       french integer,
       other integer,
       serial_subscriptions integer,
       is_confirmed boolean default true, -- false == data needs review
       primary key(id)
);

alter table collections add foreign key (branch_id) references branches (id);
create index on collections (branch_id);


