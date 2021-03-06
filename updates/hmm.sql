create table symbol_to_library_system (
       symbol varchar(10),
       library_id integer,
       municipality_id integer
);
insert into symbol_to_library_system (symbol, library_id, municipality_id) values
('MGI',
	(select id from libraries where name='Bette Winner Public Library'),
	(select id from municipalities where name='Town of Gillam')),
('MSTG',
	(select id from libraries where name='Bibliothèque Allard Regional Library'),
	(select id from municipalities where name='RM of Alexander')),
('MBBB',
	(select id from libraries where name='Bibliothèque Allard Regional Library'),
	(select id from municipalities where name='Town of Powerview/Pine Falls')),
('MVBB',
	(select id from libraries where name='Bibliothèque Allard Regional Library'),
	(select id from municipalities where name='RM of Victoria Beach')),
('MSJB',
	(select id from libraries where name='Bibliothèque Montcalm Library'),
	(select id from municipalities where name='RM of Montcalm')),
('MNDP',
	(select id from libraries where name='Lorne Library Services'),
	(select id from municipalities where name='Municipality of Lorne')),
('MIBR',
	(select id from libraries where name='Bibliothèque Ritchot Library'),
	(select id from municipalities where name='RM of Ritchot')),
('MSAD',
	(select id from libraries where name='Bibliothèque Ritchot Library'),
	(select id from municipalities where name='RM of Ritchot')),
('MSAG',
	(select id from libraries where name='Bibliothèque Ritchot Library'),
	(select id from municipalities where name='RM of Ritchot')),
('MLB',
	(select id from libraries where name='Bibliothèque Saint-Joachim Library'),
	(select id from municipalities where name='RM of La Broquerie')),
('MS',
	(select id from libraries where name='Lorne Library Services'),
	(select id from municipalities where name='Municipality of Lorne')),
('MSCL',
	(select id from libraries where name='Bibliothèque St. Claude Library'),
	(select id from municipalities where name='RM of Grey')),
('MSA',
	(select id from libraries where name='Bibliothèque Ste Anne Library'),
	(select id from municipalities where name='Town of Ste. Anne')),
('MTPL',
	(select id from libraries where name='Bibliothèque Taché  Library'),
	(select id from municipalities where name='RM of Tache')),
('MBOM',
	(select id from libraries where name='Boissevain & Morton Regional Library'),
	(select id from municipalities where name='Municipality of Boissevain-Morton')),
('MVE',
	(select id from libraries where name='Border Regional Library'),
	(select id from municipalities where name='Town of Virden')),
('ME',
	(select id from libraries where name='Border Regional Library'),
	(select id from municipalities where name='RM of Wallace-Woodworth')),
('MMCA',
	(select id from libraries where name='Border Regional Library'),
	(select id from municipalities where name='Municipality of Ellice-Archie')),
('MCB',
	(select id from libraries where name='Boyne Regional Library'),
	(select id from municipalities where name='Town of Carman')),
('MDB',
	(select id from libraries where name='Bren Del Win Centennial Library'),
	(select id from municipalities where name='Municipality of Deloraine-Winchester')),
('TWAS',
	(select id from libraries where name='Bren Del Win Centennial Library'),
	(select id from municipalities where name='RM of Brenda-Waskada')),
('MBBR',
	(select id from libraries where name='Brokenhead River Regional Library'),
	(select id from municipalities where name='Town of Beausejour')),
('MCH',
	(select id from libraries where name='Churchill Public Library'),
	(select id from municipalities where name='Town of Churchill')),
('MEPL',
	(select id from libraries where name='Emerson Public Library'),
	(select id from municipalities where name='Municipality of Emerson-Franklin')),
('MEL',
	(select id from libraries where name='Eriksdale Public Library'),
	(select id from municipalities where name='RM of West Interlake')),
('MGE',
	(select id from libraries where name='Evergreen Regional Library'),
	(select id from municipalities where name='RM of Gimli')),
('MAB',
	(select id from libraries where name='Evergreen Regional Library'),
	(select id from municipalities where name='Town of Arborg')),
('MRB',
	(select id from libraries where name='Evergreen Regional Library'),
	(select id from municipalities where name='RM of Bifrost-Riverton')),
('MFF',
	(select id from libraries where name='Flin Flon Public Library'),
	(select id from municipalities where name='City of Flin Flon')),
('MSEL',
	(select id from libraries where name='Gaynor Family Regional Library'),
	(select id from municipalities where name='City of Selkirk')),
