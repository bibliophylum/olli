drop table if exists mun_geo_gis;
create table mun_geo_gis(
    municipality_id integer references municipalities(id),
    gis_local_id integer,
    designation varchar(25),
    year varchar(4),
    primary key(municipality_id, year));
alter table mun_geo_gis owner to olli;

--insert INTO mun_geo_gis values (,,'',2011);   --
insert INTO mun_geo_gis values (457,619,'Town',2011);   --Town of Gillam
insert INTO mun_geo_gis values (458,600,'Rural Municipality',2011);   --RM of Alexander
insert INTO mun_geo_gis values (459,198,'Rural Municipality',2011);   --RM of Victoria Beach
insert INTO mun_geo_gis values (460,347,'Town',2011);   --Town of Powerview/Pine Falls
insert INTO mun_geo_gis values (461,151,'Rural Municipality',2011);   --RM of Montcalm
insert INTO mun_geo_gis values (462,342,'Village',2011);   --Village of Notre-Dame-de-Lourdes
insert INTO mun_geo_gis values (463,165,'Rural Municipality',2011);   --RM of Ritchot
insert INTO mun_geo_gis values (464,138,'Rural Municipality',2011);   --RM of La Broquerie
insert INTO mun_geo_gis values (465,362,'Village',2011);   --Village of Somerset
insert INTO mun_geo_gis values (466,354,'Village',2011);   --Village of St. Claude
insert INTO mun_geo_gis values (467,351,'Town',2011);   --Town of Ste. Anne
insert INTO mun_geo_gis values (468,194,'Rural Municipality',2011);   --RM of Tache
insert INTO mun_geo_gis values (469,153,'Rural Municipality',2011);   --RM of Morton
insert INTO mun_geo_gis values (470,405,'Town',2011);   --Town of Boissevain
insert INTO mun_geo_gis values (471,101,'Rural Municipality',2011);   --RM of Archie
insert INTO mun_geo_gis values (472,199,'Rural Municipality',2011);   --RM of Wallace
insert INTO mun_geo_gis values (473,461,'Town',2011);   --Town of Virden
insert INTO mun_geo_gis values (474,313,'Village',2011);   --Village of Elkhorn
insert INTO mun_geo_gis values (475,120,'Rural Municipality',2011);   --RM of Dufferin
insert INTO mun_geo_gis values (476,409,'Town',2011);   --Town of Carman
insert INTO mun_geo_gis values (477,109,'Rural Municipality',2011);   --RM of Brenda
insert INTO mun_geo_gis values (478,205,'Rural Municipality',2011);   --RM of Winchester
insert INTO mun_geo_gis values (479,413,'Town',2011);   --Town of Deloraine
insert INTO mun_geo_gis values (480,367,'Village',2011);   --Village of Waskada
insert INTO mun_geo_gis values (481,110,'Rural Municipality',2011);   --RM of Brokenhead
insert INTO mun_geo_gis values (482,401,'Town',2011);   --Town of Beausejour
insert INTO mun_geo_gis values (483,603,'Town',2011);   --Town of Churchhill
insert INTO mun_geo_gis values (484,415,'Town',2011);   --Town of Emerson
insert INTO mun_geo_gis values (485,125,'Rural Municipality',2011);   --RM of Eriksdale
insert INTO mun_geo_gis values (486,105,'Rural Municipality',2011);   --RM of Bifrost
insert INTO mun_geo_gis values (487,129,'Rural Municipality',2011);   --RM of Gimli
insert INTO mun_geo_gis values (488,300,'Town',2011);   --Town of Arborg
insert INTO mun_geo_gis values (489,349,'Village',2011);   --Village of Riverton
insert INTO mun_geo_gis values (490,540,'City',2011);   --City of Flin Flon
-- insert INTO mun_geo_gis values (491,,'',2011);   --Flin Flon Ext. Boundaries (DOES NOT EXIST)
insert INTO mun_geo_gis values (492,447,'City',2011);   --City of Selkirk
insert INTO mun_geo_gis values (493,174,'Rural Municipality',2011);   --RM of St. Andrews
insert INTO mun_geo_gis values (494,176,'Rural Municipality',2011);   --RM of St. Clements
insert INTO mun_geo_gis values (495,131,'Rural Municipality',2011);   --RM of Glenwood
insert INTO mun_geo_gis values (496,449,'Town',2011);   --Town of Souris
insert INTO mun_geo_gis values (497,208,'Rural Municipality',2011);   --RM of Headingly
insert INTO mun_geo_gis values (498,451,'City',2011);   --City of Steinbach
insert INTO mun_geo_gis values (499,119,'Rural Municipality',2011);   --RM of DeSalaberry
insert INTO mun_geo_gis values (500,357,'Village',2011);   --Village of St. Pierre
insert INTO mun_geo_gis values (501,139,'Rural Municipality',2011);   --RM of Lac Du Bonnet
insert INTO mun_geo_gis values (502,333,'Town',2011);   --Town of Lac Du Bonnet
insert INTO mun_geo_gis values (503,167,'Rural Municipality',2011);   --RM of Roblin
insert INTO mun_geo_gis values (504,196,'Rural Municipality',2011);   --RM of Turtle Mountain
-- insert INTO mun_geo_gis values (505,,'',2011);   --Town of Killarney (DOES NOT EXIST)
insert INTO mun_geo_gis values (506,307,'Village',2011);   --Village of Cartwright
insert INTO mun_geo_gis values (507,428,'Town',2011);   --Town of Leaf Rapids
insert INTO mun_geo_gis values (508,343,'Town',2011);   --Town of Pilot Mound
insert INTO mun_geo_gis values (509,614,'Town',2011);   --Town of Lynn Lake
insert INTO mun_geo_gis values (510,161,'Rural Municipality',2011);   --RM of Pembina
insert INTO mun_geo_gis values (511,337,'Town',2011);   --Town of Manitou
insert INTO mun_geo_gis values (512,150,'Rural Municipality',2011);   --RM of Minto
insert INTO mun_geo_gis values (513,159,'Rural Municipality',2011);   --RM of Odanah
insert INTO mun_geo_gis values (514,431,'Town',2011);   --Town of Minnedosa
insert INTO mun_geo_gis values (515,156,'Rural Municipality',2011);   --RM of North Norfolk
insert INTO mun_geo_gis values (516,335,'Village',2011);   --Village of Macgregor
insert INTO mun_geo_gis values (517,193,'Rural Municipality',2011);   --RM of Swan River
insert INTO mun_geo_gis values (518,455,'Town',2011);   --Town of Swan River
insert INTO mun_geo_gis values (519,301,'Village',2011);   --Village of Benito
insert INTO mun_geo_gis values (520,617,'Rural Municipality',2011);   --RM of Mountain
insert INTO mun_geo_gis values (521,403,'Town',2011);   --Town of Birtle
insert INTO mun_geo_gis values (522,303,'Village',2011);   --Village of Bowsman
insert INTO mun_geo_gis values (523,411,'City',2011);   --City of Dauphin
insert INTO mun_geo_gis values (524,118,'Rural Municipality',2011);   --RM of Dauphin
insert INTO mun_geo_gis values (525,114,'Rural Municipality',2011);   --RM of Clanwilliam
insert INTO mun_geo_gis values (526,315,'Town',2011);   --Town of Erickson
insert INTO mun_geo_gis values (527,106,'Rural Municipality',2011);   --RM of Birtle
insert INTO mun_geo_gis values (528,128,'Rural Municipality',2011);   --RM of Gilbert Plains
insert INTO mun_geo_gis values (529,323,'Town',2011);   --Town of Gilbert Plains
insert INTO mun_geo_gis values (530,200,'Rural Municipality',2011);   --RM of Westbourne
insert INTO mun_geo_gis values (531,421,'Town',2011);   --Town of Gladstone
insert INTO mun_geo_gis values (532,132,'Rural Municipality',2011);   --RM of Grandview
insert INTO mun_geo_gis values (533,423,'Town',2011);   --Town of Grandview
insert INTO mun_geo_gis values (534,107,'Rural Municipality',2011);   --RM of Blanshard
insert INTO mun_geo_gis values (535,134,'Rural Municipality',2011);   --RM of Hamiota
insert INTO mun_geo_gis values (536,148,'Rural Municipality',2011);   --RM of Miniota
insert INTO mun_geo_gis values (537,331,'Town',2011);   --Town of Hamiota
insert INTO mun_geo_gis values (538,140,'Rural Municipality',2011);   --RM of Lakeview
insert INTO mun_geo_gis values (539,147,'Rural Municipality',2011);   --RM of McCreary
insert INTO mun_geo_gis values (540,336,'Village',2011);   --Village of McCreary
insert INTO mun_geo_gis values (541,149,'Rural Municipality',2011);   --RM of Minitonas
insert INTO mun_geo_gis values (542,339,'Town',2011);   --Town of Minitonas
insert INTO mun_geo_gis values (543,143,'Rural Municipality',2011);   --RM of Lawrence
insert INTO mun_geo_gis values (544,158,'Rural Municipality',2011);   --RM of Ochre River
insert INTO mun_geo_gis values (545,182,'Rural Municipality',2011);   --RM of Shell River
insert INTO mun_geo_gis values (546,444,'Town',2011);   --Town of Roblin
insert INTO mun_geo_gis values (547,123,'Rural Municipality',2011);   --RM of Ellice
insert INTO mun_geo_gis values (548,355,'Village',2011);   --Village of St. Lazare
insert INTO mun_geo_gis values (549,183,'Rural Municipality',2011);   --RM of Shoal Lake
insert INTO mun_geo_gis values (550,606,'Rural Municipality',2011);   --RM of Grahamdale
insert INTO mun_geo_gis values (551,185,'Rural Municipality',2011);   --RM of Siglunes
insert INTO mun_geo_gis values (552,191,'Rural Municipality',2011);   --RM of Strathclair
insert INTO mun_geo_gis values (553,154,'Rural Municipality',2011);   --RM of Mossey River
insert INTO mun_geo_gis values (554,371,'Village',2011);   --Village of Winnipegosis
insert INTO mun_geo_gis values (555,115,'Rural Municipality',2011);   --RM of Coldwell
-- insert INTO mun_geo_gis values (556,,'',2011);   --Peguis First Nation (DOES NOT EXIST)
insert INTO mun_geo_gis values (557,616,'Local Government District',2011);   --LGD of Pinawa
insert INTO mun_geo_gis values (558,550,'City',2011);	--City of Portage La Prairie
insert INTO mun_geo_gis values (559,163,'Rural Municipality',2011);	--RM of Portage
insert INTO mun_geo_gis values (560,117,'Rural Municipality',2011);   --RM of Daly
insert INTO mun_geo_gis values (561,443,'Town',2011);   --Town of Rivers
insert INTO mun_geo_gis values (562,102,'Rural Municipality',2011);   --RM of Argyle
insert INTO mun_geo_gis values (563,180,'Rural Municipality',2011);   --RM of Saskatchewan
insert INTO mun_geo_gis values (564,441,'Town',2011);   --Town of Rapid City
insert INTO mun_geo_gis values (565,100,'Rural Municipality',2011);   --RM of Albert
insert INTO mun_geo_gis values (566,162,'Rural Municipality',2011);   --RM of Pipestone
insert INTO mun_geo_gis values (567,171,'Rural Municipality',2011);   --RM of Rossburn
insert INTO mun_geo_gis values (568,353,'Town',2011);   --Town of Rossburn
insert INTO mun_geo_gis values (569,173,'Rural Municipality',2011);   --RM of Russell
insert INTO mun_geo_gis values (570,186,'Rural Municipality',2011);   --RM of Silver Creek
insert INTO mun_geo_gis values (571,445,'Town',2011);   --Town of Russell
insert INTO mun_geo_gis values (572,302,'Village',2011);   --Village of Binscarth
insert INTO mun_geo_gis values (573,448,'Town',2011);   --Town of Snow Lake
insert INTO mun_geo_gis values (574,463,'City',2011);   --City of Winkler
insert INTO mun_geo_gis values (575,164,'Rural Municipality',2011);   --RM of Rhineland
insert INTO mun_geo_gis values (576,190,'Rural Municipality',2011);   --RM of Stanley
insert INTO mun_geo_gis values (577,195,'Rural Municipality',2011);   --RM of Thompson
insert INTO mun_geo_gis values (578,400,'Town',2011);   --Town of Altona
insert INTO mun_geo_gis values (579,329,'Town',2011);   --Town of Gretna
insert INTO mun_geo_gis values (580,433,'Town',2011);   --Town of Morden
insert INTO mun_geo_gis values (581,345,'Town',2011);   --Town of Plum Coulee
insert INTO mun_geo_gis values (582,168,'Rural Municipality',2011);   --RM of Rockwood
insert INTO mun_geo_gis values (583,172,'Rural Municipality',2011);   --RM of Rosser
insert INTO mun_geo_gis values (584,453,'Town',2011);   --Town of Stonewall
insert INTO mun_geo_gis values (585,363,'Town',2011);   --Town of Teulon
insert INTO mun_geo_gis values (586,103,'Rural Municipality',2011);   --RM of Arthur
insert INTO mun_geo_gis values (587,122,'Rural Municipality',2011);   --RM of Edward
insert INTO mun_geo_gis values (588,429,'Town',2011);   --Town of Melita
insert INTO mun_geo_gis values (589,189,'Rural Municipality',2011);   --RM of Springfield
insert INTO mun_geo_gis values (590,179,'Rural Municipality',2011);   --RM of Ste. Rose du Lac
insert INTO mun_geo_gis values (591,359,'Town',2011);   --Town of Ste. Rose du Lac
insert INTO mun_geo_gis values (592,604,'Rural Municipality',2011);   --RM of Kelsey
insert INTO mun_geo_gis values (593,457,'Town',2011);   --Town of The Pas
insert INTO mun_geo_gis values (594,560,'City',2011);   --City of Thompson
-- insert INTO mun_geo_gis values (595,,'',2011);   --Chemawawin (DOES NOT EXIST)
-- insert INTO mun_geo_gis values (596,,'',2011);   --Norway House (DOES NOT EXIST)
insert INTO mun_geo_gis values (597,152,'Rural Municipality',2011);   --RM of Morris
insert INTO mun_geo_gis values (598,435,'Town',2011);   --Town of Morris
insert INTO mun_geo_gis values (599,197,'Rural Municipality',2011);   --RM of Victoria
insert INTO mun_geo_gis values (600,500,'City',2011);	--City of Brandon
insert INTO mun_geo_gis values (601,111,'Rural Municipality',2011);   --RM of Cameron
insert INTO mun_geo_gis values (602,141,'Rural Municipality',2011);   --RM of Langford
insert INTO mun_geo_gis values (603,155,'Rural Municipality',2011);	--RM of North Cypress
insert INTO mun_geo_gis values (604,187,'Rural Municipality',2011);	--RM of South Cypress
insert INTO mun_geo_gis values (605,407,'Town',2011);	--Town of Carberry
insert INTO mun_geo_gis values (606,425,'Town',2011);   --Town of Hartney
insert INTO mun_geo_gis values (607,437,'Town',2011);   --Town of Neepawa
insert INTO mun_geo_gis values (608,325,'Village',2011);   --Village of Glenboro
insert INTO mun_geo_gis values (609,0,'City',2011);	--City of Winnipeg

insert INTO mun_geo_gis values (903,145,'Rural Municipality',2015);	--RM of Lorne
insert INTO mun_geo_gis values (904,145,'Rural Municipality',2015);	--RM of Louise
insert INTO mun_geo_gis values (869,133,'Rural Municipality',2015);   --RM of Grey
-- insert INTO mun_geo_gis values (872,,'',2015);   --Municipality of Boissevain-Morton
insert INTO mun_geo_gis values (883,127,'Rural Municipality',2015);   --Municipality of Emerson-Franklin
-- insert INTO mun_geo_gis values (884,,'',2015);   --RM of West Interlake
-- =insert INTO mun_geo_gis values (889,,'',2015);   --Flin Flon Extended Boundaries
-- insert INTO mun_geo_gis values (900,,'',2015);   --Cartwright-Roblin Municipality
insert INTO mun_geo_gis values (901,196,'Rural Municipality',2015);   --RM of Killarney-Turle Mountain
-- insert INTO mun_geo_gis values (910,,'',2015);   --Municipality of Swan Valley West