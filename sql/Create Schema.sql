use Geocaches;

create table point_types (
	typeid int not null constraint pk_point_types primary key,
	typename varchar(16) not null
);

create table cache_sizes (
	sizeid int not null constraint pk_cache_sizes primary key,
	sizename varchar(16)
);

create table countries (
	countryid int not null constraint pk_countries primary key,
	name nvarchar(50)
);

create table states (
	stateid int not null constraint pk_states primary key,
	name nvarchar(50)
);

create table caches (
	cacheid varchar(8) not null constraint pk_caches primary key,
	gsid int not null,
	cachename nvarchar(50) not null,
	latitude float not null,
	longitude float not null,
	latlong geography not null,
	lastupdated datetime not null default getdate(),
	placed date not null,
	placedby nvarchar(50) not null,
	typeid int not null,
	sizeid int not null,
	difficulty float not null,
	terrain float not null,
	countryid int not null,
	stateid int,
	shortdesc nvarchar(500) not null, /* Matches geocaching.com maximum length */
	longdesc ntext not null,
	hint nvarchar(1000) NULL,
	available bit not null default 1,
	archived bit not null default 0,
	webpage nvarchar(2083), /* Maximum length in IE. geocaching.com allows only 100 characters */
	premiumonly bit not null default 0
	constraint fk_cache_type foreign key (typeid) references point_types (typeid),
	constraint fk_cache_size foreign key (sizeid) references cache_sizes (sizeid),
	constraint fk_country foreign key (countryid) references countries (countryid),
	constraint fk_state foreign key (stateid) references states (stateid)
);
create table attributes (
	attributeid int not null constraint pk_attributes primary key,
	attributename varchar(50) not null
);
create table cache_attributes (
	cacheid varchar(8) not null,
	attributeid int not null,
	attribute_applies bit default 1 /* Attributes can be tagged to a cache as "yes" or "no". For example a cache may have the "poisonous plants" attribute set, but flagged as "no poisonous plants" indicating that there isn't poison ivy at a cache site. If the inc attribute of the <groundspeak:attribute> element is 1, this indicates "yes".*/
	constraint fk_attr_cacheid foreign key (cacheid) references caches (cacheid),
	constraint fk_attr_id foreign key (attributeid) references attributes (attributeid)
);
create table cachers  (
	cacherid int not null constraint pk_cachers primary key,
	cachername varchar(50) not null
);
create table cache_owners (
	cacheid varchar(8) constraint pk_cache_owners primary key,
	cacherid int
	constraint fk_owner_cacheid foreign key (cacheid) references caches (cacheid),
	constraint fk_owner_cacher foreign key (cacheid) references caches (cacheid)
);
create table waypoints (
	waypointid varchar(8) not null constraint pk_waypoints primary key,
	parentcache varchar(8) not null,
	latitude float not null,
	longitude float not null,
	latlong geography not null,
	typeid int,
	[name] varchar(50) not null,
	description varchar(2000) not null,
	url varchar(2038) not null,
	lookupcode nvarchar(6)
	constraint fk_waypoint_cacheid foreign key (parentcache) references caches (cacheid),
	constraint fk_waypoint_type foreign key (typeid) references point_types (typeid)
);

create table log_types (
	logtypeid int not null constraint pk_log_types primary key,
	logtypedesc varchar(20) not null
);

create table logs (
	logid bigint not null constraint pk_logs primary key,
	logdate datetime not null,
	logtypeid int not null,
	cacherid int not null,
	logtext nvarchar(4000),
	latitude float null,
	longitude float null,
	latlong geography null,
	constraint fk_logtype foreign key (logtypeid) references log_types (logtypeid),
	constraint fk_cacher foreign key (cacherid) references cachers (cacherid)
);
create table cache_logs (
	cacheid varchar(8) not null,
	logid bigint not null,
	constraint fk_log_cacheid foreign key (cacheid) references caches (cacheid),
	constraint fk_log_logid foreign key (logid) references logs (logid),
	constraint pk_cache_logs primary key (cacheid,logid)
);
create table travelbugs (
	tbpublicid varchar(8) not null constraint pk_travelbugs primary key,
	tbinternalid int not null,
	tbname varchar(50) not null
);

create table tbinventory (
	cacheid varchar(8) not null,
	tbpublicid varchar(8) not null,
	constraint fk_tb_id foreign key (tbpublicid) references travelbugs (tbpublicid),
	constraint fk_cacheid foreign key (cacheid) references caches (cacheid),
	constraint pk_tbinventory primary key (cacheid,tbpublicid)
);

create table CenterPoints  (
	Locationname varchar(20) not null,
	LocationGeo geography not null
	constraint pk_centerpoints primary key (Locationname)
);

/* IDs & names taken from geocaching.com new listing form */
insert into cache_sizes (sizeid, sizename) values (1, 'Not Listed');
insert into cache_sizes (sizeid, sizename) values (2, 'Micro');
insert into cache_sizes (sizeid, sizename) values (8, 'Small');
insert into cache_sizes (sizeid, sizename) values (3, 'Regular');
insert into cache_sizes (sizeid, sizename) values (4, 'Large');
insert into cache_sizes (sizeid, sizename) values (6, 'Other');

insert into point_types (typeid, typename) values (1, 'Traditional Cache');
insert into point_types (typeid, typename) values (3, 'Multi-cache');
insert into point_types (typeid, typename) values (5, 'Letterbox Hybrid');
insert into point_types (typeid, typename) values (6, 'Event Cache');
insert into point_types (typeid, typename) values (8, 'Unknown Cache');
insert into point_types (typeid, typename) values (13, 'Cache In Trash Out Event');
insert into point_types (typeid, typename) values (137, 'Earthcache');
insert into point_types (typeid, typename) values (1858, 'Wherigo Cache');
/* Still need virtuals & other retired cache types */
insert into point_types (typeid, typename) values (220, 'Final Location');
insert into point_types (typeid, typename) values (217, 'Parking Area');
insert into point_types (typeid, typename) values (218, 'Question to Answer');
insert into point_types (typeid, typename) values (452, 'Reference Point');
insert into point_types (typeid, typename) values (219, 'Stages of a Multicache');
insert into point_types (typeid, typename) values (221, 'Trailhead');

