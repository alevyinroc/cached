USE geocaches;
/* IDs & names taken from geocaching.com new listing form */
INSERT INTO cache_sizes (sizeid, sizename)
	VALUES (1, 'Not Listed');
INSERT INTO cache_sizes (sizeid, sizename)
	VALUES (2, 'Micro');
INSERT INTO cache_sizes (sizeid, sizename)
	VALUES (8, 'Small');
INSERT INTO cache_sizes (sizeid, sizename)
	VALUES (3, 'Regular');
INSERT INTO cache_sizes (sizeid, sizename)
	VALUES (4, 'Large');
INSERT INTO cache_sizes (sizeid, sizename)
	VALUES (6, 'Other');
INSERT INTO cache_sizes (sizeid, sizename)
	VALUES (5, 'Virtual');
INSERT INTO cache_sizes (sizeid, sizename)
	VALUES (7, 'Not Chosen');

INSERT INTO point_types (typeid, typename)
	VALUES (1, 'Traditional Cache');
INSERT INTO point_types (typeid, typename)
	VALUES (3, 'Multi-cache');
INSERT INTO point_types (typeid, typename)
	VALUES (5, 'Letterbox Hybrid');
INSERT INTO point_types (typeid, typename)
	VALUES (6, 'Event Cache');
INSERT INTO point_types (typeid, typename)
	VALUES (8, 'Unknown Cache');
INSERT INTO point_types (typeid, typename)
	VALUES (13, 'Cache In Trash Out Event');
INSERT INTO point_types (typeid, typename)
	VALUES (137, 'Earthcache');
INSERT INTO point_types (typeid, typename)
	VALUES (1858, 'Wherigo Cache');
/* Still need virtuals & other retired cache types */
INSERT INTO point_types (typeid, typename)
	VALUES (220, 'Final Location');
INSERT INTO point_types (typeid, typename)
	VALUES (217, 'Parking Area');
INSERT INTO point_types (typeid, typename)
	VALUES (218, 'Question to Answer');
INSERT INTO point_types (typeid, typename)
	VALUES (452, 'Reference Point');
INSERT INTO point_types (typeid, typename)
	VALUES (219, 'Stages of a Multicache');
INSERT INTO point_types (typeid, typename)
	VALUES (221, 'Trailhead');
INSERT INTO point_types (typeid, typename)
	VALUES (4, 'Virtual Cache');

INSERT INTO countries (countryid, name)
	VALUES (12, 'Afghanistan');
INSERT INTO countries (countryid, name)
	VALUES (272, 'Aland Islands');
INSERT INTO countries (countryid, name)
	VALUES (244, 'Albania');
INSERT INTO countries (countryid, name)
	VALUES (14, 'Algeria');
INSERT INTO countries (countryid, name)
	VALUES (245, 'American Samoa');
INSERT INTO countries (countryid, name)
	VALUES (16, 'Andorra');
INSERT INTO countries (countryid, name)
	VALUES (17, 'Angola');
INSERT INTO countries (countryid, name)
	VALUES (246, 'Anguilla');
INSERT INTO countries (countryid, name)
	VALUES (18, 'Antarctica');
INSERT INTO countries (countryid, name)
	VALUES (13, 'Antigua and Barbuda');
INSERT INTO countries (countryid, name)
	VALUES (19, 'Argentina');
INSERT INTO countries (countryid, name)
	VALUES (15, 'Armenia');
INSERT INTO countries (countryid, name)
	VALUES (20, 'Aruba');
INSERT INTO countries (countryid, name)
	VALUES (3, 'Australia');
INSERT INTO countries (countryid, name)
	VALUES (227, 'Austria');
INSERT INTO countries (countryid, name)
	VALUES (21, 'Azerbaijan');
INSERT INTO countries (countryid, name)
	VALUES (23, 'Bahamas');
INSERT INTO countries (countryid, name)
	VALUES (29, 'Bahrain');
INSERT INTO countries (countryid, name)
	VALUES (24, 'Bangladesh');
INSERT INTO countries (countryid, name)
	VALUES (25, 'Barbados');
INSERT INTO countries (countryid, name)
	VALUES (40, 'Belarus');
INSERT INTO countries (countryid, name)
	VALUES (4, 'Belgium');
INSERT INTO countries (countryid, name)
	VALUES (31, 'Belize');
INSERT INTO countries (countryid, name)
	VALUES (26, 'Benin');
INSERT INTO countries (countryid, name)
	VALUES (27, 'Bermuda');
INSERT INTO countries (countryid, name)
	VALUES (30, 'Bhutan');
INSERT INTO countries (countryid, name)
	VALUES (32, 'Bolivia');
INSERT INTO countries (countryid, name)
	VALUES (275, 'Bonaire');
INSERT INTO countries (countryid, name)
	VALUES (234, 'Bosnia and Herzegovina');
INSERT INTO countries (countryid, name)
	VALUES (33, 'Botswana');
INSERT INTO countries (countryid, name)
	VALUES (247, 'Bouvet Island');
INSERT INTO countries (countryid, name)
	VALUES (34, 'Brazil');
INSERT INTO countries (countryid, name)
	VALUES (248, 'British Indian Ocean Territories');
INSERT INTO countries (countryid, name)
	VALUES (39, 'British Virgin Islands');
INSERT INTO countries (countryid, name)
	VALUES (36, 'Brunei');
INSERT INTO countries (countryid, name)
	VALUES (37, 'Bulgaria');
INSERT INTO countries (countryid, name)
	VALUES (216, 'Burkina Faso');
INSERT INTO countries (countryid, name)
	VALUES (35, 'Burundi');
INSERT INTO countries (countryid, name)
	VALUES (42, 'Cambodia');
INSERT INTO countries (countryid, name)
	VALUES (43, 'Cameroon');
INSERT INTO countries (countryid, name)
	VALUES (5, 'Canada');
INSERT INTO countries (countryid, name)
	VALUES (239, 'Cape Verde');
INSERT INTO countries (countryid, name)
	VALUES (44, 'Cayman Islands');
INSERT INTO countries (countryid, name)
	VALUES (46, 'Central African Republic');
INSERT INTO countries (countryid, name)
	VALUES (249, 'Chad');
INSERT INTO countries (countryid, name)
	VALUES (6, 'Chile');
INSERT INTO countries (countryid, name)
	VALUES (47, 'China');
INSERT INTO countries (countryid, name)
	VALUES (250, 'Christmas Island');
INSERT INTO countries (countryid, name)
	VALUES (251, 'Cocos (Keeling) Islands');
INSERT INTO countries (countryid, name)
	VALUES (49, 'Colombia');
INSERT INTO countries (countryid, name)
	VALUES (50, 'Comoros');
INSERT INTO countries (countryid, name)
	VALUES (51, 'Congo');
INSERT INTO countries (countryid, name)
	VALUES (48, 'Cook Islands');
INSERT INTO countries (countryid, name)
	VALUES (52, 'Costa Rica');
INSERT INTO countries (countryid, name)
	VALUES (53, 'Croatia');
INSERT INTO countries (countryid, name)
	VALUES (238, 'Cuba');
INSERT INTO countries (countryid, name)
	VALUES (54, 'Curacao');
INSERT INTO countries (countryid, name)
	VALUES (55, 'Cyprus');
INSERT INTO countries (countryid, name)
	VALUES (56, 'Czech Republic');
INSERT INTO countries (countryid, name)
	VALUES (257, 'Democratic Republic of the Congo');
INSERT INTO countries (countryid, name)
	VALUES (57, 'Denmark');
INSERT INTO countries (countryid, name)
	VALUES (58, 'Djibouti');
INSERT INTO countries (countryid, name)
	VALUES (59, 'Dominica');
INSERT INTO countries (countryid, name)
	VALUES (60, 'Dominican Republic');
INSERT INTO countries (countryid, name)
	VALUES (252, 'East Timor');
INSERT INTO countries (countryid, name)
	VALUES (61, 'Ecuador');
INSERT INTO countries (countryid, name)
	VALUES (63, 'Egypt');
INSERT INTO countries (countryid, name)
	VALUES (64, 'El Salvador');
INSERT INTO countries (countryid, name)
	VALUES (62, 'Equatorial Guinea');
INSERT INTO countries (countryid, name)
	VALUES (65, 'Eritrea');