('MSOG',
	(select id from libraries where name='Glenwood & Souris Regional Library'),
	(select id from municipalities where name='Municipality of Souris-Glenwood')),
('MHH',
	(select id from libraries where name='Headingley Municipal Library'),
	(select id from municipalities where name='RM of Headingley')),
('MSTE',
	(select id from libraries where name='Jake Epp Library'),
	(select id from municipalities where name='City of Steinbach')),
('MSTP',
	(select id from libraries where name='Jolys Regional Library'),
	(select id from municipalities where name='Village of St. Pierre-Jolys')),
('MSSM',
	(select id from libraries where name='Jolys Regional Library'),
	(select id from municipalities where name='RM of DeSalaberry')),
('MLDB',
	(select id from libraries where name='Lac Du Bonnet Regional Library'),
	(select id from municipalities where name='Town of Lac Du Bonnet')),
('MKL',
	(select id from libraries where name='Lakeland Regional Library'),
	(select id from municipalities where name='RM of Killarney-Turtle Mountain')),
('MCCB',
	(select id from libraries where name='Lakeland Regional Library'),
	(select id from municipalities where name='Cartwright-Roblin Municipality')),
('MLR',
	(select id from libraries where name='Leaf Rapids Public Library'),
	(select id from municipalities where name='Town of Leaf Rapids')),
('MPM',
	(select id from libraries where name='Louise Public Library'),
	(select id from municipalities where name='Municipality of Louise')),
('MLLC',
	(select id from libraries where name='Lynn Lake Centennial Library'),
	(select id from municipalities where name='Town of Lynn Lake')),
('MMA',
	(select id from libraries where name='Manitou Regional Library'),
	(select id from municipalities where name='RM of Pembina')),
('MMR',
	(select id from libraries where name='Minnedosa Regional Library'),
	(select id from municipalities where name='Town of Minnedosa')),
('MMNN',
	(select id from libraries where name='North Norfolk-MacGregor Regional Library'),
	(select id from municipalities where name='Municipality of North Norfolk')),
('MSRN',
	(select id from libraries where name='North-West Regional Library'),
	(select id from municipalities where name='Town of Swan River')),
('MBB',
	(select id from libraries where name='North-West Regional Library'),
	(select id from municipalities where name='Municipality of Swan Valley West')),
('MDP',
	(select id from libraries where name='Parkland Regional Library'),
	null),
('MDPBR',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='RM of Mountain')),
('MDPBI',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='Prairie View Municipality')),
('MDPBO',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='Municipality of Minitonas-Bowsman')),
('MDA',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='City of Dauphin')),
('MDPER',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='Municipality of Clanwilliam-Erickson')),
('MDPFO',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='Prairie View Municipality')),
('MDPGP',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='Gilbert Plains Municipality')),
('MDPGL',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='RM of Westlake-Gladstone')),
('MDPGV',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='Grandview Municipality')),
('MDPHA',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='Hamiota Municipality')),
('MDPLA',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='RM of Westlake-Gladstone')),
('MDPMC',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='Municipality of McCreary')),
('MDPMI',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='Municipality of Minitonas-Bowsman')),
('MDPOR',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='RM of Lakeshore')),
('MDPRO',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='Hillsburg-Roblin-Shell River')),
('MDPSLA',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='RM of Ellice-Archie')),
('MDPSL',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='RM of Yellowhead')),
('MDPSI',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='RM of West Interlake')),
('MDPST',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='RM of Yellowhead')),
('MDPWP',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='RM of Mossey River')),
('MRO',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='Rossburn Municipality')),
('MSTR',
	(select id from libraries where name='Parkland Regional Library'),
	(select id from municipalities where name='Municipality of Ste. Rose')),
('MLPJ',
	(select id from libraries where name='Pauline Johnson Library'),
	(select id from municipalities where name='RM of Coldwell')),
('MPFN',
	(select id from libraries where name='Peguis First Nation Public Library'),
	(select id from municipalities where name='Peguis First Nation')),
('MP',
	(select id from libraries where name='Pinawa Public Library'),
	(select id from municipalities where name='LGD of Pinawa')),
('MPLP',
	(select id from libraries where name='Portage la Prairie Regional Library'),
	(select id from municipalities where name='City of Portage La Prairie')),
('MRIP',
	(select id from libraries where name='Prairie Crocus Regional Library'),
	(select id from municipalities where name='Riverdale Municipality')),
('MBA',
	(select id from libraries where name='RM of Argyle Public Library'),
	(select id from municipalities where name='RM of Argyle')),
('MRA',
	(select id from libraries where name='Rapid City Regional Library'),
	(select id from municipalities where name='RM of Oakview')),
