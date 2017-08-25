create table if not exists mun_geo_gis(municipality_id integer, gis_local_id integer, designation varchar(25), year varchar(4), primary key(municipality_id, gis_local_id, designation, year));
alter table mun_geo_gis owner to olli;

--insert INTO mun_geo_gis values (,,'',2011);
insert INTO mun_geo_gis values (600,500,'City',2011);	--City of Brandon
insert INTO mun_geo_gis values (609,0,'City',2011);	--City of Winnipeg
insert INTO mun_geo_gis values (559,163,'Rural Municipality',2011);	--City of Portage La Prairie
insert INTO mun_geo_gis values (558,550,'City',2011);	--RM of Portage
insert INTO mun_geo_gis values (603,155,'Rural Municipality',2011);	--RM of North Cypress
insert INTO mun_geo_gis values (604,187,'Rural Municipality',2011);	--RM of South Cypress
insert INTO mun_geo_gis values (605,407,'Town',2011);	--Town of Carberry