INSERT INTO countries (countryid, name)
	VALUES (66, 'Estonia');
INSERT INTO countries (countryid, name)
	VALUES (67, 'Ethiopia');
INSERT INTO countries (countryid, name)
	VALUES (69, 'Falkland Islands');
INSERT INTO countries (countryid, name)
	VALUES (68, 'Faroe Islands');
INSERT INTO countries (countryid, name)
	VALUES (71, 'Fiji');
INSERT INTO countries (countryid, name)
	VALUES (72, 'Finland');
INSERT INTO countries (countryid, name)
	VALUES (73, 'France');
INSERT INTO countries (countryid, name)
	VALUES (70, 'French Guiana');
INSERT INTO countries (countryid, name)
	VALUES (74, 'French Polynesia');
INSERT INTO countries (countryid, name)
	VALUES (253, 'French Southern Territories');
INSERT INTO countries (countryid, name)
	VALUES (75, 'Gabon');
INSERT INTO countries (countryid, name)
	VALUES (76, 'Gambia');
INSERT INTO countries (countryid, name)
	VALUES (78, 'Georgia');
INSERT INTO countries (countryid, name)
	VALUES (79, 'Germany');
INSERT INTO countries (countryid, name)
	VALUES (254, 'Ghana');
INSERT INTO countries (countryid, name)
	VALUES (80, 'Gibraltar');
INSERT INTO countries (countryid, name)
	VALUES (82, 'Greece');
INSERT INTO countries (countryid, name)
	VALUES (83, 'Greenland');
INSERT INTO countries (countryid, name)
	VALUES (81, 'Grenada');
INSERT INTO countries (countryid, name)
	VALUES (77, 'Guadeloupe');
INSERT INTO countries (countryid, name)
	VALUES (229, 'Guam');
INSERT INTO countries (countryid, name)
	VALUES (84, 'Guatemala');
INSERT INTO countries (countryid, name)
	VALUES (86, 'Guernsey');
INSERT INTO countries (countryid, name)
	VALUES (255, 'Guinea');
INSERT INTO countries (countryid, name)
	VALUES (85, 'Guinea-Bissau');
INSERT INTO countries (countryid, name)
	VALUES (87, 'Guyana');
INSERT INTO countries (countryid, name)
	VALUES (89, 'Haiti');
INSERT INTO countries (countryid, name)
	VALUES (256, 'Heard Island And Mcdonald Islands');
INSERT INTO countries (countryid, name)
	VALUES (90, 'Honduras');
INSERT INTO countries (countryid, name)
	VALUES (91, 'Hong Kong');
INSERT INTO countries (countryid, name)
	VALUES (92, 'Hungary');
INSERT INTO countries (countryid, name)
	VALUES (93, 'Iceland');
INSERT INTO countries (countryid, name)
	VALUES (94, 'India');
INSERT INTO countries (countryid, name)
	VALUES (95, 'Indonesia');
INSERT INTO countries (countryid, name)
	VALUES (96, 'Iran');
INSERT INTO countries (countryid, name)
	VALUES (97, 'Iraq');
INSERT INTO countries (countryid, name)
	VALUES (7, 'Ireland');
INSERT INTO countries (countryid, name)
	VALUES (243, 'Isle of Man');
INSERT INTO countries (countryid, name)
	VALUES (98, 'Israel');
INSERT INTO countries (countryid, name)
	VALUES (99, 'Italy');
INSERT INTO countries (countryid, name)
	VALUES (100, 'Ivory Coast');
INSERT INTO countries (countryid, name)
	VALUES (101, 'Jamaica');
INSERT INTO countries (countryid, name)
	VALUES (104, 'Japan');
INSERT INTO countries (countryid, name)
	VALUES (102, 'Jersey');
INSERT INTO countries (countryid, name)
	VALUES (103, 'Jordan');
INSERT INTO countries (countryid, name)
	VALUES (106, 'Kazakhstan');
INSERT INTO countries (countryid, name)
	VALUES (107, 'Kenya');
INSERT INTO countries (countryid, name)
	VALUES (109, 'Kiribati');
INSERT INTO countries (countryid, name)
	VALUES (241, 'Kuwait');
INSERT INTO countries (countryid, name)
	VALUES (108, 'Kyrgyzstan');
INSERT INTO countries (countryid, name)
	VALUES (110, 'Laos');
INSERT INTO countries (countryid, name)
	VALUES (111, 'Latvia');
INSERT INTO countries (countryid, name)
	VALUES (113, 'Lebanon');
INSERT INTO countries (countryid, name)
	VALUES (114, 'Lesotho');
INSERT INTO countries (countryid, name)
	VALUES (115, 'Liberia');
INSERT INTO countries (countryid, name)
	VALUES (112, 'Libya');
INSERT INTO countries (countryid, name)
	VALUES (116, 'Liechtenstein');
INSERT INTO countries (countryid, name)
	VALUES (117, 'Lithuania');
INSERT INTO countries (countryid, name)
	VALUES (8, 'Luxembourg');
INSERT INTO countries (countryid, name)
	VALUES (258, 'Macau');
INSERT INTO countries (countryid, name)
	VALUES (125, 'Macedonia');
INSERT INTO countries (countryid, name)
	VALUES (119, 'Madagascar');
INSERT INTO countries (countryid, name)
	VALUES (129, 'Malawi');
INSERT INTO countries (countryid, name)
	VALUES (121, 'Malaysia');
INSERT INTO countries (countryid, name)
	VALUES (124, 'Maldives');
INSERT INTO countries (countryid, name)
	VALUES (127, 'Mali');
INSERT INTO countries (countryid, name)
	VALUES (128, 'Malta');
INSERT INTO countries (countryid, name)
	VALUES (240, 'Marshall Islands');
INSERT INTO countries (countryid, name)
	VALUES (122, 'Martinique');
INSERT INTO countries (countryid, name)
	VALUES (123, 'Mauritania');
INSERT INTO countries (countryid, name)
	VALUES (134, 'Mauritius');
INSERT INTO countries (countryid, name)
	VALUES (259, 'Mayotte');
INSERT INTO countries (countryid, name)
	VALUES (228, 'Mexico');
INSERT INTO countries (countryid, name)
	VALUES (242, 'Micronesia');
INSERT INTO countries (countryid, name)
	VALUES (237, 'Moldova');
INSERT INTO countries (countryid, name)
	VALUES (130, 'Monaco');
INSERT INTO countries (countryid, name)
	VALUES (131, 'Mongolia');
INSERT INTO countries (countryid, name)
	VALUES (274, 'Montenegro');
INSERT INTO countries (countryid, name)
	VALUES (135, 'Montserrat');
INSERT INTO countries (countryid, name)
	VALUES (132, 'Morocco');
INSERT INTO countries (countryid, name)
	VALUES (133, 'Mozambique');
INSERT INTO countries (countryid, name)
	VALUES (136, 'Myanmar');
INSERT INTO countries (countryid, name)
	VALUES (137, 'Namibia');
INSERT INTO countries (countryid, name)
	VALUES (138, 'Nauru');
INSERT INTO countries (countryid, name)
	VALUES (140, 'Nepal');
INSERT INTO countries (countryid, name)
	VALUES (141, 'Netherlands');
INSERT INTO countries (countryid, name)
	VALUES (148, 'Netherlands Antilles');
INSERT INTO countries (countryid, name)
	VALUES (142, 'Nevis and St Kitts');
INSERT INTO countries (countryid, name)
	VALUES (41, 'New Caledonia');
INSERT INTO countries (countryid, name)
	VALUES (9, 'New Zealand');
INSERT INTO countries (countryid, name)
	VALUES (144, 'Nicaragua');
INSERT INTO countries (countryid, name)
	VALUES (143, 'Niger');
INSERT INTO countries (countryid, name)
	VALUES (145, 'Nigeria');
INSERT INTO countries (countryid, name)
	VALUES (149, 'Niue');
INSERT INTO countries (countryid, name)
	VALUES (260, 'Norfolk Island');
INSERT INTO countries (countryid, name)
	VALUES (146, 'North Korea');
INSERT INTO countries (countryid, name)
	VALUES (236, 'Northern Mariana Islands');
INSERT INTO countries (countryid, name)
	VALUES (147, 'Norway');
INSERT INTO countries (countryid, name)
	VALUES (150, 'Oman');
