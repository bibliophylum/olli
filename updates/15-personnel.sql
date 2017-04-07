-- 15-personnel.sql

create sequence personnel_id_seq;

create table personnel (
       id integer not null default nextval('personnel_id_seq'::regclass),
       branch_id integer not null,
       is_confirmed boolean default true, -- false == data needs review
       staff_count_full_time integer,
       staff_count_part_time integer,
       weekly_hours_professional numeric(6,2), -- 1234.56
       weekly_hours_library_tech numeric(6,2),
       weekly_hours_other numeric(6,2),
       total_weekly_hours_reported_all_staff numeric(6,2), -- flag when this doesn't match
       weekly_hours_worked_when_closed numeric(6,2),
       primary key(id)
);

alter table personnel add foreign key (branch_id) references branches (id);
create index on personnel (branch_id);
