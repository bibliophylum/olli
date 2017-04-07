-- 12-ill.sql

create sequence ill_id_seq;

create table ill (
       id integer not null default nextval('ill_id_seq'::regclass),
       branch_id integer not null,
       is_confirmed boolean default true, -- false == data needs review
       requests_made integer,
       items_received integer,
       requests_received integer,
       items_sent integer,
       primary key(id)
);

alter table ill add foreign key (branch_id) references branches (id);
create index on ill (branch_id);