INSERT INTO countries (countryid, name)
	VALUES (151, 'Pakistan');
INSERT INTO countries (countryid, name)
	VALUES (261, 'Palau');
INSERT INTO countries (countryid, name)
	VALUES (276, 'Palestine');
INSERT INTO countries (countryid, name)
	VALUES (152, 'Panama');
INSERT INTO countries (countryid, name)
	VALUES (156, 'Papua New Guinea');
INSERT INTO countries (countryid, name)
	VALUES (262, 'Paraguay');
INSERT INTO countries (countryid, name)
	VALUES (153, 'Peru');
INSERT INTO countries (countryid, name)
	VALUES (154, 'Philippines');
INSERT INTO countries (countryid, name)
	VALUES (155, 'Pitcairn Islands');
INSERT INTO countries (countryid, name)
	VALUES (158, 'Poland');
INSERT INTO countries (countryid, name)
	VALUES (159, 'Portugal');
INSERT INTO countries (countryid, name)
	VALUES (226, 'Puerto Rico');
INSERT INTO countries (countryid, name)
	VALUES (160, 'Qatar');
INSERT INTO countries (countryid, name)
	VALUES (161, 'Reunion');
INSERT INTO countries (countryid, name)
	VALUES (162, 'Romania');
INSERT INTO countries (countryid, name)
	VALUES (163, 'Russia');
INSERT INTO countries (countryid, name)
	VALUES (164, 'Rwanda');
INSERT INTO countries (countryid, name)
	VALUES (277, 'Saba');
INSERT INTO countries (countryid, name)
	VALUES (171, 'Saint Helena');
INSERT INTO countries (countryid, name)
	VALUES (264, 'Saint Kitts and Nevis');
INSERT INTO countries (countryid, name)
	VALUES (173, 'Saint Lucia');
INSERT INTO countries (countryid, name)
	VALUES (217, 'Samoa');
INSERT INTO countries (countryid, name)
	VALUES (183, 'San Marino');
INSERT INTO countries (countryid, name)
	VALUES (176, 'Sao Tome and Principe');
INSERT INTO countries (countryid, name)
	VALUES (166, 'Saudi Arabia');
INSERT INTO countries (countryid, name)
	VALUES (167, 'Senegal');
INSERT INTO countries (countryid, name)
	VALUES (222, 'Serbia');
INSERT INTO countries (countryid, name)
	VALUES (168, 'Seychelles');
INSERT INTO countries (countryid, name)
	VALUES (178, 'Sierra Leone');
INSERT INTO countries (countryid, name)
	VALUES (179, 'Singapore');
INSERT INTO countries (countryid, name)
	VALUES (182, 'Slovakia');
INSERT INTO countries (countryid, name)
	VALUES (181, 'Slovenia');
INSERT INTO countries (countryid, name)
	VALUES (184, 'Solomon Islands');
INSERT INTO countries (countryid, name)
	VALUES (185, 'Somalia');
INSERT INTO countries (countryid, name)
	VALUES (165, 'South Africa');
INSERT INTO countries (countryid, name)
	VALUES (267, 'South Georgia and Sandwich Islands');
INSERT INTO countries (countryid, name)
	VALUES (180, 'South Korea');
INSERT INTO countries (countryid, name)
	VALUES (278, 'South Sudan');
INSERT INTO countries (countryid, name)
	VALUES (186, 'Spain');
INSERT INTO countries (countryid, name)
	VALUES (187, 'Sri Lanka');
INSERT INTO countries (countryid, name)
	VALUES (169, 'St Barthelemy');
INSERT INTO countries (countryid, name)
	VALUES (170, 'St Eustatius');
INSERT INTO countries (countryid, name)
	VALUES (172, 'St Kitts');
INSERT INTO countries (countryid, name)
	VALUES (175, 'St Pierre Miquelon');
INSERT INTO countries (countryid, name)
	VALUES (177, 'St Vince Grenadines');
INSERT INTO countries (countryid, name)
	VALUES (174, 'St. Martin');
INSERT INTO countries (countryid, name)
	VALUES (188, 'Sudan');
INSERT INTO countries (countryid, name)
	VALUES (189, 'Suriname');
INSERT INTO countries (countryid, name)
	VALUES (268, 'Svalbard and Jan Mayen');
INSERT INTO countries (countryid, name)
	VALUES (190, 'Swaziland');
INSERT INTO countries (countryid, name)
	VALUES (10, 'Sweden');
INSERT INTO countries (countryid, name)
	VALUES (192, 'Switzerland');
INSERT INTO countries (countryid, name)
	VALUES (193, 'Syria');
INSERT INTO countries (countryid, name)
	VALUES (194, 'Taiwan');
INSERT INTO countries (countryid, name)
	VALUES (195, 'Tajikistan');
INSERT INTO countries (countryid, name)
	VALUES (196, 'Tanzania');
INSERT INTO countries (countryid, name)
	VALUES (198, 'Thailand');
INSERT INTO countries (countryid, name)
	VALUES (200, 'Togo');
INSERT INTO countries (countryid, name)
	VALUES (269, 'Tokelau');
INSERT INTO countries (countryid, name)
	VALUES (201, 'Tonga');
INSERT INTO countries (countryid, name)
	VALUES (202, 'Trinidad and Tobago');
INSERT INTO countries (countryid, name)
	VALUES (203, 'Tunisia');
INSERT INTO countries (countryid, name)
	VALUES (204, 'Turkey');
INSERT INTO countries (countryid, name)
	VALUES (199, 'Turkmenistan');
INSERT INTO countries (countryid, name)
	VALUES (197, 'Turks and Caicos Islands');
INSERT INTO countries (countryid, name)
	VALUES (205, 'Tuvalu');
INSERT INTO countries (countryid, name)
	VALUES (208, 'Uganda');
INSERT INTO countries (countryid, name)
	VALUES (207, 'Ukraine');
INSERT INTO countries (countryid, name)
	VALUES (206, 'United Arab Emirates');
INSERT INTO countries (countryid, name)
	VALUES (11, 'United Kingdom');
INSERT INTO countries (countryid, name)
	VALUES (210, 'Uruguay');
INSERT INTO countries (countryid, name)
	VALUES (270, 'US Minor Outlying Islands');
INSERT INTO countries (countryid, name)
	VALUES (235, 'US Virgin Islands');
INSERT INTO countries (countryid, name)
	VALUES (211, 'Uzbekistan');
INSERT INTO countries (countryid, name)
	VALUES (212, 'Vanuatu');
INSERT INTO countries (countryid, name)
	VALUES (213, 'Vatican City State');
INSERT INTO countries (countryid, name)
	VALUES (214, 'Venezuela');
INSERT INTO countries (countryid, name)
	VALUES (215, 'Vietnam');
INSERT INTO countries (countryid, name)
	VALUES (218, 'Wallis And Futuna Islands');
INSERT INTO countries (countryid, name)
	VALUES (271, 'Western Sahara');
INSERT INTO countries (countryid, name)
	VALUES (220, 'Yemen');
INSERT INTO countries (countryid, name)
	VALUES (224, 'Zambia');
INSERT INTO countries (countryid, name)
	VALUES (225, 'Zimbabwe');

/* Need to look up/translate some of these unicode characters */
INSERT INTO states (stateid, name)
	VALUES (189, 'Abruzzo');
INSERT INTO states (stateid, name)
	VALUES (162, 'Acre');
INSERT INTO states (stateid, name)
	VALUES (454, 'Aguascalientes');
INSERT INTO states (stateid, name)
	VALUES (312, 'Aichi');
INSERT INTO states (stateid, name)
	VALUES (240, 'Akershus');
INSERT INTO states (stateid, name)
	VALUES (383, 'Akita');
INSERT INTO states (stateid, name)
	VALUES (60, 'Alabama');
INSERT INTO states (stateid, name)
	VALUES (163, 'Alagoas');
INSERT INTO states (stateid, name)
	VALUES (2, 'Alaska');
INSERT INTO states (stateid, name)
	VALUES (63, 'Alberta');
INSERT INTO states (stateid, name)
	VALUES (433, 'Alsace');
INSERT INTO states (stateid, name)
	VALUES (164, 'Amap&#225;');
INSERT INTO states (stateid, name)
	VALUES (165, 'Amazonas');
