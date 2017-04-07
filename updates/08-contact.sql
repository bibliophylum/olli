-- 08-contact.sql
-- could have added these to branches table, but it's easier to
-- point to an address entry.  Branch info gets duplicated for each year,
-- but the address would rarely change... so why duplicate it, too?

create sequence contact_id_seq;
create table contact (
       id integer not null default nextval('contact_id_seq'::regclass),
       branch_id integer not null,
       is_confirmed boolean default true, -- false == data needs review
       librarian text,
       street text,
       box text,
       town text,
       province text,
       postal_code text,
       phone text,
       fax text,
       email_general text,
       email_admin text,
       email_ill text,
       website text,
       catalogue text,
       primary key(id)
);

alter table contact add foreign key (branch_id) references branches (id);
create index on contact (branch_id);
