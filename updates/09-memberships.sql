-- 09-memberships.sql

alter table branches
 add column active_memberships integer,
 add column nonresident_single_memberships integer,
 add column nonresident_family_memberships integer;

alter table libraries
 add column fee_nonresident_single money,
 add column fee_nonresident_family money;
 