INSERT INTO states (stateid, name)
	VALUES (116, 'Andaluc&#237;a');
INSERT INTO states (stateid, name)
	VALUES (87, 'Antwerpen');
INSERT INTO states (stateid, name)
	VALUES (313, 'Aomori');
INSERT INTO states (stateid, name)
	VALUES (412, 'Aquitaine');
INSERT INTO states (stateid, name)
	VALUES (119, 'Arag&#243;n');
INSERT INTO states (stateid, name)
	VALUES (3, 'Arizona');
INSERT INTO states (stateid, name)
	VALUES (4, 'Arkansas');
INSERT INTO states (stateid, name)
	VALUES (380, 'Armed Forces Americas');
INSERT INTO states (stateid, name)
	VALUES (381, 'Armed Forces Europe');
INSERT INTO states (stateid, name)
	VALUES (382, 'Armed Forces Pacific');
INSERT INTO states (stateid, name)
	VALUES (113, 'Arquip&#233;lago da Madeira');
INSERT INTO states (stateid, name)
	VALUES (114, 'Arquip&#233;lago dos A&#231;ores');
INSERT INTO states (stateid, name)
	VALUES (247, 'Aust-Agder');
INSERT INTO states (stateid, name)
	VALUES (59, 'Australian Capital Territory');
INSERT INTO states (stateid, name)
	VALUES (413, 'Auvergne');
INSERT INTO states (stateid, name)
	VALUES (95, 'Aveiro');
INSERT INTO states (stateid, name)
	VALUES (434, 'B&#225;cs-Kiskun');
INSERT INTO states (stateid, name)
	VALUES (135, 'Baden-W&#252;rttemberg');
INSERT INTO states (stateid, name)
	VALUES (166, 'Bahia');
INSERT INTO states (stateid, name)
	VALUES (455, 'Baja California');
INSERT INTO states (stateid, name)
	VALUES (456, 'Baja California Sur');
INSERT INTO states (stateid, name)
	VALUES (287, 'Banskobystrick&#253; kraj');
INSERT INTO states (stateid, name)
	VALUES (435, 'Baranya');
INSERT INTO states (stateid, name)
	VALUES (190, 'Basilicata');
INSERT INTO states (stateid, name)
	VALUES (414, 'Basse-Normandie');
INSERT INTO states (stateid, name)
	VALUES (136, 'Bayern');
INSERT INTO states (stateid, name)
	VALUES (96, 'Beja');
INSERT INTO states (stateid, name)
	VALUES (436, 'B&#233;k&#233;s');
INSERT INTO states (stateid, name)
	VALUES (137, 'Berlin');
INSERT INTO states (stateid, name)
	VALUES (359, 'Blekinge');
INSERT INTO states (stateid, name)
	VALUES (437, 'Borsod-Aba&#250;j-Zempl&#233;n');
INSERT INTO states (stateid, name)
	VALUES (415, 'Bourgogne');
INSERT INTO states (stateid, name)
	VALUES (91, 'Brabant wallon');
INSERT INTO states (stateid, name)
	VALUES (97, 'Braga');
INSERT INTO states (stateid, name)
	VALUES (98, 'Bragan&#231;a');
INSERT INTO states (stateid, name)
	VALUES (138, 'Brandenburg');
INSERT INTO states (stateid, name)
	VALUES (288, 'Bratislavsk&#253; kraj');
INSERT INTO states (stateid, name)
	VALUES (139, 'Bremen');
INSERT INTO states (stateid, name)
	VALUES (416, 'Bretagne');
INSERT INTO states (stateid, name)
	VALUES (64, 'British Columbia');
INSERT INTO states (stateid, name)
	VALUES (93, 'Brussels');
INSERT INTO states (stateid, name)
	VALUES (438, 'Budapest');
INSERT INTO states (stateid, name)
	VALUES (258, 'Burgenland');
INSERT INTO states (stateid, name)
	VALUES (297, 'Busan');
INSERT INTO states (stateid, name)
	VALUES (244, 'Buskerud');
INSERT INTO states (stateid, name)
	VALUES (192, 'Calabria');
INSERT INTO states (stateid, name)
	VALUES (5, 'California');
INSERT INTO states (stateid, name)
	VALUES (193, 'Campania');
INSERT INTO states (stateid, name)
	VALUES (457, 'Campeche');
INSERT INTO states (stateid, name)
	VALUES (130, 'Cantabria');
INSERT INTO states (stateid, name)
	VALUES (99, 'Castelo Branco');
INSERT INTO states (stateid, name)
	VALUES (115, 'Castilla y Le&#243;n');
INSERT INTO states (stateid, name)
	VALUES (117, 'Castilla-La Mancha');
INSERT INTO states (stateid, name)
	VALUES (121, 'Catalu&#241;a');
INSERT INTO states (stateid, name)
	VALUES (167, 'Cear&#225;');
INSERT INTO states (stateid, name)
	VALUES (417, 'Centre');
INSERT INTO states (stateid, name)
	VALUES (133, 'Ceuta');
INSERT INTO states (stateid, name)
	VALUES (418, 'Champagne-Ardenne');
INSERT INTO states (stateid, name)
	VALUES (486, 'Chatham Islands');
INSERT INTO states (stateid, name)
	VALUES (458, 'Chiapas');
INSERT INTO states (stateid, name)
	VALUES (314, 'Chiba');
INSERT INTO states (stateid, name)
	VALUES (459, 'Chihuahua');
INSERT INTO states (stateid, name)
	VALUES (305, 'Chungcheong buk do');
INSERT INTO states (stateid, name)
	VALUES (306, 'Chungcheong nam do');
INSERT INTO states (stateid, name)
	VALUES (460, 'Coahuila');
INSERT INTO states (stateid, name)
	VALUES (100, 'Coimbra');
INSERT INTO states (stateid, name)
	VALUES (461, 'Colima');
INSERT INTO states (stateid, name)
	VALUES (6, 'Colorado');
INSERT INTO states (stateid, name)
	VALUES (127, 'Comunidad de Madrid');
INSERT INTO states (stateid, name)
	VALUES (126, 'Comunidad Foral de Navarra');
INSERT INTO states (stateid, name)
	VALUES (123, 'Comunidad Valenciana');
INSERT INTO states (stateid, name)
	VALUES (227, 'Connacht');
INSERT INTO states (stateid, name)
	VALUES (7, 'Connecticut');
INSERT INTO states (stateid, name)
	VALUES (419, 'Corse');
INSERT INTO states (stateid, name)
	VALUES (439, 'Csongr&#225;d');
INSERT INTO states (stateid, name)
	VALUES (298, 'Daegu');
INSERT INTO states (stateid, name)
	VALUES (301, 'Daejeon');
INSERT INTO states (stateid, name)
	VALUES (360, 'Dalarna');
INSERT INTO states (stateid, name)
	VALUES (9, 'Delaware');
INSERT INTO states (stateid, name)
	VALUES (8, 'District of Columbia');
INSERT INTO states (stateid, name)
	VALUES (168, 'Distrito Federal');
INSERT INTO states (stateid, name)
	VALUES (462, 'Distrito Federal');
INSERT INTO states (stateid, name)
	VALUES (396, 'Dolnośląskie');
INSERT INTO states (stateid, name)
	VALUES (385, 'Drenthe');
INSERT INTO states (stateid, name)
	VALUES (226, 'Dublin');
INSERT INTO states (stateid, name)
	VALUES (463, 'Durango');
INSERT INTO states (stateid, name)
	VALUES (215, 'East Midlands');
INSERT INTO states (stateid, name)
	VALUES (153, 'Eastern Cape');
INSERT INTO states (stateid, name)
	VALUES (219, 'Eastern England');
INSERT INTO states (stateid, name)
	VALUES (315, 'Ehime');
INSERT INTO states (stateid, name)
	VALUES (194, 'Emilia–Romagna ');
INSERT INTO states (stateid, name)
	VALUES (234, 'Espace Mittelland (BE/SO)');
INSERT INTO states (stateid, name)
	VALUES (169, 'Esp&#237;rito Santo');
INSERT INTO states (stateid, name)
	VALUES (101, '&#201;vora');
INSERT INTO states (stateid, name)
	VALUES (120, 'Extremadura');
INSERT INTO states (stateid, name)
	VALUES (102, 'Faro');
