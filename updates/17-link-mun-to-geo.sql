-- 17.link-mun-to-geo.sql
create table mun_geo (municipality_id integer not null, geo_municipality_gid integer not null);
create index mun_geo_idx on mun_geo (municipality_id, geo_municipality_gid);

begin;

insert into mun_geo (municipality_id, geo_municipality_gid) select id, 1 from municipalities where name='Town of Churchill';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 2 from municipalities where name='Town of Lynn Lake';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 3 from municipalities where name='Town of Gillam';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 4 from municipalities where name='Town of Leaf Rapids';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 6 from municipalities where name='Town of Snow Lake';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 7 from municipalities where name='City of Flin Flon';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 7 from municipalities where name='Flin Flon Ext. Boundaries';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 7 from municipalities where name='Flin Flon Extended Boundaries';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 8 from municipalities where name='RM of Kelsey';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 9 from municipalities where name='Town of The Pas';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 11 from municipalities where name='RM of Mountain';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 12 from municipalities where name='Municipality of Swan Valley West';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 12 from municipalities where name='RM of Swan River';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 13 from municipalities where name='Municipality of Minitonas-Bowsman';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 13 from municipalities where name='RM of Minitonas';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 14 from municipalities where name='Municipality of Minitonas-Bowsman';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 14 from municipalities where name='Village of Bowsman';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 15 from municipalities where name='Town of Swan River';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 16 from municipalities where name='Municipality of Minitonas-Bowsman';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 16 from municipalities where name='Town of Minitonas';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 17 from municipalities where name='RM of Mossey River';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 18 from municipalities where name='Municipality of Swan Valley West';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 18 from municipalities where name='Village of Benito';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 19 from municipalities where name='RM of Grahamdale';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 21 from municipalities where name='Village of Winnipegosis';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 22 from municipalities where name='Hillsburg-Roblin-Shell River';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 22 from municipalities where name='RM of Shell River';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 24 from municipalities where name='RM of Lakeshore';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 24 from municipalities where name='RM of Lawrence';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 25 from municipalities where name='Hillsburg-Roblin-Shell River';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 26 from municipalities where name='RM of Dauphin';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 28 from municipalities where name='Grandview Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 28 from municipalities where name='RM of Grandview';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 29 from municipalities where name='Gilbert Plains Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 29 from municipalities where name='RM of Gilbert Plains';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 30 from municipalities where name='RM of Bifrost';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 30 from municipalities where name='RM of Bifrost-Riverton';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 32 from municipalities where name='Hillsburg-Roblin-Shell River';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 32 from municipalities where name='Town of Roblin';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 33 from municipalities where name='RM of Siglunes';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 33 from municipalities where name='RM of West Interlake';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 34 from municipalities where name='Grandview Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 34 from municipalities where name='Town of Grandview';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 35 from municipalities where name='RM of Lakeshore';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 35 from municipalities where name='RM of Ochre River';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 36 from municipalities where name='Municipality of Ste. Rose du Lac';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 36 from municipalities where name='RM of Ste. Rose du Lac';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 37 from municipalities where name='City of Dauphin';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 38 from municipalities where name='Gilbert Plains Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 38 from municipalities where name='Town of Gilbert Plains';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 40 from municipalities where name='Municipality of Ste. Rose du Lac';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 40 from municipalities where name='Town of Ste. Rose du Lac';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 41 from municipalities where name='RM of Bifrost-Riverton';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 41 from municipalities where name='Village of Riverton';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 42 from municipalities where name='RM of Eriksdale';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 42 from municipalities where name='RM of West Interlake';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 43 from municipalities where name='Town of Arborg';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 44 from municipalities where name='Municipality of Russell-Binscarth';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 44 from municipalities where name='RM of Russell';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 45 from municipalities where name='RM of Silver Creek';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 46 from municipalities where name='RM of Rossburn';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 46 from municipalities where name='Rossburn Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 48 from municipalities where name='Municipality of McCreary';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 48 from municipalities where name='RM of McCreary';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 49 from municipalities where name='RM of Gimli';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 50 from municipalities where name='Municipality of Russell-Binscarth';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 50 from municipalities where name='Town of Russell';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 51 from municipalities where name='RM of Victoria Beach';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 52 from municipalities where name='Municipality of McCreary';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 52 from municipalities where name='Village of McCreary';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 53 from municipalities where name='RM of Coldwell';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 55 from municipalities where name='RM of Alexander';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 56 from municipalities where name='Rossburn Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 56 from municipalities where name='Town of Rossburn';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 57 from municipalities where name='Municipality of Russell-Binscarth';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 57 from municipalities where name='Village of Binscarth';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 58 from municipalities where name='RM of Rossburn';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 60 from municipalities where name='Municipality of Ellice-Archie';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 60 from municipalities where name='RM of Ellice';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 61 from municipalities where name='Prairie View Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 61 from municipalities where name='RM of Birtle';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 62 from municipalities where name='Town of Powerview/Pine Falls';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 63 from municipalities where name='RM of Shoal Lake';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 63 from municipalities where name='RM of Yellowhead';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 64 from municipalities where name='RM of St. Clements';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 65 from municipalities where name='RM of Strathclair';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 65 from municipalities where name='RM of Yellowhead';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 68 from municipalities where name='Municipality of Clanwilliam-Erickson';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 68 from municipalities where name='RM of Clanwilliam';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 70 from municipalities where name='RM of St. Andrews';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 71 from municipalities where name='RM of Rockwood';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 72 from municipalities where name='Municipality of Clanwilliam-Erickson';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 72 from municipalities where name='Town of Erickson';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 73 from municipalities where name='RM of Lakeview';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 73 from municipalities where name='RM of Westlake-Gladstone';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 75 from municipalities where name='RM of Westbourne';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 75 from municipalities where name='RM of Westlake-Gladstone';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 77 from municipalities where name='Municipality of Ellice-Archie';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 77 from municipalities where name='Village of St. Lazare';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 78 from municipalities where name='Prairie View Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 78 from municipalities where name='Town of Birtle';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 80 from municipalities where name='RM of Lac Du Bonnet';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 82 from municipalities where name='RM of Minto';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 83 from municipalities where name='Town of Teulon';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 84 from municipalities where name='Municipality of Ellice-Archie';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 84 from municipalities where name='RM of Archie';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 85 from municipalities where name='Prairie View Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 85 from municipalities where name='RM of Miniota';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 86 from municipalities where name='Hamiota Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 86 from municipalities where name='RM of Hamiota';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 87 from municipalities where name='RM of Blanshard';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 87 from municipalities where name='RM of Oakview';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 88 from municipalities where name='RM of Oakview';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 88 from municipalities where name='RM of Saskatchewan';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 89 from municipalities where name='RM of Brokenhead';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 90 from municipalities where name='RM of Portage';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 90 from municipalities where name='RM of Portage La Prairie';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 91 from municipalities where name='Town of Lac Du Bonnet';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 92 from municipalities where name='Town of Minnedosa';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 93 from municipalities where name='LGD of Pinawa';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 94 from municipalities where name='Town of Neepawa';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 95 from municipalities where name='RM of Minto-Odanah';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 95 from municipalities where name='RM of Odanah';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 96 from municipalities where name='Municipality of North Cypress-Langford';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 96 from municipalities where name='RM of Langford';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 97 from municipalities where name='RM of Westlake-Gladstone';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 97 from municipalities where name='Town of Gladstone';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 98 from municipalities where name='Hamiota Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 98 from municipalities where name='Town of Hamiota';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 99 from municipalities where name='City of Selkirk';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 101 from municipalities where name='Town of Stonewall';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 103 from municipalities where name='RM of Oakview';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 103 from municipalities where name='Town of Rapid City';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 104 from municipalities where name='Town of Beausejour';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 105 from municipalities where name='RM of Wallace';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 105 from municipalities where name='RM of Wallace-Woodworth';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 107 from municipalities where name='RM of Springfield';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 109 from municipalities where name='RM of Wallace-Woodworth';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 110 from municipalities where name='RM of Rosser';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 111 from municipalities where name='Riverdale Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 111 from municipalities where name='RM of Daly';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 113 from municipalities where name='Municipality of North Cypress-Langford';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 113 from municipalities where name='RM of North Cypress';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 114 from municipalities where name='Municipality of North Norfolk';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 114 from municipalities where name='RM of North Norfolk';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 116 from municipalities where name='Riverdale Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 116 from municipalities where name='Town of Rivers';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 118 from municipalities where name='City of Winnipeg';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 119 from municipalities where name='RM of Wallace-Woodworth';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 119 from municipalities where name='Village of Elkhorn';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 120 from municipalities where name='City of Portage La Prairie';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 121 from municipalities where name='Municipality of North Norfolk';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 121 from municipalities where name='Town of Macgregor';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 121 from municipalities where name='Village of Macgregor';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 122 from municipalities where name='RM of Headingley';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 123 from municipalities where name='City of Brandon';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 125 from municipalities where name='Town of Virden';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 127 from municipalities where name='Town of Carberry';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 129 from municipalities where name='RM of Tache';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 130 from municipalities where name='RM of Pipestone';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 131 from municipalities where name='RM of Ritchot';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 133 from municipalities where name='RM of Grey';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 135 from municipalities where name='Municipality of Glenboro-South Cypress';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 135 from municipalities where name='RM of South Cypress';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 136 from municipalities where name='RM of Victoria';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 139 from municipalities where name='Municipality of Souris-Glenwood';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 139 from municipalities where name='RM of Glenwood';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 141 from municipalities where name='Town of Ste. Anne';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 142 from municipalities where name='Village of St. Claude';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 144 from municipalities where name='Municipality of Souris-Glenwood';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 144 from municipalities where name='Town of Souris';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 147 from municipalities where name='RM of Dufferin';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 149 from municipalities where name='City of Steinbach';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 150 from municipalities where name='Municipality of Glenboro-South Cypress';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 150 from municipalities where name='Village of Glenboro';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 151 from municipalities where name='RM of La Broquerie';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 152 from municipalities where name='Municipality of Two Borders';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 152 from municipalities where name='RM of Albert';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 153 from municipalities where name='RM of DeSalaberry';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 154 from municipalities where name='Municipality of Grassland';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 154 from municipalities where name='RM of Cameron';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 155 from municipalities where name='RM of Morris';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 156 from municipalities where name='Municipality of Lorne';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 156 from municipalities where name='Village of Notre-Dame-de-Lourdes';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 157 from municipalities where name='Municipality of Grassland';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 160 from municipalities where name='Municipality of Lorne';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 161 from municipalities where name='RM of Argyle';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 162 from municipalities where name='Town of Carman';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 163 from municipalities where name='Municipality of Grassland';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 163 from municipalities where name='Town of Hartney';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 164 from municipalities where name='RM of Thompson';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 165 from municipalities where name='Village of St. Pierre';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 165 from municipalities where name='Village of St. Pierre-Jolys';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 168 from municipalities where name='Municipality of Lorne';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 168 from municipalities where name='Village of Somerset';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 169 from municipalities where name='Municipality of Two Borders';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 169 from municipalities where name='RM of Edward';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 170 from municipalities where name='Town of Morris';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 171 from municipalities where name='Municipality of Two Borders';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 171 from municipalities where name='RM of Arthur';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 172 from municipalities where name='RM of Brenda';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 172 from municipalities where name='RM of Brenda-Waskada';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 173 from municipalities where name='RM of Montcalm';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 174 from municipalities where name='Municipality of Deloraine-Winchester';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 174 from municipalities where name='RM of Winchester';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 175 from municipalities where name='Municipality of Boissevain-Morton';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 175 from municipalities where name='RM of Morton';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 176 from municipalities where name='RM of Killarney-Turtle Mountain';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 176 from municipalities where name='RM of Turtle Mountain';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 176 from municipalities where name='Town of Killarney';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 177 from municipalities where name='RM of Pembina';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 178 from municipalities where name='Municipality of Louise';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 180 from municipalities where name='Town of Melita';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 181 from municipalities where name='Municipality of Emerson-Franklin';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 182 from municipalities where name='Municipality of Rhineland';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 182 from municipalities where name='RM of Rhineland';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 183 from municipalities where name='RM of Stanley';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 184 from municipalities where name='Cartwright-Roblin Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 184 from municipalities where name='Municipality of Roblin';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 184 from municipalities where name='RM of Roblin';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 185 from municipalities where name='Town of Manitou';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 186 from municipalities where name='Municipality of Boissevain-Morton';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 186 from municipalities where name='Town of Boissevain';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 187 from municipalities where name='City of Morden';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 187 from municipalities where name='Town of Morden';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 188 from municipalities where name='Municipality of Deloraine-Winchester';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 188 from municipalities where name='Town of Deloraine';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 189 from municipalities where name='Municipality of Louise';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 189 from municipalities where name='Town of Pilot Mound';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 190 from municipalities where name='Municipality of Rhineland';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 190 from municipalities where name='Town of Plum Coulee';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 191 from municipalities where name='City of Winkler';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 192 from municipalities where name='Municipality of Louise';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 193 from municipalities where name='Town of Altona';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 194 from municipalities where name='RM of Brenda-Waskada';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 194 from municipalities where name='Village of Waskada';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 195 from municipalities where name='Cartwright-Roblin Municipality';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 195 from municipalities where name='Village of Cartwright';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 196 from municipalities where name='Municipality of Emerson-Franklin';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 196 from municipalities where name='Town of Emerson';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 197 from municipalities where name='Municipality of Rhineland';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 197 from municipalities where name='Town of Gretna';
insert into mun_geo (municipality_id, geo_municipality_gid) select id, 198 from municipalities where name='City of Thompson';

commit;
