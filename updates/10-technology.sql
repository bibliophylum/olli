-- 10-technology.sql

create sequence technology_id_seq;

create table technology (
       id integer not null default nextval('technology_id_seq'::regclass),
       branch_id integer not null,
       is_confirmed boolean default true, -- false == data needs review
       computers integer,
       public_access_computers integer,
       computer_bookings integer,
       website_visits integer,
       barcode_items_prefix text,
       barcode_items_length integer,
       barcode_patron_prefix text,
       barcode_patron_length integer,
       ILS text,
       primary key(id)
);

alter table technology add foreign key (branch_id) references branches (id);
create index on technology (branch_id);