INSERT INTO states (stateid, name)
	VALUES (440, 'Fej&#233;r');
INSERT INTO states (stateid, name)
	VALUES (257, 'Finnmark');
INSERT INTO states (stateid, name)
	VALUES (395, 'Flevoland');
INSERT INTO states (stateid, name)
	VALUES (10, 'Florida');
INSERT INTO states (stateid, name)
	VALUES (420, 'Franche-Comt&#233;');
INSERT INTO states (stateid, name)
	VALUES (160, 'Free State');
INSERT INTO states (stateid, name)
	VALUES (394, 'Friesland');
INSERT INTO states (stateid, name)
	VALUES (195, 'Friuli–Venezia Giulia');
INSERT INTO states (stateid, name)
	VALUES (316, 'Fukui');
INSERT INTO states (stateid, name)
	VALUES (317, 'Fukuoka');
INSERT INTO states (stateid, name)
	VALUES (318, 'Fukushima');
INSERT INTO states (stateid, name)
	VALUES (122, 'Galicia');
INSERT INTO states (stateid, name)
	VALUES (304, 'Gangwondo');
INSERT INTO states (stateid, name)
	VALUES (159, 'Gauteng');
INSERT INTO states (stateid, name)
	VALUES (362, 'G&#228;vleborg');
INSERT INTO states (stateid, name)
	VALUES (387, 'Gelderland');
INSERT INTO states (stateid, name)
	VALUES (11, 'Georgia');
INSERT INTO states (stateid, name)
	VALUES (319, 'Gifu');
INSERT INTO states (stateid, name)
	VALUES (170, 'Goi&#225;s');
INSERT INTO states (stateid, name)
	VALUES (361, 'Gotland');
INSERT INTO states (stateid, name)
	VALUES (229, 'Graubuenden (GR)');
INSERT INTO states (stateid, name)
	VALUES (384, 'Groningen');
INSERT INTO states (stateid, name)
	VALUES (464, 'Guanajuato');
INSERT INTO states (stateid, name)
	VALUES (103, 'Guarda');
INSERT INTO states (stateid, name)
	VALUES (465, 'Guerrero');
INSERT INTO states (stateid, name)
	VALUES (320, 'Gunma');
INSERT INTO states (stateid, name)
	VALUES (300, 'Gwangju');
INSERT INTO states (stateid, name)
	VALUES (303, 'Gyeonggido');
INSERT INTO states (stateid, name)
	VALUES (309, 'Gyeongsang buk do');
INSERT INTO states (stateid, name)
	VALUES (310, 'Gyeongsang nam do');
INSERT INTO states (stateid, name)
	VALUES (441, 'Gyor-Moson-Sopron');
INSERT INTO states (stateid, name)
	VALUES (88, 'Hainaut');
INSERT INTO states (stateid, name)
	VALUES (442, 'Hajd&#250;-Bihar');
INSERT INTO states (stateid, name)
	VALUES (363, 'Halland');
INSERT INTO states (stateid, name)
	VALUES (140, 'Hamburg');
INSERT INTO states (stateid, name)
	VALUES (421, 'Haute-Normandie');
INSERT INTO states (stateid, name)
	VALUES (12, 'Hawaii');
INSERT INTO states (stateid, name)
	VALUES (242, 'Hedmark');
INSERT INTO states (stateid, name)
	VALUES (150, 'Hessen');
INSERT INTO states (stateid, name)
	VALUES (443, 'Heves');
INSERT INTO states (stateid, name)
	VALUES (466, 'Hidalgo');
INSERT INTO states (stateid, name)
	VALUES (321, 'Hiroshima');
INSERT INTO states (stateid, name)
	VALUES (286, 'Hlavni mesto Praha');
INSERT INTO states (stateid, name)
	VALUES (322, 'Hokkaido');
INSERT INTO states (stateid, name)
	VALUES (250, 'Hordaland');
INSERT INTO states (stateid, name)
	VALUES (323, 'Hyogo');
INSERT INTO states (stateid, name)
	VALUES (324, 'Ibaraki');
INSERT INTO states (stateid, name)
	VALUES (13, 'Idaho');
INSERT INTO states (stateid, name)
	VALUES (422, '&#206;le-de-France');
INSERT INTO states (stateid, name)
	VALUES (14, 'Illinois');
INSERT INTO states (stateid, name)
	VALUES (299, 'Incheon');
INSERT INTO states (stateid, name)
	VALUES (15, 'Indiana');
INSERT INTO states (stateid, name)
	VALUES (16, 'Iowa');
INSERT INTO states (stateid, name)
	VALUES (325, 'Ishikawa');
INSERT INTO states (stateid, name)
	VALUES (132, 'Islas Baleares');
INSERT INTO states (stateid, name)
	VALUES (128, 'Islas Canarias');
INSERT INTO states (stateid, name)
	VALUES (326, 'Iwate');
INSERT INTO states (stateid, name)
	VALUES (467, 'Jalisco');
INSERT INTO states (stateid, name)
	VALUES (364, 'J&#228;mtland');
INSERT INTO states (stateid, name)
	VALUES (444, 'J&#225;sz-Nagykun-Szolnok');
INSERT INTO states (stateid, name)
	VALUES (311, 'Jejudo');
INSERT INTO states (stateid, name)
	VALUES (307, 'Jeolla buk do');
INSERT INTO states (stateid, name)
	VALUES (308, 'Jeolla nam do');
INSERT INTO states (stateid, name)
	VALUES (274, 'Jihocesky kraj');
INSERT INTO states (stateid, name)
	VALUES (273, 'Jihomoravsky kraj');
INSERT INTO states (stateid, name)
	VALUES (365, 'J&#246;nk&#246;ping');
INSERT INTO states (stateid, name)
	VALUES (236, 'Jura (JU/NE)');
INSERT INTO states (stateid, name)
	VALUES (327, 'Kagawa');
INSERT INTO states (stateid, name)
	VALUES (328, 'Kagoshima');
INSERT INTO states (stateid, name)
	VALUES (366, 'Kalmar');
INSERT INTO states (stateid, name)
	VALUES (329, 'Kanagawa');
INSERT INTO states (stateid, name)
	VALUES (17, 'Kansas');
INSERT INTO states (stateid, name)
	VALUES (276, 'Karlovarsky kraj');
INSERT INTO states (stateid, name)
	VALUES (259, 'K&#228;rnten');
INSERT INTO states (stateid, name)
	VALUES (18, 'Kentucky');
INSERT INTO states (stateid, name)
	VALUES (330, 'Kochi');
INSERT INTO states (stateid, name)
	VALUES (445, 'Kom&#225;rom-Esztergom');
INSERT INTO states (stateid, name)
	VALUES (289, 'Košick&#253; kraj');
INSERT INTO states (stateid, name)
	VALUES (284, 'Kraj Vysocina');
INSERT INTO states (stateid, name)
	VALUES (275, 'Kralovehradecky kraj');
INSERT INTO states (stateid, name)
	VALUES (367, 'Kronoberg');
INSERT INTO states (stateid, name)
	VALUES (397, 'Kujawsko-Pomorskie');
INSERT INTO states (stateid, name)
	VALUES (331, 'Kumamoto');
INSERT INTO states (stateid, name)
	VALUES (157, 'Kwazulu Natal');
INSERT INTO states (stateid, name)
	VALUES (332, 'Kyoto');
INSERT INTO states (stateid, name)
	VALUES (131, 'La Rioja');
INSERT INTO states (stateid, name)
	VALUES (423, 'Languedoc-Roussillon');
INSERT INTO states (stateid, name)
	VALUES (196, 'Lazio');
INSERT INTO states (stateid, name)
	VALUES (228, 'Leinster');
INSERT INTO states (stateid, name)
	VALUES (104, 'Leiria');
INSERT INTO states (stateid, name)
	VALUES (277, 'Liberecky kraj');
INSERT INTO states (stateid, name)
	VALUES (80, 'Li&#232;ge');
INSERT INTO states (stateid, name)
	VALUES (197, 'Liguria');
INSERT INTO states (stateid, name)
	VALUES (89, 'Limburg');
INSERT INTO states (stateid, name)
	VALUES (393, 'Limburg');
INSERT INTO states (stateid, name)
	VALUES (424, 'Limousin');
INSERT INTO states (stateid, name)
	VALUES (158, 'Limpopo');
