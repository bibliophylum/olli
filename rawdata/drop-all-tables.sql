-- Get list of tables to drop:
-- select 'drop table "' || tablename || '" cascade;' from pg_tables where schemaname = 'public';

drop table "census_subdivision_type" cascade; 
drop table "census_topic" cascade;            
drop table "census_year" cascade;             
drop table "circulations" cascade;            
drop table "ill" cascade;                     
drop table "ebook_circ" cascade;              
drop table "mun_cen" cascade;                 
drop table "contact" cascade;                 
drop table "technology" cascade;              
drop table "collections" cascade;             
drop table "financial" cascade;               
drop table "hours_of_operation" cascade;      
drop table "personnel" cascade;               
drop table "libmun" cascade;                  
drop table "social_media" cascade;            
drop table "census_div_sub" cascade;          
drop table "activities" cascade;              
drop table "libraries" cascade;               
drop table "census_division" cascade;         
drop table "census_subdivision" cascade;      
drop table "branches" cascade;                
drop table "census_characteristics" cascade;  
drop table "municipalities" cascade;          
drop table "census" cascade;                  
drop table "spatial_ref_sys" cascade;