insert into countries (countryid, name) values (12, 'Afghanistan');
insert into countries (countryid, name) values (272, 'Aland Islands');
insert into countries (countryid, name) values (244, 'Albania');
insert into countries (countryid, name) values (14, 'Algeria');
insert into countries (countryid, name) values (245, 'American Samoa');
insert into countries (countryid, name) values (16, 'Andorra');
insert into countries (countryid, name) values (17, 'Angola');
insert into countries (countryid, name) values (246, 'Anguilla');
insert into countries (countryid, name) values (18, 'Antarctica');
insert into countries (countryid, name) values (13, 'Antigua and Barbuda');
insert into countries (countryid, name) values (19, 'Argentina');
insert into countries (countryid, name) values (15, 'Armenia');
insert into countries (countryid, name) values (20, 'Aruba');
insert into countries (countryid, name) values (3, 'Australia');
insert into countries (countryid, name) values (227, 'Austria');
insert into countries (countryid, name) values (21, 'Azerbaijan');
insert into countries (countryid, name) values (23, 'Bahamas');
insert into countries (countryid, name) values (29, 'Bahrain');
insert into countries (countryid, name) values (24, 'Bangladesh');
insert into countries (countryid, name) values (25, 'Barbados');
insert into countries (countryid, name) values (40, 'Belarus');
insert into countries (countryid, name) values (4, 'Belgium');
insert into countries (countryid, name) values (31, 'Belize');
insert into countries (countryid, name) values (26, 'Benin');
insert into countries (countryid, name) values (27, 'Bermuda');
insert into countries (countryid, name) values (30, 'Bhutan');
insert into countries (countryid, name) values (32, 'Bolivia');
insert into countries (countryid, name) values (275, 'Bonaire');
insert into countries (countryid, name) values (234, 'Bosnia and Herzegovina');
insert into countries (countryid, name) values (33, 'Botswana');
insert into countries (countryid, name) values (247, 'Bouvet Island');
insert into countries (countryid, name) values (34, 'Brazil');
insert into countries (countryid, name) values (248, 'British Indian Ocean Territories');
insert into countries (countryid, name) values (39, 'British Virgin Islands');
insert into countries (countryid, name) values (36, 'Brunei');
insert into countries (countryid, name) values (37, 'Bulgaria');
insert into countries (countryid, name) values (216, 'Burkina Faso');
insert into countries (countryid, name) values (35, 'Burundi');
insert into countries (countryid, name) values (42, 'Cambodia');
insert into countries (countryid, name) values (43, 'Cameroon');
insert into countries (countryid, name) values (5, 'Canada');
insert into countries (countryid, name) values (239, 'Cape Verde');
insert into countries (countryid, name) values (44, 'Cayman Islands');
insert into countries (countryid, name) values (46, 'Central African Republic');
insert into countries (countryid, name) values (249, 'Chad');
insert into countries (countryid, name) values (6, 'Chile');
insert into countries (countryid, name) values (47, 'China');
insert into countries (countryid, name) values (250, 'Christmas Island');
insert into countries (countryid, name) values (251, 'Cocos (Keeling) Islands');
insert into countries (countryid, name) values (49, 'Colombia');
insert into countries (countryid, name) values (50, 'Comoros');
insert into countries (countryid, name) values (51, 'Congo');
insert into countries (countryid, name) values (48, 'Cook Islands');
insert into countries (countryid, name) values (52, 'Costa Rica');
insert into countries (countryid, name) values (53, 'Croatia');
insert into countries (countryid, name) values (238, 'Cuba');
insert into countries (countryid, name) values (54, 'Curacao');
insert into countries (countryid, name) values (55, 'Cyprus');
insert into countries (countryid, name) values (56, 'Czech Republic');
insert into countries (countryid, name) values (257, 'Democratic Republic of the Congo');
insert into countries (countryid, name) values (57, 'Denmark');
insert into countries (countryid, name) values (58, 'Djibouti');
insert into countries (countryid, name) values (59, 'Dominica');
insert into countries (countryid, name) values (60, 'Dominican Republic');
insert into countries (countryid, name) values (252, 'East Timor');
insert into countries (countryid, name) values (61, 'Ecuador');
insert into countries (countryid, name) values (63, 'Egypt');
insert into countries (countryid, name) values (64, 'El Salvador');
insert into countries (countryid, name) values (62, 'Equatorial Guinea');
insert into countries (countryid, name) values (65, 'Eritrea');
insert into countries (countryid, name) values (66, 'Estonia');
insert into countries (countryid, name) values (67, 'Ethiopia');
insert into countries (countryid, name) values (69, 'Falkland Islands');
insert into countries (countryid, name) values (68, 'Faroe Islands');
insert into countries (countryid, name) values (71, 'Fiji');
insert into countries (countryid, name) values (72, 'Finland');
insert into countries (countryid, name) values (73, 'France');
insert into countries (countryid, name) values (70, 'French Guiana');
insert into countries (countryid, name) values (74, 'French Polynesia');
insert into countries (countryid, name) values (253, 'French Southern Territories');
insert into countries (countryid, name) values (75, 'Gabon');
insert into countries (countryid, name) values (76, 'Gambia');
insert into countries (countryid, name) values (78, 'Georgia');
insert into countries (countryid, name) values (79, 'Germany');
insert into countries (countryid, name) values (254, 'Ghana');
insert into countries (countryid, name) values (80, 'Gibraltar');
insert into countries (countryid, name) values (82, 'Greece');
insert into countries (countryid, name) values (83, 'Greenland');
insert into countries (countryid, name) values (81, 'Grenada');
insert into countries (countryid, name) values (77, 'Guadeloupe');
insert into countries (countryid, name) values (229, 'Guam');
insert into countries (countryid, name) values (84, 'Guatemala');
insert into countries (countryid, name) values (86, 'Guernsey');
insert into countries (countryid, name) values (255, 'Guinea');
insert into countries (countryid, name) values (85, 'Guinea-Bissau');
insert into countries (countryid, name) values (87, 'Guyana');
insert into countries (countryid, name) values (89, 'Haiti');
insert into countries (countryid, name) values (256, 'Heard Island And Mcdonald Islands');
insert into countries (countryid, name) values (90, 'Honduras');
insert into countries (countryid, name) values (91, 'Hong Kong');
insert into countries (countryid, name) values (92, 'Hungary');
insert into countries (countryid, name) values (93, 'Iceland');
insert into countries (countryid, name) values (94, 'India');
insert into countries (countryid, name) values (95, 'Indonesia');
insert into countries (countryid, name) values (96, 'Iran');
insert into countries (countryid, name) values (97, 'Iraq');
insert into countries (countryid, name) values (7, 'Ireland');
insert into countries (countryid, name) values (243, 'Isle of Man');
insert into countries (countryid, name) values (98, 'Israel');
insert into countries (countryid, name) values (99, 'Italy');
insert into countries (countryid, name) values (100, 'Ivory Coast');
insert into countries (countryid, name) values (101, 'Jamaica');
insert into countries (countryid, name) values (104, 'Japan');
insert into countries (countryid, name) values (102, 'Jersey');
insert into countries (countryid, name) values (103, 'Jordan');
insert into countries (countryid, name) values (106, 'Kazakhstan');
insert into countries (countryid, name) values (107, 'Kenya');
insert into countries (countryid, name) values (109, 'Kiribati');
insert into countries (countryid, name) values (241, 'Kuwait');
insert into countries (countryid, name) values (108, 'Kyrgyzstan');
insert into countries (countryid, name) values (110, 'Laos');
insert into countries (countryid, name) values (111, 'Latvia');
insert into countries (countryid, name) values (113, 'Lebanon');
insert into countries (countryid, name) values (114, 'Lesotho');
insert into countries (countryid, name) values (115, 'Liberia');
insert into countries (countryid, name) values (112, 'Libya');
insert into countries (countryid, name) values (116, 'Liechtenstein');
insert into countries (countryid, name) values (117, 'Lithuania');
insert into countries (countryid, name) values (8, 'Luxembourg');
insert into countries (countryid, name) values (258, 'Macau');
insert into countries (countryid, name) values (125, 'Macedonia');
insert into countries (countryid, name) values (119, 'Madagascar');
insert into countries (countryid, name) values (129, 'Malawi');
insert into countries (countryid, name) values (121, 'Malaysia');
insert into countries (countryid, name) values (124, 'Maldives');
insert into countries (countryid, name) values (127, 'Mali');
insert into countries (countryid, name) values (128, 'Malta');
insert into countries (countryid, name) values (240, 'Marshall Islands');
insert into countries (countryid, name) values (122, 'Martinique');
insert into countries (countryid, name) values (123, 'Mauritania');
insert into countries (countryid, name) values (134, 'Mauritius');
insert into countries (countryid, name) values (259, 'Mayotte');
insert into countries (countryid, name) values (228, 'Mexico');
insert into countries (countryid, name) values (242, 'Micronesia');
insert into countries (countryid, name) values (237, 'Moldova');
insert into countries (countryid, name) values (130, 'Monaco');
insert into countries (countryid, name) values (131, 'Mongolia');
insert into countries (countryid, name) values (274, 'Montenegro');
insert into countries (countryid, name) values (135, 'Montserrat');
insert into countries (countryid, name) values (132, 'Morocco');
insert into countries (countryid, name) values (133, 'Mozambique');
insert into countries (countryid, name) values (136, 'Myanmar');
insert into countries (countryid, name) values (137, 'Namibia');
insert into countries (countryid, name) values (138, 'Nauru');
insert into countries (countryid, name) values (140, 'Nepal');
insert into countries (countryid, name) values (141, 'Netherlands');
insert into countries (countryid, name) values (148, 'Netherlands Antilles');
insert into countries (countryid, name) values (142, 'Nevis and St Kitts');
insert into countries (countryid, name) values (41, 'New Caledonia');
insert into countries (countryid, name) values (9, 'New Zealand');
insert into countries (countryid, name) values (144, 'Nicaragua');
insert into countries (countryid, name) values (143, 'Niger');
insert into countries (countryid, name) values (145, 'Nigeria');
insert into countries (countryid, name) values (149, 'Niue');
insert into countries (countryid, name) values (260, 'Norfolk Island');
insert into countries (countryid, name) values (146, 'North Korea');
insert into countries (countryid, name) values (236, 'Northern Mariana Islands');
insert into countries (countryid, name) values (147, 'Norway');
insert into countries (countryid, name) values (150, 'Oman');
insert into countries (countryid, name) values (151, 'Pakistan');
insert into countries (countryid, name) values (261, 'Palau');
insert into countries (countryid, name) values (276, 'Palestine');
insert into countries (countryid, name) values (152, 'Panama');
insert into countries (countryid, name) values (156, 'Papua New Guinea');
insert into countries (countryid, name) values (262, 'Paraguay');
insert into countries (countryid, name) values (153, 'Peru');
insert into countries (countryid, name) values (154, 'Philippines');
insert into countries (countryid, name) values (155, 'Pitcairn Islands');
insert into countries (countryid, name) values (158, 'Poland');
insert into countries (countryid, name) values (159, 'Portugal');
insert into countries (countryid, name) values (226, 'Puerto Rico');
insert into countries (countryid, name) values (160, 'Qatar');
insert into countries (countryid, name) values (161, 'Reunion');
insert into countries (countryid, name) values (162, 'Romania');
insert into countries (countryid, name) values (163, 'Russia');
insert into countries (countryid, name) values (164, 'Rwanda');
insert into countries (countryid, name) values (277, 'Saba');
insert into countries (countryid, name) values (171, 'Saint Helena');
insert into countries (countryid, name) values (264, 'Saint Kitts and Nevis');
insert into countries (countryid, name) values (173, 'Saint Lucia');
insert into countries (countryid, name) values (217, 'Samoa');
insert into countries (countryid, name) values (183, 'San Marino');
insert into countries (countryid, name) values (176, 'Sao Tome and Principe');
insert into countries (countryid, name) values (166, 'Saudi Arabia');
insert into countries (countryid, name) values (167, 'Senegal');
insert into countries (countryid, name) values (222, 'Serbia');
insert into countries (countryid, name) values (168, 'Seychelles');
insert into countries (countryid, name) values (178, 'Sierra Leone');
insert into countries (countryid, name) values (179, 'Singapore');
insert into countries (countryid, name) values (182, 'Slovakia');
insert into countries (countryid, name) values (181, 'Slovenia');
insert into countries (countryid, name) values (184, 'Solomon Islands');
insert into countries (countryid, name) values (185, 'Somalia');
insert into countries (countryid, name) values (165, 'South Africa');
insert into countries (countryid, name) values (267, 'South Georgia and Sandwich Islands');
insert into countries (countryid, name) values (180, 'South Korea');
insert into countries (countryid, name) values (278, 'South Sudan');
insert into countries (countryid, name) values (186, 'Spain');
insert into countries (countryid, name) values (187, 'Sri Lanka');
insert into countries (countryid, name) values (169, 'St Barthelemy');
insert into countries (countryid, name) values (170, 'St Eustatius');
insert into countries (countryid, name) values (172, 'St Kitts');
insert into countries (countryid, name) values (175, 'St Pierre Miquelon');
insert into countries (countryid, name) values (177, 'St Vince Grenadines');
insert into countries (countryid, name) values (174, 'St. Martin');
insert into countries (countryid, name) values (188, 'Sudan');
insert into countries (countryid, name) values (189, 'Suriname');
insert into countries (countryid, name) values (268, 'Svalbard and Jan Mayen');
insert into countries (countryid, name) values (190, 'Swaziland');
insert into countries (countryid, name) values (10, 'Sweden');
insert into countries (countryid, name) values (192, 'Switzerland');
insert into countries (countryid, name) values (193, 'Syria');
insert into countries (countryid, name) values (194, 'Taiwan');
insert into countries (countryid, name) values (195, 'Tajikistan');
insert into countries (countryid, name) values (196, 'Tanzania');
insert into countries (countryid, name) values (198, 'Thailand');
insert into countries (countryid, name) values (200, 'Togo');
insert into countries (countryid, name) values (269, 'Tokelau');
insert into countries (countryid, name) values (201, 'Tonga');
insert into countries (countryid, name) values (202, 'Trinidad and Tobago');
insert into countries (countryid, name) values (203, 'Tunisia');
insert into countries (countryid, name) values (204, 'Turkey');
insert into countries (countryid, name) values (199, 'Turkmenistan');
insert into countries (countryid, name) values (197, 'Turks and Caicos Islands');
insert into countries (countryid, name) values (205, 'Tuvalu');
insert into countries (countryid, name) values (208, 'Uganda');
insert into countries (countryid, name) values (207, 'Ukraine');
insert into countries (countryid, name) values (206, 'United Arab Emirates');
insert into countries (countryid, name) values (11, 'United Kingdom');
insert into countries (countryid, name) values (210, 'Uruguay');
insert into countries (countryid, name) values (270, 'US Minor Outlying Islands');
insert into countries (countryid, name) values (235, 'US Virgin Islands');
insert into countries (countryid, name) values (211, 'Uzbekistan');
insert into countries (countryid, name) values (212, 'Vanuatu');
insert into countries (countryid, name) values (213, 'Vatican City State');
insert into countries (countryid, name) values (214, 'Venezuela');
insert into countries (countryid, name) values (215, 'Vietnam');
insert into countries (countryid, name) values (218, 'Wallis And Futuna Islands');
insert into countries (countryid, name) values (271, 'Western Sahara');
insert into countries (countryid, name) values (220, 'Yemen');
insert into countries (countryid, name) values (224, 'Zambia');
insert into countries (countryid, name) values (225, 'Zimbabwe');