INSERT INTO states (stateid, name)
	VALUES (105, 'Lisboa');
INSERT INTO states (stateid, name)
	VALUES (400, 'Ł&#243;dzkie');
INSERT INTO states (stateid, name)
	VALUES (198, 'Lombardia');
INSERT INTO states (stateid, name)
	VALUES (220, 'London');
INSERT INTO states (stateid, name)
	VALUES (425, 'Lorraine');
INSERT INTO states (stateid, name)
	VALUES (19, 'Louisiana');
INSERT INTO states (stateid, name)
	VALUES (398, 'Lubelskie');
INSERT INTO states (stateid, name)
	VALUES (399, 'Lubuskie');
INSERT INTO states (stateid, name)
	VALUES (90, 'Luxembourg');
INSERT INTO states (stateid, name)
	VALUES (20, 'Maine');
INSERT INTO states (stateid, name)
	VALUES (401, 'Małopolskie');
INSERT INTO states (stateid, name)
	VALUES (65, 'Manitoba');
INSERT INTO states (stateid, name)
	VALUES (171, 'Maranh&#227;o');
INSERT INTO states (stateid, name)
	VALUES (199, 'Marche');
INSERT INTO states (stateid, name)
	VALUES (21, 'Maryland');
INSERT INTO states (stateid, name)
	VALUES (22, 'Massachusetts');
INSERT INTO states (stateid, name)
	VALUES (172, 'Mato Grosso');
INSERT INTO states (stateid, name)
	VALUES (173, 'Mato Grosso do Sul');
INSERT INTO states (stateid, name)
	VALUES (402, 'Mazowieckie');
INSERT INTO states (stateid, name)
	VALUES (141, 'Mecklenburg-Vorpommern');
INSERT INTO states (stateid, name)
	VALUES (134, 'Melilla');
INSERT INTO states (stateid, name)
	VALUES (468, 'M&#233;xico');
INSERT INTO states (stateid, name)
	VALUES (23, 'Michigan');
INSERT INTO states (stateid, name)
	VALUES (469, 'Michoac&#225;n');
INSERT INTO states (stateid, name)
	VALUES (426, 'Midi-Pyr&#233;n&#233;es');
INSERT INTO states (stateid, name)
	VALUES (333, 'Mie');
INSERT INTO states (stateid, name)
	VALUES (174, 'Minas Gerais');
INSERT INTO states (stateid, name)
	VALUES (24, 'Minnesota');
INSERT INTO states (stateid, name)
	VALUES (25, 'Mississippi');
INSERT INTO states (stateid, name)
	VALUES (26, 'Missouri');
INSERT INTO states (stateid, name)
	VALUES (334, 'Miyagi');
INSERT INTO states (stateid, name)
	VALUES (335, 'Miyazaki');
INSERT INTO states (stateid, name)
	VALUES (200, 'Molise');
INSERT INTO states (stateid, name)
	VALUES (27, 'Montana');
INSERT INTO states (stateid, name)
	VALUES (279, 'Moravskoslezsky kraj');
INSERT INTO states (stateid, name)
	VALUES (252, 'M&#248;re og Romsdal');
INSERT INTO states (stateid, name)
	VALUES (470, 'Morelos');
INSERT INTO states (stateid, name)
	VALUES (155, 'Mpumalanga');
INSERT INTO states (stateid, name)
	VALUES (225, 'Munster');
INSERT INTO states (stateid, name)
	VALUES (336, 'Nagano');
INSERT INTO states (stateid, name)
	VALUES (337, 'Nagasaki');
INSERT INTO states (stateid, name)
	VALUES (81, 'Namur');
INSERT INTO states (stateid, name)
	VALUES (338, 'Nara');
INSERT INTO states (stateid, name)
	VALUES (471, 'Nayarit');
INSERT INTO states (stateid, name)
	VALUES (28, 'Nebraska');
INSERT INTO states (stateid, name)
	VALUES (29, 'Nevada');
INSERT INTO states (stateid, name)
	VALUES (66, 'New Brunswick');
INSERT INTO states (stateid, name)
	VALUES (30, 'New Hampshire');
INSERT INTO states (stateid, name)
	VALUES (31, 'New Jersey');
INSERT INTO states (stateid, name)
	VALUES (32, 'New Mexico');
INSERT INTO states (stateid, name)
	VALUES (52, 'New South Wales');
INSERT INTO states (stateid, name)
	VALUES (33, 'New York');
INSERT INTO states (stateid, name)
	VALUES (67, 'Newfoundland and Labrador');
INSERT INTO states (stateid, name)
	VALUES (260, 'Nieder&#246;sterreich');
INSERT INTO states (stateid, name)
	VALUES (142, 'Niedersachsen');
INSERT INTO states (stateid, name)
	VALUES (339, 'Niigata');
INSERT INTO states (stateid, name)
	VALUES (290, 'Nitriansky kraj');
INSERT INTO states (stateid, name)
	VALUES (446, 'N&#243;gr&#225;d');
INSERT INTO states (stateid, name)
	VALUES (392, 'Noord-Brabant');
INSERT INTO states (stateid, name)
	VALUES (389, 'Noord-Holland');
INSERT INTO states (stateid, name)
	VALUES (255, 'Nordland');
INSERT INTO states (stateid, name)
	VALUES (427, 'Nord-Pas-de-Calais');
INSERT INTO states (stateid, name)
	VALUES (143, 'Nordrhein-Westfalen');
INSERT INTO states (stateid, name)
	VALUES (254, 'Nord-Tr&#248;ndelag');
INSERT INTO states (stateid, name)
	VALUES (232, 'Nordwestschweiz (AG/BL/BS)');
INSERT INTO states (stateid, name)
	VALUES (368, 'Norrbotten');
INSERT INTO states (stateid, name)
	VALUES (34, 'North Carolina');
INSERT INTO states (stateid, name)
	VALUES (35, 'North Dakota');
INSERT INTO states (stateid, name)
	VALUES (82, 'North Island');
INSERT INTO states (stateid, name)
	VALUES (217, 'North Wales');
INSERT INTO states (stateid, name)
	VALUES (156, 'North West');
INSERT INTO states (stateid, name)
	VALUES (212, 'Northeast England');
INSERT INTO states (stateid, name)
	VALUES (154, 'Northern Cape');
INSERT INTO states (stateid, name)
	VALUES (210, 'Northern Scotland');
INSERT INTO states (stateid, name)
	VALUES (58, 'Northern Territory');
INSERT INTO states (stateid, name)
	VALUES (213, 'Northwest England');
INSERT INTO states (stateid, name)
	VALUES (72, 'Northwest Territories');
INSERT INTO states (stateid, name)
	VALUES (68, 'Nova Scotia');
INSERT INTO states (stateid, name)
	VALUES (472, 'Nuevo Le&#243;n');
INSERT INTO states (stateid, name)
	VALUES (73, 'Nunavut');
INSERT INTO states (stateid, name)
	VALUES (473, 'Oaxaca');
INSERT INTO states (stateid, name)
	VALUES (261, 'Ober&#246;sterreich');
INSERT INTO states (stateid, name)
	VALUES (36, 'Ohio');
INSERT INTO states (stateid, name)
	VALUES (340, 'Oita');
INSERT INTO states (stateid, name)
	VALUES (341, 'Okayama');
INSERT INTO states (stateid, name)
	VALUES (342, 'Okinawa');
INSERT INTO states (stateid, name)
	VALUES (37, 'Oklahoma');
INSERT INTO states (stateid, name)
	VALUES (278, 'Olomoucky kraj');
INSERT INTO states (stateid, name)
	VALUES (69, 'Ontario');
INSERT INTO states (stateid, name)
	VALUES (76, 'Oost-Vlaanderen');
INSERT INTO states (stateid, name)
	VALUES (403, 'Opolskie');
INSERT INTO states (stateid, name)
	VALUES (243, 'Oppland');
INSERT INTO states (stateid, name)
	VALUES (378, '&#214;rebro');
INSERT INTO states (stateid, name)
	VALUES (38, 'Oregon');
INSERT INTO states (stateid, name)
	VALUES (343, 'Osaka');
INSERT INTO states (stateid, name)
	VALUES (241, 'Oslo');
INSERT INTO states (stateid, name)
	VALUES (379, '&#214;sterg&#246;tland');
