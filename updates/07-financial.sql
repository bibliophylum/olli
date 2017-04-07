-- 07-financial.sql

create sequence financial_id_seq;

create table financial (
       id integer not null default nextval('financial_id_seq'::regclass),
       library_id integer not null,
       is_confirmed boolean default true, -- false == data needs review
       income_municipal_contribution money,
       income_provincial_operating_grant money,
       income_provincial_collection_development_grant money,
       income_provincial_establishment_grant money,
       income_other_miscellaneous money,
       income_other_municipal money,
       income_other_provincial money,
       income_other_federal money,
       income_other_private money,
       expenditure_personnel money,
       expenditure_materials money,
       expenditure_capital money,
       expenditure_building money,
       expenditure_technology money,
       expenditure_other money,
       primary key(id)
);

alter table financial add foreign key (library_id) references libraries (id);
create index on financial (library_id);