/* Need to look up/translate some of these unicode characters */
insert into states (stateid, name) values (189, 'Abruzzo');
insert into states (stateid, name) values (162, 'Acre');
insert into states (stateid, name) values (454, 'Aguascalientes');
insert into states (stateid, name) values (312, 'Aichi');
insert into states (stateid, name) values (240, 'Akershus');
insert into states (stateid, name) values (383, 'Akita');
insert into states (stateid, name) values (60, 'Alabama');
insert into states (stateid, name) values (163, 'Alagoas');
insert into states (stateid, name) values (2, 'Alaska');
insert into states (stateid, name) values (63, 'Alberta');
insert into states (stateid, name) values (433, 'Alsace');
insert into states (stateid, name) values (164, 'Amap&#225;');
insert into states (stateid, name) values (165, 'Amazonas');
insert into states (stateid, name) values (116, 'Andaluc&#237;a');
insert into states (stateid, name) values (87, 'Antwerpen');
insert into states (stateid, name) values (313, 'Aomori');
insert into states (stateid, name) values (412, 'Aquitaine');
insert into states (stateid, name) values (119, 'Arag&#243;n');
insert into states (stateid, name) values (3, 'Arizona');
insert into states (stateid, name) values (4, 'Arkansas');
insert into states (stateid, name) values (380, 'Armed Forces Americas');
insert into states (stateid, name) values (381, 'Armed Forces Europe');
insert into states (stateid, name) values (382, 'Armed Forces Pacific');
insert into states (stateid, name) values (113, 'Arquip&#233;lago da Madeira');
insert into states (stateid, name) values (114, 'Arquip&#233;lago dos A&#231;ores');
insert into states (stateid, name) values (247, 'Aust-Agder');
insert into states (stateid, name) values (59, 'Australian Capital Territory');
insert into states (stateid, name) values (413, 'Auvergne');
insert into states (stateid, name) values (95, 'Aveiro');
insert into states (stateid, name) values (434, 'B&#225;cs-Kiskun');
insert into states (stateid, name) values (135, 'Baden-W&#252;rttemberg');
insert into states (stateid, name) values (166, 'Bahia');
insert into states (stateid, name) values (455, 'Baja California');
insert into states (stateid, name) values (456, 'Baja California Sur');
insert into states (stateid, name) values (287, 'Banskobystrick&#253; kraj');
insert into states (stateid, name) values (435, 'Baranya');
insert into states (stateid, name) values (190, 'Basilicata');
insert into states (stateid, name) values (414, 'Basse-Normandie');
insert into states (stateid, name) values (136, 'Bayern');
insert into states (stateid, name) values (96, 'Beja');
insert into states (stateid, name) values (436, 'B&#233;k&#233;s');
insert into states (stateid, name) values (137, 'Berlin');
insert into states (stateid, name) values (359, 'Blekinge');
insert into states (stateid, name) values (437, 'Borsod-Aba&#250;j-Zempl&#233;n');
insert into states (stateid, name) values (415, 'Bourgogne');
insert into states (stateid, name) values (91, 'Brabant wallon');
insert into states (stateid, name) values (97, 'Braga');
insert into states (stateid, name) values (98, 'Bragan&#231;a');
insert into states (stateid, name) values (138, 'Brandenburg');
insert into states (stateid, name) values (288, 'Bratislavsk&#253; kraj');
insert into states (stateid, name) values (139, 'Bremen');
insert into states (stateid, name) values (416, 'Bretagne');
insert into states (stateid, name) values (64, 'British Columbia');
insert into states (stateid, name) values (93, 'Brussels');
insert into states (stateid, name) values (438, 'Budapest');
insert into states (stateid, name) values (258, 'Burgenland');
insert into states (stateid, name) values (297, 'Busan');
insert into states (stateid, name) values (244, 'Buskerud');
insert into states (stateid, name) values (192, 'Calabria');
insert into states (stateid, name) values (5, 'California');
insert into states (stateid, name) values (193, 'Campania');
insert into states (stateid, name) values (457, 'Campeche');
insert into states (stateid, name) values (130, 'Cantabria');
insert into states (stateid, name) values (99, 'Castelo Branco');
insert into states (stateid, name) values (115, 'Castilla y Le&#243;n');
insert into states (stateid, name) values (117, 'Castilla-La Mancha');
insert into states (stateid, name) values (121, 'Catalu&#241;a');
insert into states (stateid, name) values (167, 'Cear&#225;');
insert into states (stateid, name) values (417, 'Centre');
insert into states (stateid, name) values (133, 'Ceuta');
insert into states (stateid, name) values (418, 'Champagne-Ardenne');
insert into states (stateid, name) values (486, 'Chatham Islands');
insert into states (stateid, name) values (458, 'Chiapas');
insert into states (stateid, name) values (314, 'Chiba');
insert into states (stateid, name) values (459, 'Chihuahua');
insert into states (stateid, name) values (305, 'Chungcheong buk do');
insert into states (stateid, name) values (306, 'Chungcheong nam do');
insert into states (stateid, name) values (460, 'Coahuila');
insert into states (stateid, name) values (100, 'Coimbra');
insert into states (stateid, name) values (461, 'Colima');
insert into states (stateid, name) values (6, 'Colorado');
insert into states (stateid, name) values (127, 'Comunidad de Madrid');
insert into states (stateid, name) values (126, 'Comunidad Foral de Navarra');
insert into states (stateid, name) values (123, 'Comunidad Valenciana');
insert into states (stateid, name) values (227, 'Connacht');
insert into states (stateid, name) values (7, 'Connecticut');
insert into states (stateid, name) values (419, 'Corse');
insert into states (stateid, name) values (439, 'Csongr&#225;d');
insert into states (stateid, name) values (298, 'Daegu');
insert into states (stateid, name) values (301, 'Daejeon');
insert into states (stateid, name) values (360, 'Dalarna');
insert into states (stateid, name) values (9, 'Delaware');
insert into states (stateid, name) values (8, 'District of Columbia');
insert into states (stateid, name) values (168, 'Distrito Federal');
insert into states (stateid, name) values (462, 'Distrito Federal');
insert into states (stateid, name) values (396, 'Dolnośląskie');
insert into states (stateid, name) values (385, 'Drenthe');
insert into states (stateid, name) values (226, 'Dublin');
insert into states (stateid, name) values (463, 'Durango');
insert into states (stateid, name) values (215, 'East Midlands');
insert into states (stateid, name) values (153, 'Eastern Cape');
insert into states (stateid, name) values (219, 'Eastern England');
insert into states (stateid, name) values (315, 'Ehime');
insert into states (stateid, name) values (194, 'Emilia–Romagna ');
insert into states (stateid, name) values (234, 'Espace Mittelland (BE/SO)');
insert into states (stateid, name) values (169, 'Esp&#237;rito Santo');
insert into states (stateid, name) values (101, '&#201;vora');
insert into states (stateid, name) values (120, 'Extremadura');
insert into states (stateid, name) values (102, 'Faro');
insert into states (stateid, name) values (440, 'Fej&#233;r');
insert into states (stateid, name) values (257, 'Finnmark');
insert into states (stateid, name) values (395, 'Flevoland');
insert into states (stateid, name) values (10, 'Florida');
insert into states (stateid, name) values (420, 'Franche-Comt&#233;');
insert into states (stateid, name) values (160, 'Free State');
insert into states (stateid, name) values (394, 'Friesland');
insert into states (stateid, name) values (195, 'Friuli–Venezia Giulia');
insert into states (stateid, name) values (316, 'Fukui');
insert into states (stateid, name) values (317, 'Fukuoka');
insert into states (stateid, name) values (318, 'Fukushima');
insert into states (stateid, name) values (122, 'Galicia');
insert into states (stateid, name) values (304, 'Gangwondo');
insert into states (stateid, name) values (159, 'Gauteng');
insert into states (stateid, name) values (362, 'G&#228;vleborg');
insert into states (stateid, name) values (387, 'Gelderland');
insert into states (stateid, name) values (11, 'Georgia');
insert into states (stateid, name) values (319, 'Gifu');
insert into states (stateid, name) values (170, 'Goi&#225;s');
insert into states (stateid, name) values (361, 'Gotland');
insert into states (stateid, name) values (229, 'Graubuenden (GR)');
insert into states (stateid, name) values (384, 'Groningen');
insert into states (stateid, name) values (464, 'Guanajuato');
insert into states (stateid, name) values (103, 'Guarda');
insert into states (stateid, name) values (465, 'Guerrero');
insert into states (stateid, name) values (320, 'Gunma');
insert into states (stateid, name) values (300, 'Gwangju');
insert into states (stateid, name) values (303, 'Gyeonggido');
insert into states (stateid, name) values (309, 'Gyeongsang buk do');
insert into states (stateid, name) values (310, 'Gyeongsang nam do');
insert into states (stateid, name) values (441, 'Gyor-Moson-Sopron');
insert into states (stateid, name) values (88, 'Hainaut');
insert into states (stateid, name) values (442, 'Hajd&#250;-Bihar');
insert into states (stateid, name) values (363, 'Halland');
insert into states (stateid, name) values (140, 'Hamburg');
insert into states (stateid, name) values (421, 'Haute-Normandie');
insert into states (stateid, name) values (12, 'Hawaii');
insert into states (stateid, name) values (242, 'Hedmark');
insert into states (stateid, name) values (150, 'Hessen');
insert into states (stateid, name) values (443, 'Heves');
insert into states (stateid, name) values (466, 'Hidalgo');
insert into states (stateid, name) values (321, 'Hiroshima');
insert into states (stateid, name) values (286, 'Hlavni mesto Praha');
insert into states (stateid, name) values (322, 'Hokkaido');
insert into states (stateid, name) values (250, 'Hordaland');
insert into states (stateid, name) values (323, 'Hyogo');
insert into states (stateid, name) values (324, 'Ibaraki');
insert into states (stateid, name) values (13, 'Idaho');
insert into states (stateid, name) values (422, '&#206;le-de-France');
insert into states (stateid, name) values (14, 'Illinois');
insert into states (stateid, name) values (299, 'Incheon');
insert into states (stateid, name) values (15, 'Indiana');
insert into states (stateid, name) values (16, 'Iowa');
insert into states (stateid, name) values (325, 'Ishikawa');
insert into states (stateid, name) values (132, 'Islas Baleares');
insert into states (stateid, name) values (128, 'Islas Canarias');
insert into states (stateid, name) values (326, 'Iwate');
insert into states (stateid, name) values (467, 'Jalisco');
insert into states (stateid, name) values (364, 'J&#228;mtland');
insert into states (stateid, name) values (444, 'J&#225;sz-Nagykun-Szolnok');
insert into states (stateid, name) values (311, 'Jejudo');
insert into states (stateid, name) values (307, 'Jeolla buk do');
insert into states (stateid, name) values (308, 'Jeolla nam do');
insert into states (stateid, name) values (274, 'Jihocesky kraj');
insert into states (stateid, name) values (273, 'Jihomoravsky kraj');
insert into states (stateid, name) values (365, 'J&#246;nk&#246;ping');
insert into states (stateid, name) values (236, 'Jura (JU/NE)');
insert into states (stateid, name) values (327, 'Kagawa');
insert into states (stateid, name) values (328, 'Kagoshima');
insert into states (stateid, name) values (366, 'Kalmar');
insert into states (stateid, name) values (329, 'Kanagawa');
insert into states (stateid, name) values (17, 'Kansas');
insert into states (stateid, name) values (276, 'Karlovarsky kraj');
insert into states (stateid, name) values (259, 'K&#228;rnten');
insert into states (stateid, name) values (18, 'Kentucky');
insert into states (stateid, name) values (330, 'Kochi');
insert into states (stateid, name) values (445, 'Kom&#225;rom-Esztergom');
insert into states (stateid, name) values (289, 'Košick&#253; kraj');
insert into states (stateid, name) values (284, 'Kraj Vysocina');
insert into states (stateid, name) values (275, 'Kralovehradecky kraj');
insert into states (stateid, name) values (367, 'Kronoberg');
insert into states (stateid, name) values (397, 'Kujawsko-Pomorskie');
insert into states (stateid, name) values (331, 'Kumamoto');
insert into states (stateid, name) values (157, 'Kwazulu Natal');
insert into states (stateid, name) values (332, 'Kyoto');
insert into states (stateid, name) values (131, 'La Rioja');
insert into states (stateid, name) values (423, 'Languedoc-Roussillon');
insert into states (stateid, name) values (196, 'Lazio');
insert into states (stateid, name) values (228, 'Leinster');
insert into states (stateid, name) values (104, 'Leiria');
insert into states (stateid, name) values (277, 'Liberecky kraj');
insert into states (stateid, name) values (80, 'Li&#232;ge');
insert into states (stateid, name) values (197, 'Liguria');
insert into states (stateid, name) values (89, 'Limburg');
insert into states (stateid, name) values (393, 'Limburg');
insert into states (stateid, name) values (424, 'Limousin');
insert into states (stateid, name) values (158, 'Limpopo');
insert into states (stateid, name) values (105, 'Lisboa');
insert into states (stateid, name) values (400, 'Ł&#243;dzkie');
insert into states (stateid, name) values (198, 'Lombardia');
insert into states (stateid, name) values (220, 'London');
insert into states (stateid, name) values (425, 'Lorraine');
insert into states (stateid, name) values (19, 'Louisiana');
insert into states (stateid, name) values (398, 'Lubelskie');
insert into states (stateid, name) values (399, 'Lubuskie');
insert into states (stateid, name) values (90, 'Luxembourg');
insert into states (stateid, name) values (20, 'Maine');
insert into states (stateid, name) values (401, 'Małopolskie');
insert into states (stateid, name) values (65, 'Manitoba');
insert into states (stateid, name) values (171, 'Maranh&#227;o');
insert into states (stateid, name) values (199, 'Marche');
insert into states (stateid, name) values (21, 'Maryland');
insert into states (stateid, name) values (22, 'Massachusetts');
insert into states (stateid, name) values (172, 'Mato Grosso');
insert into states (stateid, name) values (173, 'Mato Grosso do Sul');
insert into states (stateid, name) values (402, 'Mazowieckie');
insert into states (stateid, name) values (141, 'Mecklenburg-Vorpommern');
insert into states (stateid, name) values (134, 'Melilla');
insert into states (stateid, name) values (468, 'M&#233;xico');
insert into states (stateid, name) values (23, 'Michigan');
insert into states (stateid, name) values (469, 'Michoac&#225;n');
insert into states (stateid, name) values (426, 'Midi-Pyr&#233;n&#233;es');
insert into states (stateid, name) values (333, 'Mie');
insert into states (stateid, name) values (174, 'Minas Gerais');
insert into states (stateid, name) values (24, 'Minnesota');
insert into states (stateid, name) values (25, 'Mississippi');
insert into states (stateid, name) values (26, 'Missouri');
insert into states (stateid, name) values (334, 'Miyagi');
insert into states (stateid, name) values (335, 'Miyazaki');
insert into states (stateid, name) values (200, 'Molise');
insert into states (stateid, name) values (27, 'Montana');
insert into states (stateid, name) values (279, 'Moravskoslezsky kraj');
insert into states (stateid, name) values (252, 'M&#248;re og Romsdal');
insert into states (stateid, name) values (470, 'Morelos');
insert into states (stateid, name) values (155, 'Mpumalanga');
insert into states (stateid, name) values (225, 'Munster');
insert into states (stateid, name) values (336, 'Nagano');
insert into states (stateid, name) values (337, 'Nagasaki');
insert into states (stateid, name) values (81, 'Namur');
insert into states (stateid, name) values (338, 'Nara');
insert into states (stateid, name) values (471, 'Nayarit');
insert into states (stateid, name) values (28, 'Nebraska');
insert into states (stateid, name) values (29, 'Nevada');
insert into states (stateid, name) values (66, 'New Brunswick');
insert into states (stateid, name) values (30, 'New Hampshire');
insert into states (stateid, name) values (31, 'New Jersey');
insert into states (stateid, name) values (32, 'New Mexico');
insert into states (stateid, name) values (52, 'New South Wales');
insert into states (stateid, name) values (33, 'New York');
insert into states (stateid, name) values (67, 'Newfoundland and Labrador');
insert into states (stateid, name) values (260, 'Nieder&#246;sterreich');
insert into states (stateid, name) values (142, 'Niedersachsen');
insert into states (stateid, name) values (339, 'Niigata');
insert into states (stateid, name) values (290, 'Nitriansky kraj');
insert into states (stateid, name) values (446, 'N&#243;gr&#225;d');
insert into states (stateid, name) values (392, 'Noord-Brabant');
insert into states (stateid, name) values (389, 'Noord-Holland');
insert into states (stateid, name) values (255, 'Nordland');
insert into states (stateid, name) values (427, 'Nord-Pas-de-Calais');
insert into states (stateid, name) values (143, 'Nordrhein-Westfalen');
insert into states (stateid, name) values (254, 'Nord-Tr&#248;ndelag');
insert into states (stateid, name) values (232, 'Nordwestschweiz (AG/BL/BS)');
insert into states (stateid, name) values (368, 'Norrbotten');
insert into states (stateid, name) values (34, 'North Carolina');
insert into states (stateid, name) values (35, 'North Dakota');
insert into states (stateid, name) values (82, 'North Island');
insert into states (stateid, name) values (217, 'North Wales');
insert into states (stateid, name) values (156, 'North West');
insert into states (stateid, name) values (212, 'Northeast England');
insert into states (stateid, name) values (154, 'Northern Cape');
insert into states (stateid, name) values (210, 'Northern Scotland');
insert into states (stateid, name) values (58, 'Northern Territory');
insert into states (stateid, name) values (213, 'Northwest England');
insert into states (stateid, name) values (72, 'Northwest Territories');
insert into states (stateid, name) values (68, 'Nova Scotia');
insert into states (stateid, name) values (472, 'Nuevo Le&#243;n');
insert into states (stateid, name) values (73, 'Nunavut');
insert into states (stateid, name) values (473, 'Oaxaca');
insert into states (stateid, name) values (261, 'Ober&#246;sterreich');
insert into states (stateid, name) values (36, 'Ohio');
insert into states (stateid, name) values (340, 'Oita');
insert into states (stateid, name) values (341, 'Okayama');
insert into states (stateid, name) values (342, 'Okinawa');
insert into states (stateid, name) values (37, 'Oklahoma');
insert into states (stateid, name) values (278, 'Olomoucky kraj');
insert into states (stateid, name) values (69, 'Ontario');
insert into states (stateid, name) values (76, 'Oost-Vlaanderen');
insert into states (stateid, name) values (403, 'Opolskie');
insert into states (stateid, name) values (243, 'Oppland');
insert into states (stateid, name) values (378, '&#214;rebro');
insert into states (stateid, name) values (38, 'Oregon');
insert into states (stateid, name) values (343, 'Osaka');
insert into states (stateid, name) values (241, 'Oslo');
insert into states (stateid, name) values (379, '&#214;sterg&#246;tland');
insert into states (stateid, name) values (239, '&#216;stfold');
insert into states (stateid, name) values (230, 'Ostschweiz (SG/SH/TG/AI/AR/GL)');
insert into states (stateid, name) values (386, 'Overijssel');
insert into states (stateid, name) values (129, 'Pa&#237;s Vasco');
insert into states (stateid, name) values (175, 'Par&#225;');
insert into states (stateid, name) values (176, 'Para&#237;ba');
insert into states (stateid, name) values (177, 'Paran&#225;');
insert into states (stateid, name) values (280, 'Pardubicky kraj');
insert into states (stateid, name) values (428, 'Pays de la Loire');
insert into states (stateid, name) values (39, 'Pennsylvania');
insert into states (stateid, name) values (178, 'Pernambuco');
insert into states (stateid, name) values (447, 'Pest');
insert into states (stateid, name) values (179, 'Piau&#237;');
insert into states (stateid, name) values (429, 'Picardie');
insert into states (stateid, name) values (201, 'Piemonte');
insert into states (stateid, name) values (281, 'Plzensky kraj');
insert into states (stateid, name) values (404, 'Podkarpackie');
insert into states (stateid, name) values (405, 'Podlaskie');
insert into states (stateid, name) values (430, 'Poitou-Charentes');
insert into states (stateid, name) values (406, 'Pomorskie');
insert into states (stateid, name) values (106, 'Portalegre');
insert into states (stateid, name) values (107, 'Porto');
insert into states (stateid, name) values (291, 'Prešovsk&#253; kraj');
insert into states (stateid, name) values (70, 'Prince Edward Island');
insert into states (stateid, name) values (125, 'Principado de Asturias');
insert into states (stateid, name) values (431, 'Provence-Alpes-C&#244;te d&#39;Azur');
insert into states (stateid, name) values (474, 'Puebla');
insert into states (stateid, name) values (202, 'Puglia');
insert into states (stateid, name) values (62, 'Quebec');
insert into states (stateid, name) values (54, 'Queensland');
insert into states (stateid, name) values (475, 'Quer&#233;taro');
insert into states (stateid, name) values (476, 'Quintana Roo');
insert into states (stateid, name) values (124, 'Regi&#243;n de Murcia');
insert into states (stateid, name) values (231, 'Region Zuerich (ZH)');
insert into states (stateid, name) values (144, 'Rheinland-Pfalz');
insert into states (stateid, name) values (40, 'Rhode Island');
insert into states (stateid, name) values (432, 'Rh&#244;ne-Alpes');
insert into states (stateid, name) values (180, 'Rio de Janeiro');
insert into states (stateid, name) values (181, 'Rio Grande do Norte');
insert into states (stateid, name) values (182, 'Rio Grande do Sul');
insert into states (stateid, name) values (249, 'Rogaland');
insert into states (stateid, name) values (183, 'Rond&#244;nia');
insert into states (stateid, name) values (184, 'Roraima');
insert into states (stateid, name) values (145, 'Saarland');
insert into states (stateid, name) values (146, 'Sachsen');
insert into states (stateid, name) values (147, 'Sachsen-Anhalt');
insert into states (stateid, name) values (344, 'Saga');
insert into states (stateid, name) values (345, 'Saitama');
insert into states (stateid, name) values (262, 'Salzburg');
insert into states (stateid, name) values (477, 'San Luis Potos&#237;');
insert into states (stateid, name) values (185, 'Santa Catarina');
insert into states (stateid, name) values (108, 'Santar&#233;m');
insert into states (stateid, name) values (186, 'S&#227;o Paulo');
insert into states (stateid, name) values (203, 'Sardegna');
insert into states (stateid, name) values (71, 'Saskatchewan');
insert into states (stateid, name) values (148, 'Schleswig-Holstein');
insert into states (stateid, name) values (296, 'Seoul');
insert into states (stateid, name) values (187, 'Sergipe');
insert into states (stateid, name) values (109, 'Set&#250;bal');
insert into states (stateid, name) values (346, 'Shiga');
insert into states (stateid, name) values (347, 'Shimane');
insert into states (stateid, name) values (348, 'Shizuoka');
insert into states (stateid, name) values (204, 'Sicilia');
insert into states (stateid, name) values (478, 'Sinaloa');
insert into states (stateid, name) values (369, 'Sk&#229;ne');
insert into states (stateid, name) values (407, 'Śląskie');
insert into states (stateid, name) values (371, 'S&#246;dermanland');
insert into states (stateid, name) values (251, 'Sogn og Fjordane');
insert into states (stateid, name) values (448, 'Somogy');
insert into states (stateid, name) values (479, 'Sonora');
insert into states (stateid, name) values (253, 'S&#248;r-Tr&#248;ndelag');
insert into states (stateid, name) values (55, 'South Australia');
insert into states (stateid, name) values (41, 'South Carolina');
insert into states (stateid, name) values (42, 'South Dakota');
insert into states (stateid, name) values (223, 'South East England');
insert into states (stateid, name) values (86, 'South Island');
insert into states (stateid, name) values (218, 'South Wales');
insert into states (stateid, name) values (222, 'South West England');
insert into states (stateid, name) values (221, 'Southern England');
insert into states (stateid, name) values (211, 'Southern Scotland');
insert into states (stateid, name) values (263, 'Steiermark');
insert into states (stateid, name) values (370, 'Stockholm');
insert into states (stateid, name) values (282, 'Stredocesky kraj');
insert into states (stateid, name) values (235, 'Suisse romande (GE/VD/FR)');
insert into states (stateid, name) values (408, 'Świętokrzyskie');
insert into states (stateid, name) values (449, 'Szabolcs-Szatm&#225;r-Bereg');
insert into states (stateid, name) values (480, 'Tabasco');
insert into states (stateid, name) values (481, 'Tamaulipas');
insert into states (stateid, name) values (57, 'Tasmania');
insert into states (stateid, name) values (245, 'Telemark');
insert into states (stateid, name) values (43, 'Tennessee');
insert into states (stateid, name) values (238, 'Tessin (TI)');
insert into states (stateid, name) values (44, 'Texas');
insert into states (stateid, name) values (149, 'Th&#252;ringen');
insert into states (stateid, name) values (264, 'Tirol');
insert into states (stateid, name) values (482, 'Tlaxcala');
insert into states (stateid, name) values (188, 'Tocantins');
insert into states (stateid, name) values (349, 'Tochigi');
insert into states (stateid, name) values (350, 'Tokushima');
insert into states (stateid, name) values (351, 'Tokyo');
insert into states (stateid, name) values (450, 'Tolna');
insert into states (stateid, name) values (205, 'Toscana');
insert into states (stateid, name) values (352, 'Tottori');
insert into states (stateid, name) values (353, 'Toyama');
insert into states (stateid, name) values (292, 'Trenčiansky kraj');
insert into states (stateid, name) values (206, 'Trentino–Alto Adige ');
insert into states (stateid, name) values (293, 'Trnavsk&#253; kraj');
insert into states (stateid, name) values (256, 'Troms');
insert into states (stateid, name) values (302, 'Ulsan');
insert into states (stateid, name) values (224, 'Ulster');
insert into states (stateid, name) values (207, 'Umbria');
insert into states (stateid, name) values (372, 'Uppsala');
insert into states (stateid, name) values (283, 'Ustecky kraj');
insert into states (stateid, name) values (45, 'Utah');
insert into states (stateid, name) values (388, 'Utrecht');
insert into states (stateid, name) values (208, 'Valle d&#39;Aosta');
insert into states (stateid, name) values (373, 'V&#228;rmland');
insert into states (stateid, name) values (451, 'Vas');
insert into states (stateid, name) values (374, 'V&#228;sterbotten');
insert into states (stateid, name) values (375, 'V&#228;sternorrland');
insert into states (stateid, name) values (376, 'V&#228;stmanland');
insert into states (stateid, name) values (377, 'V&#228;stra G&#246;taland');
insert into states (stateid, name) values (209, 'Veneto');
insert into states (stateid, name) values (483, 'Veracruz');
insert into states (stateid, name) values (46, 'Vermont');
insert into states (stateid, name) values (248, 'Vest-Agder');
insert into states (stateid, name) values (246, 'Vestfold');
insert into states (stateid, name) values (452, 'Veszpr&#233;m');
insert into states (stateid, name) values (110, 'Viana do Castelo');
insert into states (stateid, name) values (53, 'Victoria');
insert into states (stateid, name) values (112, 'Vila Real');
insert into states (stateid, name) values (47, 'Virginia');
insert into states (stateid, name) values (111, 'Viseu');
insert into states (stateid, name) values (78, 'Vlaams-Brabant');
insert into states (stateid, name) values (265, 'Vorarlberg');
insert into states (stateid, name) values (354, 'Wakayama');
insert into states (stateid, name) values (237, 'Wallis (VS)');
insert into states (stateid, name) values (409, 'Warmińsko-Mazurskie');
insert into states (stateid, name) values (48, 'Washington');
insert into states (stateid, name) values (216, 'West Midlands');
insert into states (stateid, name) values (49, 'West Virginia');
insert into states (stateid, name) values (56, 'Western Australia');
insert into states (stateid, name) values (152, 'Western Cape');
insert into states (stateid, name) values (92, 'West-Vlaanderen');
insert into states (stateid, name) values (410, 'Wielkopolskie');
insert into states (stateid, name) values (295, 'Wien');
insert into states (stateid, name) values (50, 'Wisconsin');
insert into states (stateid, name) values (51, 'Wyoming');
insert into states (stateid, name) values (355, 'Yamagata');
insert into states (stateid, name) values (356, 'Yamaguchi');
insert into states (stateid, name) values (357, 'Yamanashi');
insert into states (stateid, name) values (214, 'Yorkshire');
insert into states (stateid, name) values (484, 'Yucat&#225;n');
insert into states (stateid, name) values (74, 'Yukon Territory');
insert into states (stateid, name) values (485, 'Zacatecas');
insert into states (stateid, name) values (411, 'Zachodniopomorskie');
insert into states (stateid, name) values (453, 'Zala');
insert into states (stateid, name) values (391, 'Zeeland');
insert into states (stateid, name) values (233, 'Zentralschweiz (ZG/SZ/LU/UR/OW/NW)');
insert into states (stateid, name) values (294, 'Žilinsk&#253; kraj');
insert into states (stateid, name) values (285, 'Zlinsky kraj');
insert into states (stateid, name) values (390, 'Zuid-Holland');
/* Point takes longitude, then latitude. Out of bounds CenterPoints throw an error */
insert into CenterPoints values (
	'Home Old',
	geography::STGeomFromText('POINT(-77.23315 43.06525)',4326)
);
insert into CenterPoints values (
	'Home',
	geography::STGeomFromText('POINT(-77.306933 42.885983)',4326)
);
insert into CenterPoints values (
	'Mom&Dad',
	geography::STGeomFromText('POINT(-73.809733 42.853833)',4326)
);
insert into CenterPoints values (
	'Geneva',
	geography::STGeomFromText('POINT(-76.993056 42.878889)',4326)
);
insert into CenterPoints values (
	'DML',
	geography::STGeomFromText('POINT(-79.1105 42.5074)',4326)
);
insert into CenterPoints values (
	'Watkins Glen',
	geography::STGeomFromText('POINT(-76.8853 42.3386)',4326)
);
insert into CenterPoints values (
	'Syracuse',
	geography::STGeomFromText('POINT(-76.144167 43.046944)',4326)
);
insert into CenterPoints values (
	'Auburn',
	geography::STGeomFromText('POINT(-76.56477 42.93166)',4326)
);
insert into CenterPoints values (
	'Niagara Falls',
	geography::STGeomFromText('POINT(-79.017222 43.094167)',4326)
);
insert into CenterPoints values (
	'Silver Creek',
	geography::STGeomFromText('POINT(-79.167222 42.544167)',4326)
);
insert into CenterPoints values (
	'Mendon Ponds',
	geography::STGeomFromText('POINT(-77.564267 43.0293)',4326)
);
insert into CenterPoints values (
	'Saratoga',
	geography::STGeomFromText('POINT(-73.7825 43.075278)',4326)
);
insert into CenterPoints values (
	'Sea Isle',
	geography::STGeomFromText('POINT(-74.691917 39.147633)',4326)
);
insert into CenterPoints values (
	'zSpun Around Center',
	geography::STGeomFromText('POINT(-77.48055 43.09305)',4326)
);
insert into CenterPoints values (
	'Dansville',
	geography::STGeomFromText('POINT(-77.697433 42.560417)',4326)
);
insert into CenterPoints values (
	'Lockport',
	geography::STGeomFromText('POINT(-78.689767 43.17485)',4326)
);
insert into CenterPoints values (
	'Seattle',
	geography::STGeomFromText('POINT(-122.33365 47.612033)',4326)
);