INSERT INTO states (stateid, name)
	VALUES (239, '&#216;stfold');
INSERT INTO states (stateid, name)
	VALUES (230, 'Ostschweiz (SG/SH/TG/AI/AR/GL)');
INSERT INTO states (stateid, name)
	VALUES (386, 'Overijssel');
INSERT INTO states (stateid, name)
	VALUES (129, 'Pa&#237;s Vasco');
INSERT INTO states (stateid, name)
	VALUES (175, 'Par&#225;');
INSERT INTO states (stateid, name)
	VALUES (176, 'Para&#237;ba');
INSERT INTO states (stateid, name)
	VALUES (177, 'Paran&#225;');
INSERT INTO states (stateid, name)
	VALUES (280, 'Pardubicky kraj');
INSERT INTO states (stateid, name)
	VALUES (428, 'Pays de la Loire');
INSERT INTO states (stateid, name)
	VALUES (39, 'Pennsylvania');
INSERT INTO states (stateid, name)
	VALUES (178, 'Pernambuco');
INSERT INTO states (stateid, name)
	VALUES (447, 'Pest');
INSERT INTO states (stateid, name)
	VALUES (179, 'Piau&#237;');
INSERT INTO states (stateid, name)
	VALUES (429, 'Picardie');
INSERT INTO states (stateid, name)
	VALUES (201, 'Piemonte');
INSERT INTO states (stateid, name)
	VALUES (281, 'Plzensky kraj');
INSERT INTO states (stateid, name)
	VALUES (404, 'Podkarpackie');
INSERT INTO states (stateid, name)
	VALUES (405, 'Podlaskie');
INSERT INTO states (stateid, name)
	VALUES (430, 'Poitou-Charentes');
INSERT INTO states (stateid, name)
	VALUES (406, 'Pomorskie');
INSERT INTO states (stateid, name)
	VALUES (106, 'Portalegre');
INSERT INTO states (stateid, name)
	VALUES (107, 'Porto');
INSERT INTO states (stateid, name)
	VALUES (291, 'Prešovsk&#253; kraj');
INSERT INTO states (stateid, name)
	VALUES (70, 'Prince Edward Island');
INSERT INTO states (stateid, name)
	VALUES (125, 'Principado de Asturias');
INSERT INTO states (stateid, name)
	VALUES (431, 'Provence-Alpes-C&#244;te d&#39;Azur');
INSERT INTO states (stateid, name)
	VALUES (474, 'Puebla');
INSERT INTO states (stateid, name)
	VALUES (202, 'Puglia');
INSERT INTO states (stateid, name)
	VALUES (62, 'Quebec');
INSERT INTO states (stateid, name)
	VALUES (54, 'Queensland');
INSERT INTO states (stateid, name)
	VALUES (475, 'Quer&#233;taro');
INSERT INTO states (stateid, name)
	VALUES (476, 'Quintana Roo');
INSERT INTO states (stateid, name)
	VALUES (124, 'Regi&#243;n de Murcia');
INSERT INTO states (stateid, name)
	VALUES (231, 'Region Zuerich (ZH)');
INSERT INTO states (stateid, name)
	VALUES (144, 'Rheinland-Pfalz');
INSERT INTO states (stateid, name)
	VALUES (40, 'Rhode Island');
INSERT INTO states (stateid, name)
	VALUES (432, 'Rh&#244;ne-Alpes');
INSERT INTO states (stateid, name)
	VALUES (180, 'Rio de Janeiro');
INSERT INTO states (stateid, name)
	VALUES (181, 'Rio Grande do Norte');
INSERT INTO states (stateid, name)
	VALUES (182, 'Rio Grande do Sul');
INSERT INTO states (stateid, name)
	VALUES (249, 'Rogaland');
INSERT INTO states (stateid, name)
	VALUES (183, 'Rond&#244;nia');
INSERT INTO states (stateid, name)
	VALUES (184, 'Roraima');
INSERT INTO states (stateid, name)
	VALUES (145, 'Saarland');
INSERT INTO states (stateid, name)
	VALUES (146, 'Sachsen');
INSERT INTO states (stateid, name)
	VALUES (147, 'Sachsen-Anhalt');
INSERT INTO states (stateid, name)
	VALUES (344, 'Saga');
INSERT INTO states (stateid, name)
	VALUES (345, 'Saitama');
INSERT INTO states (stateid, name)
	VALUES (262, 'Salzburg');
INSERT INTO states (stateid, name)
	VALUES (477, 'San Luis Potos&#237;');
INSERT INTO states (stateid, name)
	VALUES (185, 'Santa Catarina');
INSERT INTO states (stateid, name)
	VALUES (108, 'Santar&#233;m');
INSERT INTO states (stateid, name)
	VALUES (186, 'S&#227;o Paulo');
INSERT INTO states (stateid, name)
	VALUES (203, 'Sardegna');
INSERT INTO states (stateid, name)
	VALUES (71, 'Saskatchewan');
INSERT INTO states (stateid, name)
	VALUES (148, 'Schleswig-Holstein');
INSERT INTO states (stateid, name)
	VALUES (296, 'Seoul');
INSERT INTO states (stateid, name)
	VALUES (187, 'Sergipe');
INSERT INTO states (stateid, name)
	VALUES (109, 'Set&#250;bal');
INSERT INTO states (stateid, name)
	VALUES (346, 'Shiga');
INSERT INTO states (stateid, name)
	VALUES (347, 'Shimane');
INSERT INTO states (stateid, name)
	VALUES (348, 'Shizuoka');
INSERT INTO states (stateid, name)
	VALUES (204, 'Sicilia');
INSERT INTO states (stateid, name)
	VALUES (478, 'Sinaloa');
INSERT INTO states (stateid, name)
	VALUES (369, 'Sk&#229;ne');
INSERT INTO states (stateid, name)
	VALUES (407, 'Śląskie');
INSERT INTO states (stateid, name)
	VALUES (371, 'S&#246;dermanland');
INSERT INTO states (stateid, name)
	VALUES (251, 'Sogn og Fjordane');
INSERT INTO states (stateid, name)
	VALUES (448, 'Somogy');
INSERT INTO states (stateid, name)
	VALUES (479, 'Sonora');
INSERT INTO states (stateid, name)
	VALUES (253, 'S&#248;r-Tr&#248;ndelag');
INSERT INTO states (stateid, name)
	VALUES (55, 'South Australia');
INSERT INTO states (stateid, name)
	VALUES (41, 'South Carolina');
INSERT INTO states (stateid, name)
	VALUES (42, 'South Dakota');
INSERT INTO states (stateid, name)
	VALUES (223, 'South East England');
INSERT INTO states (stateid, name)
	VALUES (86, 'South Island');
INSERT INTO states (stateid, name)
	VALUES (218, 'South Wales');
INSERT INTO states (stateid, name)
	VALUES (222, 'South West England');
INSERT INTO states (stateid, name)
	VALUES (221, 'Southern England');
INSERT INTO states (stateid, name)
	VALUES (211, 'Southern Scotland');
INSERT INTO states (stateid, name)
	VALUES (263, 'Steiermark');
INSERT INTO states (stateid, name)
	VALUES (370, 'Stockholm');
INSERT INTO states (stateid, name)
	VALUES (282, 'Stredocesky kraj');
INSERT INTO states (stateid, name)
	VALUES (235, 'Suisse romande (GE/VD/FR)');
INSERT INTO states (stateid, name)
	VALUES (408, 'Świętokrzyskie');
INSERT INTO states (stateid, name)
	VALUES (449, 'Szabolcs-Szatm&#225;r-Bereg');
INSERT INTO states (stateid, name)
	VALUES (480, 'Tabasco');
INSERT INTO states (stateid, name)
	VALUES (481, 'Tamaulipas');
INSERT INTO states (stateid, name)
	VALUES (57, 'Tasmania');
INSERT INTO states (stateid, name)
	VALUES (245, 'Telemark');
INSERT INTO states (stateid, name)
	VALUES (43, 'Tennessee');
INSERT INTO states (stateid, name)
	VALUES (238, 'Tessin (TI)');
INSERT INTO states (stateid, name)
	VALUES (44, 'Texas');
INSERT INTO states (stateid, name)
	VALUES (149, 'Th&#252;ringen');
INSERT INTO states (stateid, name)
	VALUES (264, 'Tirol');
