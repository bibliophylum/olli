-- 13-ebook-circ.sql

create sequence ebook_circ_id_seq;

create table ebook_circ (
       id integer not null default nextval('ebook_circ_id_seq'::regclass),
       branch_id integer not null,
       is_confirmed boolean default true, -- false == data needs review
       adobe_epub integer,
       adobe_pdf integer,
       disney_online integer,
       open_epub integer,
       open_pdf integer,
       mobipocket integer,
       overdrive_read integer,
       overdrive_listen integer,
       mp3_audio integer,
       wma_audio integer,
       database_sessions integer,
       primary key(id)
);

alter table ebook_circ add foreign key (branch_id) references branches (id);
create index on ebook_circ (branch_id);