('MRP',
	(select id from libraries where name='Reston District Library'),
	(select id from municipalities where name='RM of Pipestone')),
('MRD',
	(select id from libraries where name='Russell & District Regional Library'),
	(select id from municipalities where name='Municipality of Russell-Binscarth')),
('MBI',
	(select id from libraries where name='Russell & District Regional Library'),
	(select id from municipalities where name='Municipality of Russell-Binscarth')),
('MSL',
	(select id from libraries where name='Snow Lake Community Library'),
	(select id from municipalities where name='Town of Snow Lake')),
('MWOWH',
	(select id from libraries where name='South Central Regional Library'),
	null), -- South Central, HQ
('MAOW',
	(select id from libraries where name='South Central Regional Library'),
	(select id from municipalities where name='Town of Altona')),
('MMIOW',
	(select id from libraries where name='South Central Regional Library'),
	(select id from municipalities where name='RM of Thompson')),
('MMOW',
	(select id from libraries where name='South Central Regional Library'),
	(select id from municipalities where name='City of Morden')),
('MWOW',
	(select id from libraries where name='South Central Regional Library'),
	(select id from municipalities where name='City of Winkler')),
('MSTOS',
	(select id from libraries where name='South Interlake Regional Library'),
	(select id from municipalities where name='Town of Stonewall')),
('MTSIR',
	(select id from libraries where name='South Interlake Regional Library'),
	(select id from municipalities where name='Town of Teulon')),
('MESM',
	(select id from libraries where name='Southwestern Manitoba Regional Library'),
	(select id from municipalities where name='Town of Melita')),
('MESMN',
	(select id from libraries where name='Southwestern Manitoba Regional Library'),
	(select id from municipalities where name='RM of Brenda-Waskada')),
('MESP',
	(select id from libraries where name='Southwestern Manitoba Regional Library'),
	(select id from municipalities where name='Municipality of Two Borders')),
('MDS',
	(select id from libraries where name='Springfield Public Library'),
	(select id from municipalities where name='RM of Springfield')),
('MTP',
	(select id from libraries where name='The Pas Regional Library'),
	(select id from municipalities where name='Town of The Pas')),
('MTH',
	(select id from libraries where name='Thompson Public Library'),
	(select id from municipalities where name='City of Thompson')),
('MEC',
	(select id from libraries where name='UCN Chemawawin Public Library'),
	(select id from municipalities where name='Chemawawin')),
('MNH',
	(select id from libraries where name='UCN Norway House Public Library'),
	(select id from municipalities where name='Norway House')),
('MMVR',
	(select id from libraries where name='Valley Regional Library'),
	(select id from municipalities where name='Town of Morris')),
('MHP',
	(select id from libraries where name='Victoria Municipal Library'),
	(select id from municipalities where name='RM of Victoria')),
('MBW',
	(select id from libraries where name='Western Manitoba Regional Library'),
	(select id from municipalities where name='City of Dauphin')),
('MCNC',
	(select id from libraries where name='Western Manitoba Regional Library'),
	(select id from municipalities where name='Town of Carberry')),
('MGW',
	(select id from libraries where name='Western Manitoba Regional Library'),
	(select id from municipalities where name='Municipality of Glenboro-South Cypress')),
('MHW',
	(select id from libraries where name='Western Manitoba Regional Library'),
	(select id from municipalities where name='Municipality of Grassland')),
('MNW',
	(select id from libraries where name='Western Manitoba Regional Library'),
	(select id from municipalities where name='Town of Neepawa')),
('MW',
	(select id from libraries where name='Winnipeg Public Library'),
	null),    -- Winnipeg (with made-up branch symbols)
('MWCH',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  Charlsewood
('MWCO',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  Cornish
('MWFG',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  Fort Garry
('MWHE',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  Henderson
('MWLR',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  Louis Riel
('MWMU',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  Munroe
('MWPT',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  Pembina Trail
('MWOS',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  Osborne
('MWMI',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  Millennium
('MWRH',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  River Heights
('MWWS',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  Sir William Stephenson
('MWSB',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  St. Boniface
('MWSJA',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  St. James-Assiniboia
('MWSJ',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  St. John's
('MWSV',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  St. Vital
('MWTR',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  Transcona
('MWWE',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  West End
('MWWK',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  West Kildonan
('MWWW',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg')),
	--  Westwood
('MWWP',
	(select id from libraries where name='Winnipeg Public Library'),
	(select id from municipalities where name='City of Winnipeg'))
	--  Windsor Park
;