INSERT INTO states (stateid, name)
	VALUES (482, 'Tlaxcala');
INSERT INTO states (stateid, name)
	VALUES (188, 'Tocantins');
INSERT INTO states (stateid, name)
	VALUES (349, 'Tochigi');
INSERT INTO states (stateid, name)
	VALUES (350, 'Tokushima');
INSERT INTO states (stateid, name)
	VALUES (351, 'Tokyo');
INSERT INTO states (stateid, name)
	VALUES (450, 'Tolna');
INSERT INTO states (stateid, name)
	VALUES (205, 'Toscana');
INSERT INTO states (stateid, name)
	VALUES (352, 'Tottori');
INSERT INTO states (stateid, name)
	VALUES (353, 'Toyama');
INSERT INTO states (stateid, name)
	VALUES (292, 'Trenčiansky kraj');
INSERT INTO states (stateid, name)
	VALUES (206, 'Trentino–Alto Adige ');
INSERT INTO states (stateid, name)
	VALUES (293, 'Trnavsk&#253; kraj');
INSERT INTO states (stateid, name)
	VALUES (256, 'Troms');
INSERT INTO states (stateid, name)
	VALUES (302, 'Ulsan');
INSERT INTO states (stateid, name)
	VALUES (224, 'Ulster');
INSERT INTO states (stateid, name)
	VALUES (207, 'Umbria');
INSERT INTO states (stateid, name)
	VALUES (372, 'Uppsala');
INSERT INTO states (stateid, name)
	VALUES (283, 'Ustecky kraj');
INSERT INTO states (stateid, name)
	VALUES (45, 'Utah');
INSERT INTO states (stateid, name)
	VALUES (388, 'Utrecht');
INSERT INTO states (stateid, name)
	VALUES (208, 'Valle d&#39;Aosta');
INSERT INTO states (stateid, name)
	VALUES (373, 'V&#228;rmland');
INSERT INTO states (stateid, name)
	VALUES (451, 'Vas');
INSERT INTO states (stateid, name)
	VALUES (374, 'V&#228;sterbotten');
INSERT INTO states (stateid, name)
	VALUES (375, 'V&#228;sternorrland');
INSERT INTO states (stateid, name)
	VALUES (376, 'V&#228;stmanland');
INSERT INTO states (stateid, name)
	VALUES (377, 'V&#228;stra G&#246;taland');
INSERT INTO states (stateid, name)
	VALUES (209, 'Veneto');
INSERT INTO states (stateid, name)
	VALUES (483, 'Veracruz');
INSERT INTO states (stateid, name)
	VALUES (46, 'Vermont');
INSERT INTO states (stateid, name)
	VALUES (248, 'Vest-Agder');
INSERT INTO states (stateid, name)
	VALUES (246, 'Vestfold');
INSERT INTO states (stateid, name)
	VALUES (452, 'Veszpr&#233;m');
INSERT INTO states (stateid, name)
	VALUES (110, 'Viana do Castelo');
INSERT INTO states (stateid, name)
	VALUES (53, 'Victoria');
INSERT INTO states (stateid, name)
	VALUES (112, 'Vila Real');
INSERT INTO states (stateid, name)
	VALUES (47, 'Virginia');
INSERT INTO states (stateid, name)
	VALUES (111, 'Viseu');
INSERT INTO states (stateid, name)
	VALUES (78, 'Vlaams-Brabant');
INSERT INTO states (stateid, name)
	VALUES (265, 'Vorarlberg');
INSERT INTO states (stateid, name)
	VALUES (354, 'Wakayama');
INSERT INTO states (stateid, name)
	VALUES (237, 'Wallis (VS)');
INSERT INTO states (stateid, name)
	VALUES (409, 'Warmińsko-Mazurskie');
INSERT INTO states (stateid, name)
	VALUES (48, 'Washington');
INSERT INTO states (stateid, name)
	VALUES (216, 'West Midlands');
INSERT INTO states (stateid, name)
	VALUES (49, 'West Virginia');
INSERT INTO states (stateid, name)
	VALUES (56, 'Western Australia');
INSERT INTO states (stateid, name)
	VALUES (152, 'Western Cape');
INSERT INTO states (stateid, name)
	VALUES (92, 'West-Vlaanderen');
INSERT INTO states (stateid, name)
	VALUES (410, 'Wielkopolskie');
INSERT INTO states (stateid, name)
	VALUES (295, 'Wien');
INSERT INTO states (stateid, name)
	VALUES (50, 'Wisconsin');
INSERT INTO states (stateid, name)
	VALUES (51, 'Wyoming');
INSERT INTO states (stateid, name)
	VALUES (355, 'Yamagata');
INSERT INTO states (stateid, name)
	VALUES (356, 'Yamaguchi');
INSERT INTO states (stateid, name)
	VALUES (357, 'Yamanashi');
INSERT INTO states (stateid, name)
	VALUES (214, 'Yorkshire');
INSERT INTO states (stateid, name)
	VALUES (484, 'Yucat&#225;n');
INSERT INTO states (stateid, name)
	VALUES (74, 'Yukon Territory');
INSERT INTO states (stateid, name)
	VALUES (485, 'Zacatecas');
INSERT INTO states (stateid, name)
	VALUES (411, 'Zachodniopomorskie');
INSERT INTO states (stateid, name)
	VALUES (453, 'Zala');
INSERT INTO states (stateid, name)
	VALUES (391, 'Zeeland');
INSERT INTO states (stateid, name)
	VALUES (233, 'Zentralschweiz (ZG/SZ/LU/UR/OW/NW)');
INSERT INTO states (stateid, name)
	VALUES (294, 'Žilinsk&#253; kraj');
INSERT INTO states (stateid, name)
	VALUES (285, 'Zlinsky kraj');
INSERT INTO states (stateid, name)
	VALUES (390, 'Zuid-Holland');
/* Point takes longitude, then latitude. Out of bounds CenterPoints throw an error */
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Home Old', -77.23315, 43.06525);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Home', -77.306933, 42.885983);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Mom&Dad', -73.809733, 42.853833);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Geneva', -76.993056, 42.878889);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('DML', -79.1105, 42.5074);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Watkins Glen', -76.8853, 42.3386);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Syracuse', -76.144167, 43.046944);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Auburn', -76.56477, 42.93166);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Niagara Falls', -79.017222, 43.094167);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Silver Creek', -79.167222, 42.544167);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Mendon Ponds', -77.564267, 43.0293);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Saratoga', -73.7825, 43.075278);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Sea Isle', -74.691917, 39.147633);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('zSpun Around Center', -77.48055, 43.09305);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Dansville', -77.697433, 42.560417);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Lockport', -78.689767, 43.17485);
INSERT INTO CenterPoints (locationname, longitude, latitude)
	VALUES ('Seattle', -122.33365, 47.612033);

INSERT INTO log_types (logtypedesc)
	VALUES ('Archive');
INSERT INTO log_types (logtypedesc)
	VALUES ('Didn''t find it');
INSERT INTO log_types (logtypedesc)
	VALUES ('Enable Listing');
INSERT INTO log_types (logtypedesc)
	VALUES ('Found it');
INSERT INTO log_types (logtypedesc)
	VALUES ('Needs Archived');
INSERT INTO log_types (logtypedesc)
	VALUES ('Needs Maintenance');
INSERT INTO log_types (logtypedesc)
	VALUES ('Owner Maintenance');
INSERT INTO log_types (logtypedesc)
	VALUES ('Post Reviewer Note');
INSERT INTO log_types (logtypedesc)
	VALUES ('Publish Listing');
INSERT INTO log_types (logtypedesc)
	VALUES ('Retract Listing');
INSERT INTO log_types (logtypedesc)
	VALUES ('Temporarily Disable Listing');
INSERT INTO log_types (logtypedesc)
	VALUES ('Unarchive');
INSERT INTO log_types (logtypedesc)
	VALUES ('Update Coordinates');
INSERT INTO log_types (logtypedesc)
	VALUES ('Webcam Photo Taken');
INSERT INTO log_types (logtypedesc)
	VALUES ('Write note');

INSERT INTO statuses (statusname)
	VALUES ('Available');
INSERT INTO statuses (statusname)
	VALUES ('Disabled');
INSERT INTO statuses (statusname)
	VALUES ('Archived');