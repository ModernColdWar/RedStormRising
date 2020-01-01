-- CSAR Script for DCS Ciribob - 2015
-- Version 1.9.2 - 23/04/2018
-- DCS 1.5 Compatible - Needs Mist 4.0.55 or higher!
--
-- 4 Options:
--      0 - No Limit - NO Aircraft disabling or pilot lives
--      1 - Disable Aircraft when its down - Timeout to reenable aircraft
--      2 - Disable Aircraft for Pilot when he's shot down -- timeout to reenable pilot for aircraft
--      3 - Pilot Life Limit - No Aircraft Disabling 

csar = {}

-- SETTINGS FOR MISSION DESIGNER vvvvvvvvvvvvvvvvvv
csar.csarUnits = {
    "Batumi Blue Helos #001",
    "Batumi Blue Helos #002",
    "Batumi Blue Helos #003",
    "Batumi Blue Helos #004",
    "Batumi Blue Helos #005",
    "Batumi Blue Helos #006",
    "Batumi Blue Helos #007",
    "Batumi Blue Helos #008",
    "Batumi Blue Helos #009",
    "Batumi Blue Helos #010",
	"Batumi Blue Helos #011",
	"Batumi Blue Helos #012",
	"Batumi Blue Helos #013",
	"Batumi Blue Helos #014",
	"Batumi Blue Helos #015",
	"Batumi Blue Helos #016",

	"Batumi Red Helos #001",
    "Batumi Red Helos #002",
    "Batumi Red Helos #003",
    "Batumi Red Helos #004",
    "Batumi Red Helos #005",
    "Batumi Red Helos #006",
    "Batumi Red Helos #007",
    "Batumi Red Helos #008",
    "Batumi Red Helos #009",
    "Batumi Red Helos #010",
	"Batumi Red Helos #011",
	"Batumi Red Helos #012",
	"Batumi Red Helos #013",
	"Batumi Red Helos #014",
	"Batumi Red Helos #015",
	"Batumi Red Helos #016",
	
	"Kobuleti Blue Helos #001",
	"Kobuleti Blue Helos #002",
	"Kobuleti Blue Helos #003",
	"Kobuleti Blue Helos #004",
	"Kobuleti Blue Helos #005",
	"Kobuleti Blue Helos #006",
	"Kobuleti Blue Helos #007",
	"Kobuleti Blue Helos #008",
	"Kobuleti Blue Helos #009",
	"Kobuleti Blue Helos #010",
	"Kobuleti Blue Helos #011",
	"Kobuleti Blue Helos #012",
	"Kobuleti Blue Helos #013",
	"Kobuleti Blue Helos #014",
	"Kobuleti Blue Helos #015",
	"Kobuleti Blue Helos #016",

	"Kobuleti Red Helos #001",
	"Kobuleti Red Helos #002",
	"Kobuleti Red Helos #003",
	"Kobuleti Red Helos #004",
	"Kobuleti Red Helos #005",
	"Kobuleti Red Helos #006",
	"Kobuleti Red Helos #007",
	"Kobuleti Red Helos #008",
	"Kobuleti Red Helos #009",
	"Kobuleti Red Helos #010",
	"Kobuleti Red Helos #011",
	"Kobuleti Red Helos #012",
	"Kobuleti Red Helos #013",
	"Kobuleti Red Helos #014",
	"Kobuleti Red Helos #015",
	"Kobuleti Red Helos #016",

	"Senaki Blue Helos #001",
	"Senaki Blue Helos #002",
	"Senaki Blue Helos #003",
	"Senaki Blue Helos #004",
	"Senaki Blue Helos #005",
	"Senaki Blue Helos #006",
	"Senaki Blue Helos #007",
	"Senaki Blue Helos #008",
	"Senaki Blue Helos #009",
	"Senaki Blue Helos #010",
	"Senaki Blue Helos #011",
	"Senaki Blue Helos #012",
	"Senaki Blue Helos #013",
	"Senaki Blue Helos #014",
	"Senaki Blue Helos #015",
	"Senaki Blue Helos #016",

	"Senaki Red Helos #001",
	"Senaki Red Helos #002",
	"Senaki Red Helos #003",
	"Senaki Red Helos #004",
	"Senaki Red Helos #005",
	"Senaki Red Helos #006",
	"Senaki Red Helos #007",
	"Senaki Red Helos #008",
	"Senaki Red Helos #009",
	"Senaki Red Helos #010",
	"Senaki Red Helos #011",
	"Senaki Red Helos #012",
	"Senaki Red Helos #013",
	"Senaki Red Helos #014",
	"Senaki Red Helos #015",
	"Senaki Red Helos #016",
	
	"Kutaisi Blue Helos #001",
	"Kutaisi Blue Helos #002",
	"Kutaisi Blue Helos #003",
	"Kutaisi Blue Helos #004",
	"Kutaisi Blue Helos #005",
	"Kutaisi Blue Helos #006",
	"Kutaisi Blue Helos #007",
	"Kutaisi Blue Helos #008",
	"Kutaisi Blue Helos #009",
	"Kutaisi Blue Helos #010",
	"Kutaisi Blue Helos #011",
	"Kutaisi Blue Helos #012",
	"Kutaisi Blue Helos #013",
	"Kutaisi Blue Helos #014",
	"Kutaisi Blue Helos #015",
	"Kutaisi Blue Helos #016",

	"Kutaisi Red Helos #001",
	"Kutaisi Red Helos #002",
	"Kutaisi Red Helos #003",
	"Kutaisi Red Helos #004",
	"Kutaisi Red Helos #005",
	"Kutaisi Red Helos #006",
	"Kutaisi Red Helos #007",
	"Kutaisi Red Helos #008",
	"Kutaisi Red Helos #009",
	"Kutaisi Red Helos #010",
	"Kutaisi Red Helos #011",
	"Kutaisi Red Helos #012",
	"Kutaisi Red Helos #013",
	"Kutaisi Red Helos #014",
	"Kutaisi Red Helos #015",
	"Kutaisi Red Helos #016",

	"Sukumi Blue Helos #001",
	"Sukumi Blue Helos #002",
	"Sukumi Blue Helos #003",
	"Sukumi Blue Helos #004",
	"Sukumi Blue Helos #005",
	"Sukumi Blue Helos #006",
	"Sukumi Blue Helos #007",
	"Sukumi Blue Helos #008",
	"Sukumi Blue Helos #009",
	"Sukumi Blue Helos #010",
	"Sukumi Blue Helos #011",
	"Sukumi Blue Helos #012",
	"Sukumi Blue Helos #013",
	"Sukumi Blue Helos #014",
	"Sukumi Blue Helos #015",
	"Sukumi Blue Helos #016",

	"Sukumi Red Helos #001",
	"Sukumi Red Helos #002",
	"Sukumi Red Helos #003",
	"Sukumi Red Helos #004",
	"Sukumi Red Helos #005",
	"Sukumi Red Helos #006",
	"Sukumi Red Helos #007",
	"Sukumi Red Helos #008",
	"Sukumi Red Helos #009",
	"Sukumi Red Helos #010",
	"Sukumi Red Helos #011",
	"Sukumi Red Helos #012",
	"Sukumi Red Helos #013",
	"Sukumi Red Helos #014",
	"Sukumi Red Helos #015",
	"Sukumi Red Helos #016",

	"Gudauta Blue Helos #001",
	"Gudauta Blue Helos #002",
	"Gudauta Blue Helos #003",
	"Gudauta Blue Helos #004",
	"Gudauta Blue Helos #005",
	"Gudauta Blue Helos #006",
	"Gudauta Blue Helos #007",
	"Gudauta Blue Helos #008",
	"Gudauta Blue Helos #009",
	"Gudauta Blue Helos #010",
	"Gudauta Blue Helos #011",
	"Gudauta Blue Helos #012",
	"Gudauta Blue Helos #013",
	"Gudauta Blue Helos #014",
	"Gudauta Blue Helos #015",
	"Gudauta Blue Helos #016",
	
	"Gudauta Red Helos #001",
	"Gudauta Red Helos #002",
	"Gudauta Red Helos #003",
	"Gudauta Red Helos #004",
	"Gudauta Red Helos #005",
	"Gudauta Red Helos #006",
	"Gudauta Red Helos #007",
	"Gudauta Red Helos #008",
	"Gudauta Red Helos #009",
	"Gudauta Red Helos #010",
	"Gudauta Red Helos #011",
	"Gudauta Red Helos #012",
	"Gudauta Red Helos #013",
	"Gudauta Red Helos #014",
	"Gudauta Red Helos #015",
	"Gudauta Red Helos #016",

	"Sochi Blue Helos #001",
	"Sochi Blue Helos #002",
	"Sochi Blue Helos #003",
	"Sochi Blue Helos #004",
	"Sochi Blue Helos #005",
	"Sochi Blue Helos #006",
	"Sochi Blue Helos #007",
	"Sochi Blue Helos #008",
	"Sochi Blue Helos #009",
	"Sochi Blue Helos #010",
	"Sochi Blue Helos #011",
	"Sochi Blue Helos #012",
	"Sochi Blue Helos #013",
	"Sochi Blue Helos #014",
	"Sochi Blue Helos #015",
	"Sochi Blue Helos #016",
	
	"Sochi Red Helos #001",
	"Sochi Red Helos #002",
	"Sochi Red Helos #003",
	"Sochi Red Helos #004",
	"Sochi Red Helos #005",
	"Sochi Red Helos #006",
	"Sochi Red Helos #007",
	"Sochi Red Helos #008",
	"Sochi Red Helos #009",
	"Sochi Red Helos #010",
	"Sochi Red Helos #011",
	"Sochi Red Helos #012",
	"Sochi Red Helos #013",
	"Sochi Red Helos #014",
	"Sochi Red Helos #015",
	"Sochi Red Helos #016",

	"Vaziani Blue Helos #001",
	"Vaziani Blue Helos #002",
	"Vaziani Blue Helos #003",
	"Vaziani Blue Helos #004",
	"Vaziani Blue Helos #005",
	"Vaziani Blue Helos #006",
	"Vaziani Blue Helos #007",
	"Vaziani Blue Helos #008",
	"Vaziani Blue Helos #009",
	"Vaziani Blue Helos #010",
	"Vaziani Blue Helos #011",
	"Vaziani Blue Helos #012",
	"Vaziani Blue Helos #013",
	"Vaziani Blue Helos #014",
	"Vaziani Blue Helos #015",
	"Vaziani Blue Helos #016",
	
	"Vaziani Red Helos #001",
	"Vaziani Red Helos #002",
	"Vaziani Red Helos #003",
	"Vaziani Red Helos #004",
	"Vaziani Red Helos #005",
	"Vaziani Red Helos #006",
	"Vaziani Red Helos #007",
	"Vaziani Red Helos #008",
	"Vaziani Red Helos #009",
	"Vaziani Red Helos #010",
	"Vaziani Red Helos #011",
	"Vaziani Red Helos #012",
	"Vaziani Red Helos #013",
	"Vaziani Red Helos #014",
	"Vaziani Red Helos #015",
	"Vaziani Red Helos #016",

	"Beslan Blue Helos #001",
	"Beslan Blue Helos #002",
	"Beslan Blue Helos #003",
	"Beslan Blue Helos #004",
	"Beslan Blue Helos #005",
	"Beslan Blue Helos #006",
	"Beslan Blue Helos #007",
	"Beslan Blue Helos #008",
	"Beslan Blue Helos #009",
	"Beslan Blue Helos #010",
	"Beslan Blue Helos #011",
	"Beslan Blue Helos #012",
	"Beslan Blue Helos #013",
	"Beslan Blue Helos #014",
	"Beslan Blue Helos #015",
	"Beslan Blue Helos #016",
	
	"Beslan Red Helos #001",
	"Beslan Red Helos #002",
	"Beslan Red Helos #003",
	"Beslan Red Helos #004",
	"Beslan Red Helos #005",
	"Beslan Red Helos #006",
	"Beslan Red Helos #007",
	"Beslan Red Helos #008",
	"Beslan Red Helos #009",
	"Beslan Red Helos #010",
	"Beslan Red Helos #011",
	"Beslan Red Helos #012",
	"Beslan Red Helos #013",
	"Beslan Red Helos #014",
	"Beslan Red Helos #015",
	"Beslan Red Helos #016",

	"Mozdok Blue Helos #001",
	"Mozdok Blue Helos #002",
	"Mozdok Blue Helos #003",
	"Mozdok Blue Helos #004",
	"Mozdok Blue Helos #005",
	"Mozdok Blue Helos #006",
	"Mozdok Blue Helos #007",
	"Mozdok Blue Helos #008",
	"Mozdok Blue Helos #009",
	"Mozdok Blue Helos #010",
	"Mozdok Blue Helos #011",
	"Mozdok Blue Helos #012",
	"Mozdok Blue Helos #013",
	"Mozdok Blue Helos #014",
	"Mozdok Blue Helos #015",
	"Mozdok Blue Helos #016",
	
	"Mozdok Red Helos #001",
	"Mozdok Red Helos #002",
	"Mozdok Red Helos #003",
	"Mozdok Red Helos #004",
	"Mozdok Red Helos #005",
	"Mozdok Red Helos #006",
	"Mozdok Red Helos #007",
	"Mozdok Red Helos #008",
	"Mozdok Red Helos #009",
	"Mozdok Red Helos #010",
	"Mozdok Red Helos #011",
	"Mozdok Red Helos #012",
	"Mozdok Red Helos #013",
	"Mozdok Red Helos #014",
	"Mozdok Red Helos #015",
	"Mozdok Red Helos #016",

	"Nalchik Blue Helos #001",
	"Nalchik Blue Helos #002",
	"Nalchik Blue Helos #003",
	"Nalchik Blue Helos #004",
	"Nalchik Blue Helos #005",
	"Nalchik Blue Helos #006",
	"Nalchik Blue Helos #007",
	"Nalchik Blue Helos #008",
	"Nalchik Blue Helos #009",
	"Nalchik Blue Helos #010",
	"Nalchik Blue Helos #011",
	"Nalchik Blue Helos #012",
	"Nalchik Blue Helos #013",
	"Nalchik Blue Helos #014",
	"Nalchik Blue Helos #015",
	"Nalchik Blue Helos #016",
	
	"Nalchik Red Helos #001",
	"Nalchik Red Helos #002",
	"Nalchik Red Helos #003",
	"Nalchik Red Helos #004",
	"Nalchik Red Helos #005",
	"Nalchik Red Helos #006",
	"Nalchik Red Helos #007",
	"Nalchik Red Helos #008",
	"Nalchik Red Helos #009",
	"Nalchik Red Helos #010",
	"Nalchik Red Helos #011",
	"Nalchik Red Helos #012",
	"Nalchik Red Helos #013",
	"Nalchik Red Helos #014",
	"Nalchik Red Helos #015",
	"Nalchik Red Helos #016",

	"Mineralnye Vody Blue Helos #001",
	"Mineralnye Vody Blue Helos #002",
	"Mineralnye Vody Blue Helos #003",
	"Mineralnye Vody Blue Helos #004",
	"Mineralnye Vody Blue Helos #005",
	"Mineralnye Vody Blue Helos #006",
	"Mineralnye Vody Blue Helos #007",
	"Mineralnye Vody Blue Helos #008",
	"Mineralnye Vody Blue Helos #009",
	"Mineralnye Vody Blue Helos #010",
	"Mineralnye Vody Blue Helos #011",
	"Mineralnye Vody Blue Helos #012",
	"Mineralnye Vody Blue Helos #013",
	"Mineralnye Vody Blue Helos #014",
	"Mineralnye Vody Blue Helos #015",
	"Mineralnye Vody Blue Helos #016",
	
	"Mineralnye Vody Red Helos #001",
	"Mineralnye Vody Red Helos #002",
	"Mineralnye Vody Red Helos #003",
	"Mineralnye Vody Red Helos #004",
	"Mineralnye Vody Red Helos #005",
	"Mineralnye Vody Red Helos #006",
	"Mineralnye Vody Red Helos #007",
	"Mineralnye Vody Red Helos #008",
	"Mineralnye Vody Red Helos #009",
	"Mineralnye Vody Red Helos #010",
	"Mineralnye Vody Red Helos #011",
	"Mineralnye Vody Red Helos #012",
	"Mineralnye Vody Red Helos #013",
	"Mineralnye Vody Red Helos #014",
	"Mineralnye Vody Red Helos #015",
	"Mineralnye Vody Red Helos #016",

	"Maykop Blue Helos #001",
	"Maykop Blue Helos #002",
	"Maykop Blue Helos #003",
	"Maykop Blue Helos #004",
	"Maykop Blue Helos #005",
	"Maykop Blue Helos #006",
	"Maykop Blue Helos #007",
	"Maykop Blue Helos #008",
	"Maykop Blue Helos #009",
	"Maykop Blue Helos #010",
	"Maykop Blue Helos #011",
	"Maykop Blue Helos #012",
	"Maykop Blue Helos #013",
	"Maykop Blue Helos #014",
	"Maykop Blue Helos #015",
	"Maykop Blue Helos #016",
	
	"Maykop Red Helos #001",
	"Maykop Red Helos #002",
	"Maykop Red Helos #003",
	"Maykop Red Helos #004",
	"Maykop Red Helos #005",
	"Maykop Red Helos #006",
	"Maykop Red Helos #007",
	"Maykop Red Helos #008",
	"Maykop Red Helos #009",
	"Maykop Red Helos #010",
	"Maykop Red Helos #011",
	"Maykop Red Helos #012",
	"Maykop Red Helos #013",
	"Maykop Red Helos #014",
	"Maykop Red Helos #015",
	"Maykop Red Helos #016",

	"Krasnodar-Center Blue Helos #001",
	"Krasnodar-Center Blue Helos #002",
	"Krasnodar-Center Blue Helos #003",
	"Krasnodar-Center Blue Helos #004",
	"Krasnodar-Center Blue Helos #005",
	"Krasnodar-Center Blue Helos #006",
	"Krasnodar-Center Blue Helos #007",
	"Krasnodar-Center Blue Helos #008",
	"Krasnodar-Center Blue Helos #009",
	"Krasnodar-Center Blue Helos #010",
	"Krasnodar-Center Blue Helos #011",
	"Krasnodar-Center Blue Helos #012",
	"Krasnodar-Center Blue Helos #013",
	"Krasnodar-Center Blue Helos #014",
	"Krasnodar-Center Blue Helos #015",
	"Krasnodar-Center Blue Helos #016",
	
	"Krasnodar-Center Red Helos #001",
	"Krasnodar-Center Red Helos #002",
	"Krasnodar-Center Red Helos #003",
	"Krasnodar-Center Red Helos #004",
	"Krasnodar-Center Red Helos #005",
	"Krasnodar-Center Red Helos #006",
	"Krasnodar-Center Red Helos #007",
	"Krasnodar-Center Red Helos #008",
	"Krasnodar-Center Red Helos #009",
	"Krasnodar-Center Red Helos #010",
	"Krasnodar-Center Red Helos #011",
	"Krasnodar-Center Red Helos #012",
	"Krasnodar-Center Red Helos #013",
	"Krasnodar-Center Red Helos #014",
	"Krasnodar-Center Red Helos #015",
	"Krasnodar-Center Red Helos #016",

	"Krymsk Blue Helos #001",
	"Krymsk Blue Helos #002",
	"Krymsk Blue Helos #003",
	"Krymsk Blue Helos #004",
	"Krymsk Blue Helos #005",
	"Krymsk Blue Helos #006",
	"Krymsk Blue Helos #007",
	"Krymsk Blue Helos #008",
	"Krymsk Blue Helos #009",
	"Krymsk Blue Helos #010",
	"Krymsk Blue Helos #011",
	"Krymsk Blue Helos #012",
	"Krymsk Blue Helos #013",
	"Krymsk Blue Helos #014",
	"Krymsk Blue Helos #015",
	"Krymsk Blue Helos #016",
	
	"Krymsk Red Helos #001",
	"Krymsk Red Helos #002",
	"Krymsk Red Helos #003",
	"Krymsk Red Helos #004",
	"Krymsk Red Helos #005",
	"Krymsk Red Helos #006",
	"Krymsk Red Helos #007",
	"Krymsk Red Helos #008",
	"Krymsk Red Helos #009",
	"Krymsk Red Helos #010",
	"Krymsk Red Helos #011",
	"Krymsk Red Helos #012",
	"Krymsk Red Helos #013",
	"Krymsk Red Helos #014",
	"Krymsk Red Helos #015",
	"Krymsk Red Helos #016",

	"Gelendzhik Blue Helos #001",
	"Gelendzhik Blue Helos #002",
	"Gelendzhik Blue Helos #003",
	"Gelendzhik Blue Helos #004",
	"Gelendzhik Blue Helos #005",
	"Gelendzhik Blue Helos #006",
	"Gelendzhik Blue Helos #007",
	"Gelendzhik Blue Helos #008",
	"Gelendzhik Blue Helos #009",
	"Gelendzhik Blue Helos #010",
	"Gelendzhik Blue Helos #011",
	"Gelendzhik Blue Helos #012",
	"Gelendzhik Blue Helos #013",
	"Gelendzhik Blue Helos #014",
	"Gelendzhik Blue Helos #015",
	"Gelendzhik Blue Helos #016",
	
	"Gelendzhik Red Helos #001",
	"Gelendzhik Red Helos #002",
	"Gelendzhik Red Helos #003",
	"Gelendzhik Red Helos #004",
	"Gelendzhik Red Helos #005",
	"Gelendzhik Red Helos #006",
	"Gelendzhik Red Helos #007",
	"Gelendzhik Red Helos #008",
	"Gelendzhik Red Helos #009",
	"Gelendzhik Red Helos #010",
	"Gelendzhik Red Helos #011",
	"Gelendzhik Red Helos #012",
	"Gelendzhik Red Helos #013",
	"Gelendzhik Red Helos #014",
	"Gelendzhik Red Helos #015",
	"Gelendzhik Red Helos #016",

	"Anapa Blue Helos #001",
	"Anapa Blue Helos #002",
	"Anapa Blue Helos #003",
	"Anapa Blue Helos #004",
	"Anapa Blue Helos #005",
	"Anapa Blue Helos #006",
	"Anapa Blue Helos #007",
	"Anapa Blue Helos #008",
	"Anapa Blue Helos #009",
	"Anapa Blue Helos #010",
	"Anapa Blue Helos #011",
	"Anapa Blue Helos #012",
	"Anapa Blue Helos #013",
	"Anapa Blue Helos #014",
	"Anapa Blue Helos #015",
	"Anapa Blue Helos #016",
	
	"Anapa Red Helos #001",
	"Anapa Red Helos #002",
	"Anapa Red Helos #003",
	"Anapa Red Helos #004",
	"Anapa Red Helos #005",
	"Anapa Red Helos #006",
	"Anapa Red Helos #007",
	"Anapa Red Helos #008",
	"Anapa Red Helos #009",
	"Anapa Red Helos #010",
	"Anapa Red Helos #011",
	"Anapa Red Helos #012",
	"Anapa Red Helos #013",
	"Anapa Red Helos #014",
	"Anapa Red Helos #015",
	"Anapa Red Helos #016",

	"RedBeachhead Red Helos #001",
	"RedBeachhead Red Helos #002",
	"RedBeachhead Red Helos #003",
	"RedBeachhead Red Helos #004",
	"RedBeachhead Red Helos #005",
	"RedBeachhead Red Helos #006",
	"RedBeachhead Red Helos #007",
	"RedBeachhead Red Helos #008",
	"RedBeachhead Red Helos #009",
	"RedBeachhead Red Helos #010",
	"RedBeachhead Red Helos #011",
	"RedBeachhead Red Helos #012",

	"GG19 Blue Helos #001",
	"GG19 Blue Helos #002",
	"GG19 Blue Helos #003",
	"GG19 Blue Helos #004",
	"GG19 Blue Helos #005",
	"GG19 Blue Helos #006",
	"GG19 Blue Helos #007",
	"GG19 Blue Helos #008",
	"GG19 Blue Helos #009",
	"GG19 Blue Helos #010",
	"GG19 Blue Helos #011",
	"GG19 Blue Helos #012",
	"GG19 Blue Helos #013",
	"GG19 Blue Helos #014",
	"GG19 Blue Helos #015",
	"GG19 Blue Helos #016",
	
	"GG19 Red Helos #001",
	"GG19 Red Helos #002",
	"GG19 Red Helos #003",
	"GG19 Red Helos #004",
	"GG19 Red Helos #005",
	"GG19 Red Helos #006",
	"GG19 Red Helos #007",
	"GG19 Red Helos #008",
	"GG19 Red Helos #009",
	"GG19 Red Helos #010",
	"GG19 Red Helos #011",
	"GG19 Red Helos #012",
	"GG19 Red Helos #013",
	"GG19 Red Helos #014",
	"GG19 Red Helos #015",
	"GG19 Red Helos #016",

	"KN70 Blue Helos #001",
	"KN70 Blue Helos #002",
	"KN70 Blue Helos #003",
	"KN70 Blue Helos #004",
	"KN70 Blue Helos #005",
	"KN70 Blue Helos #006",
	"KN70 Blue Helos #007",
	"KN70 Blue Helos #008",
	"KN70 Blue Helos #009",
	"KN70 Blue Helos #010",
	"KN70 Blue Helos #011",
	"KN70 Blue Helos #012",
	"KN70 Blue Helos #013",
	"KN70 Blue Helos #014",
	"KN70 Blue Helos #015",
	"KN70 Blue Helos #016",
	
	"KN70 Red Helos #001",
	"KN70 Red Helos #002",
	"KN70 Red Helos #003",
	"KN70 Red Helos #004",
	"KN70 Red Helos #005",
	"KN70 Red Helos #006",
	"KN70 Red Helos #007",
	"KN70 Red Helos #008",
	"KN70 Red Helos #009",
	"KN70 Red Helos #010",
	"KN70 Red Helos #011",
	"KN70 Red Helos #012",
	"KN70 Red Helos #013",
	"KN70 Red Helos #014",
	"KN70 Red Helos #015",
	"KN70 Red Helos #016",

	"KN53 Blue Helos #001",
	"KN53 Blue Helos #002",
	"KN53 Blue Helos #003",
	"KN53 Blue Helos #004",
	"KN53 Blue Helos #005",
	"KN53 Blue Helos #006",
	"KN53 Blue Helos #007",
	"KN53 Blue Helos #008",
	"KN53 Blue Helos #009",
	"KN53 Blue Helos #010",
	"KN53 Blue Helos #011",
	"KN53 Blue Helos #012",
	"KN53 Blue Helos #013",
	"KN53 Blue Helos #014",
	"KN53 Blue Helos #015",
	"KN53 Blue Helos #016",
	
	"KN53 Red Helos #001",
	"KN53 Red Helos #002",
	"KN53 Red Helos #003",
	"KN53 Red Helos #004",
	"KN53 Red Helos #005",
	"KN53 Red Helos #006",
	"KN53 Red Helos #007",
	"KN53 Red Helos #008",
	"KN53 Red Helos #009",
	"KN53 Red Helos #010",
	"KN53 Red Helos #011",
	"KN53 Red Helos #012",
	"KN53 Red Helos #013",
	"KN53 Red Helos #014",
	"KN53 Red Helos #015",
	"KN53 Red Helos #016",

	"GH03 Blue Helos #001",
	"GH03 Blue Helos #002",
	"GH03 Blue Helos #003",
	"GH03 Blue Helos #004",
	"GH03 Blue Helos #005",
	"GH03 Blue Helos #006",
	"GH03 Blue Helos #007",
	"GH03 Blue Helos #008",
	"GH03 Blue Helos #009",
	"GH03 Blue Helos #010",
	"GH03 Blue Helos #011",
	"GH03 Blue Helos #012",
	"GH03 Blue Helos #013",
	"GH03 Blue Helos #014",
	"GH03 Blue Helos #015",
	"GH03 Blue Helos #016",
	
	"GH03 Red Helos #001",
	"GH03 Red Helos #002",
	"GH03 Red Helos #003",
	"GH03 Red Helos #004",
	"GH03 Red Helos #005",
	"GH03 Red Helos #006",
	"GH03 Red Helos #007",
	"GH03 Red Helos #008",
	"GH03 Red Helos #009",
	"GH03 Red Helos #010",
	"GH03 Red Helos #011",
	"GH03 Red Helos #012",
	"GH03 Red Helos #013",
	"GH03 Red Helos #014",
	"GH03 Red Helos #015",
	"GH03 Red Helos #016",

	"KN76 Blue Helos #001",
	"KN76 Blue Helos #002",
	"KN76 Blue Helos #003",
	"KN76 Blue Helos #004",
	"KN76 Blue Helos #005",
	"KN76 Blue Helos #006",
	"KN76 Blue Helos #007",
	"KN76 Blue Helos #008",
	"KN76 Blue Helos #009",
	"KN76 Blue Helos #010",
	"KN76 Blue Helos #011",
	"KN76 Blue Helos #012",
	"KN76 Blue Helos #013",
	"KN76 Blue Helos #014",
	"KN76 Blue Helos #015",
	"KN76 Blue Helos #016",
	
	"KN76 Red Helos #001",
	"KN76 Red Helos #002",
	"KN76 Red Helos #003",
	"KN76 Red Helos #004",
	"KN76 Red Helos #005",
	"KN76 Red Helos #006",
	"KN76 Red Helos #007",
	"KN76 Red Helos #008",
	"KN76 Red Helos #009",
	"KN76 Red Helos #010",
	"KN76 Red Helos #011",
	"KN76 Red Helos #012",
	"KN76 Red Helos #013",
	"KN76 Red Helos #014",
	"KN76 Red Helos #015",
	"KN76 Red Helos #016",

	"GH17 Blue Helos #001",
	"GH17 Blue Helos #002",
	"GH17 Blue Helos #003",
	"GH17 Blue Helos #004",
	"GH17 Blue Helos #005",
	"GH17 Blue Helos #006",
	"GH17 Blue Helos #007",
	"GH17 Blue Helos #008",
	"GH17 Blue Helos #009",
	"GH17 Blue Helos #010",
	"GH17 Blue Helos #011",
	"GH17 Blue Helos #012",
	"GH17 Blue Helos #013",
	"GH17 Blue Helos #014",
	"GH17 Blue Helos #015",
	"GH17 Blue Helos #016",
	
	"GH17 Red Helos #001",
	"GH17 Red Helos #002",
	"GH17 Red Helos #003",
	"GH17 Red Helos #004",
	"GH17 Red Helos #005",
	"GH17 Red Helos #006",
	"GH17 Red Helos #007",
	"GH17 Red Helos #008",
	"GH17 Red Helos #009",
	"GH17 Red Helos #010",
	"GH17 Red Helos #011",
	"GH17 Red Helos #012",
	"GH17 Red Helos #013",
	"GH17 Red Helos #014",
	"GH17 Red Helos #015",
	"GH17 Red Helos #016",

	"EJ34 Blue Helos #001",
	"EJ34 Blue Helos #002",
	"EJ34 Blue Helos #003",
	"EJ34 Blue Helos #004",
	"EJ34 Blue Helos #005",
	"EJ34 Blue Helos #006",
	"EJ34 Blue Helos #007",
	"EJ34 Blue Helos #008",
	"EJ34 Blue Helos #009",
	"EJ34 Blue Helos #010",
	"EJ34 Blue Helos #011",
	"EJ34 Blue Helos #012",
	"EJ34 Blue Helos #013",
	"EJ34 Blue Helos #014",
	"EJ34 Blue Helos #015",
	"EJ34 Blue Helos #016",
	
	"EJ34 Red Helos #001",
	"EJ34 Red Helos #002",
	"EJ34 Red Helos #003",
	"EJ34 Red Helos #004",
	"EJ34 Red Helos #005",
	"EJ34 Red Helos #006",
	"EJ34 Red Helos #007",
	"EJ34 Red Helos #008",
	"EJ34 Red Helos #009",
	"EJ34 Red Helos #010",
	"EJ34 Red Helos #011",
	"EJ34 Red Helos #012",
	"EJ34 Red Helos #013",
	"EJ34 Red Helos #014",
	"EJ34 Red Helos #015",
	"EJ34 Red Helos #016",

	"EJ08 Blue Helos #001",
	"EJ08 Blue Helos #002",
	"EJ08 Blue Helos #003",
	"EJ08 Blue Helos #004",
	"EJ08 Blue Helos #005",
	"EJ08 Blue Helos #006",
	"EJ08 Blue Helos #007",
	"EJ08 Blue Helos #008",
	"EJ08 Blue Helos #009",
	"EJ08 Blue Helos #010",
	"EJ08 Blue Helos #011",
	"EJ08 Blue Helos #012",
	"EJ08 Blue Helos #013",
	"EJ08 Blue Helos #014",
	"EJ08 Blue Helos #015",
	"EJ08 Blue Helos #016",
	
	"EJ08 Red Helos #001",
	"EJ08 Red Helos #002",
	"EJ08 Red Helos #003",
	"EJ08 Red Helos #004",
	"EJ08 Red Helos #005",
	"EJ08 Red Helos #006",
	"EJ08 Red Helos #007",
	"EJ08 Red Helos #008",
	"EJ08 Red Helos #009",
	"EJ08 Red Helos #010",
	"EJ08 Red Helos #011",
	"EJ08 Red Helos #012",
	"EJ08 Red Helos #013",
	"EJ08 Red Helos #014",
	"EJ08 Red Helos #015",
	"EJ08 Red Helos #016",

	"DK61 Blue Helos #001",
	"DK61 Blue Helos #002",
	"DK61 Blue Helos #003",
	"DK61 Blue Helos #004",
	"DK61 Blue Helos #005",
	"DK61 Blue Helos #006",
	"DK61 Blue Helos #007",
	"DK61 Blue Helos #008",
	"DK61 Blue Helos #009",
	"DK61 Blue Helos #010",
	"DK61 Blue Helos #011",
	"DK61 Blue Helos #012",
	"DK61 Blue Helos #013",
	"DK61 Blue Helos #014",
	"DK61 Blue Helos #015",
	"DK61 Blue Helos #016",
	
	"DK61 Red Helos #001",
	"DK61 Red Helos #002",
	"DK61 Red Helos #003",
	"DK61 Red Helos #004",
	"DK61 Red Helos #005",
	"DK61 Red Helos #006",
	"DK61 Red Helos #007",
	"DK61 Red Helos #008",
	"DK61 Red Helos #009",
	"DK61 Red Helos #010",
	"DK61 Red Helos #011",
	"DK61 Red Helos #012",
	"DK61 Red Helos #013",
	"DK61 Red Helos #014",
	"DK61 Red Helos #015",
	"DK61 Red Helos #016",

	"Novorossiysk Blue Helos #001",
	"Novorossiysk Blue Helos #002",
	"Novorossiysk Blue Helos #003",
	"Novorossiysk Blue Helos #004",
	"Novorossiysk Blue Helos #005",
	"Novorossiysk Blue Helos #006",
	"Novorossiysk Blue Helos #007",
	"Novorossiysk Blue Helos #008",
	"Novorossiysk Blue Helos #009",
	"Novorossiysk Blue Helos #010",
	"Novorossiysk Blue Helos #011",
	"Novorossiysk Blue Helos #012",
	"Novorossiysk Blue Helos #013",
	"Novorossiysk Blue Helos #014",
	"Novorossiysk Blue Helos #015",
	"Novorossiysk Blue Helos #016",
	
	"Novorossiysk Red Helos #001",
	"Novorossiysk Red Helos #002",
	"Novorossiysk Red Helos #003",
	"Novorossiysk Red Helos #004",
	"Novorossiysk Red Helos #005",
	"Novorossiysk Red Helos #006",
	"Novorossiysk Red Helos #007",
	"Novorossiysk Red Helos #008",
	"Novorossiysk Red Helos #009",
	"Novorossiysk Red Helos #010",
	"Novorossiysk Red Helos #011",
	"Novorossiysk Red Helos #012",
	"Novorossiysk Red Helos #013",
	"Novorossiysk Red Helos #014",
	"Novorossiysk Red Helos #015",
	"Novorossiysk Red Helos #016",

	"DK65 Blue Helos #001",
	"DK65 Blue Helos #002",
	"DK65 Blue Helos #003",
	"DK65 Blue Helos #004",
	"DK65 Blue Helos #005",
	"DK65 Blue Helos #006",
	"DK65 Blue Helos #007",
	"DK65 Blue Helos #008",
	"DK65 Blue Helos #009",
	"DK65 Blue Helos #010",
	"DK65 Blue Helos #011",
	"DK65 Blue Helos #012",
	"DK65 Blue Helos #013",
	"DK65 Blue Helos #014",
	"DK65 Blue Helos #015",
	"DK65 Blue Helos #016",
	
	"DK65 Red Helos #001",
	"DK65 Red Helos #002",
	"DK65 Red Helos #003",
	"DK65 Red Helos #004",
	"DK65 Red Helos #005",
	"DK65 Red Helos #006",
	"DK65 Red Helos #007",
	"DK65 Red Helos #008",
	"DK65 Red Helos #009",
	"DK65 Red Helos #010",
	"DK65 Red Helos #011",
	"DK65 Red Helos #012",
	"DK65 Red Helos #013",
	"DK65 Red Helos #014",
	"DK65 Red Helos #015",
	"DK65 Red Helos #016",

	"EK14 Blue Helos #001",
	"EK14 Blue Helos #002",
	"EK14 Blue Helos #003",
	"EK14 Blue Helos #004",
	"EK14 Blue Helos #005",
	"EK14 Blue Helos #006",
	"EK14 Blue Helos #007",
	"EK14 Blue Helos #008",
	"EK14 Blue Helos #009",
	"EK14 Blue Helos #010",
	"EK14 Blue Helos #011",
	"EK14 Blue Helos #012",
	"EK14 Blue Helos #013",
	"EK14 Blue Helos #014",
	"EK14 Blue Helos #015",
	"EK14 Blue Helos #016",
	
	"EK14 Red Helos #001",
	"EK14 Red Helos #002",
	"EK14 Red Helos #003",
	"EK14 Red Helos #004",
	"EK14 Red Helos #005",
	"EK14 Red Helos #006",
	"EK14 Red Helos #007",
	"EK14 Red Helos #008",
	"EK14 Red Helos #009",
	"EK14 Red Helos #010",
	"EK14 Red Helos #011",
	"EK14 Red Helos #012",
	"EK14 Red Helos #013",
	"EK14 Red Helos #014",
	"EK14 Red Helos #015",
	"EK14 Red Helos #016",

	"EK20 Blue Helos #001",
	"EK20 Blue Helos #002",
	"EK20 Blue Helos #003",
	"EK20 Blue Helos #004",
	"EK20 Blue Helos #005",
	"EK20 Blue Helos #006",
	"EK20 Blue Helos #007",
	"EK20 Blue Helos #008",
	"EK20 Blue Helos #009",
	"EK20 Blue Helos #010",
	"EK20 Blue Helos #011",
	"EK20 Blue Helos #012",
	"EK20 Blue Helos #013",
	"EK20 Blue Helos #014",
	"EK20 Blue Helos #015",
	"EK20 Blue Helos #016",
	
	"EK20 Red Helos #001",
	"EK20 Red Helos #002",
	"EK20 Red Helos #003",
	"EK20 Red Helos #004",
	"EK20 Red Helos #005",
	"EK20 Red Helos #006",
	"EK20 Red Helos #007",
	"EK20 Red Helos #008",
	"EK20 Red Helos #009",
	"EK20 Red Helos #010",
	"EK20 Red Helos #011",
	"EK20 Red Helos #012",
	"EK20 Red Helos #013",
	"EK20 Red Helos #014",
	"EK20 Red Helos #015",
	"EK20 Red Helos #016",

	"EK51 Blue Helos #001",
	"EK51 Blue Helos #002",
	"EK51 Blue Helos #003",
	"EK51 Blue Helos #004",
	"EK51 Blue Helos #005",
	"EK51 Blue Helos #006",
	"EK51 Blue Helos #007",
	"EK51 Blue Helos #008",
	"EK51 Blue Helos #009",
	"EK51 Blue Helos #010",
	"EK51 Blue Helos #011",
	"EK51 Blue Helos #012",
	"EK51 Blue Helos #013",
	"EK51 Blue Helos #014",
	"EK51 Blue Helos #015",
	"EK51 Blue Helos #016",
	
	"EK51 Red Helos #001",
	"EK51 Red Helos #002",
	"EK51 Red Helos #003",
	"EK51 Red Helos #004",
	"EK51 Red Helos #005",
	"EK51 Red Helos #006",
	"EK51 Red Helos #007",
	"EK51 Red Helos #008",
	"EK51 Red Helos #009",
	"EK51 Red Helos #010",
	"EK51 Red Helos #011",
	"EK51 Red Helos #012",
	"EK51 Red Helos #013",
	"EK51 Red Helos #014",
	"EK51 Red Helos #015",
	"EK51 Red Helos #016",

	"EJ98 Blue Helos #001",
	"EJ98 Blue Helos #002",
	"EJ98 Blue Helos #003",
	"EJ98 Blue Helos #004",
	"EJ98 Blue Helos #005",
	"EJ98 Blue Helos #006",
	"EJ98 Blue Helos #007",
	"EJ98 Blue Helos #008",
	"EJ98 Blue Helos #009",
	"EJ98 Blue Helos #010",
	"EJ98 Blue Helos #011",
	"EJ98 Blue Helos #012",
	"EJ98 Blue Helos #013",
	"EJ98 Blue Helos #014",
	"EJ98 Blue Helos #015",
	"EJ98 Blue Helos #016",
	
	"EJ98 Red Helos #001",
	"EJ98 Red Helos #002",
	"EJ98 Red Helos #003",
	"EJ98 Red Helos #004",
	"EJ98 Red Helos #005",
	"EJ98 Red Helos #006",
	"EJ98 Red Helos #007",
	"EJ98 Red Helos #008",
	"EJ98 Red Helos #009",
	"EJ98 Red Helos #010",
	"EJ98 Red Helos #011",
	"EJ98 Red Helos #012",
	"EJ98 Red Helos #013",
	"EJ98 Red Helos #014",
	"EJ98 Red Helos #015",
	"EJ98 Red Helos #016",

	"FJ53 Blue Helos #001",
	"FJ53 Blue Helos #002",
	"FJ53 Blue Helos #003",
	"FJ53 Blue Helos #004",
	"FJ53 Blue Helos #005",
	"FJ53 Blue Helos #006",
	"FJ53 Blue Helos #007",
	"FJ53 Blue Helos #008",
	"FJ53 Blue Helos #009",
	"FJ53 Blue Helos #010",
	"FJ53 Blue Helos #011",
	"FJ53 Blue Helos #012",
	"FJ53 Blue Helos #013",
	"FJ53 Blue Helos #014",
	"FJ53 Blue Helos #015",
	"FJ53 Blue Helos #016",
	
	"FJ53 Red Helos #001",
	"FJ53 Red Helos #002",
	"FJ53 Red Helos #003",
	"FJ53 Red Helos #004",
	"FJ53 Red Helos #005",
	"FJ53 Red Helos #006",
	"FJ53 Red Helos #007",
	"FJ53 Red Helos #008",
	"FJ53 Red Helos #009",
	"FJ53 Red Helos #010",
	"FJ53 Red Helos #011",
	"FJ53 Red Helos #012",
	"FJ53 Red Helos #013",
	"FJ53 Red Helos #014",
	"FJ53 Red Helos #015",
	"FJ53 Red Helos #016",

	"FJ69 Blue Helos #001",
	"FJ69 Blue Helos #002",
	"FJ69 Blue Helos #003",
	"FJ69 Blue Helos #004",
	"FJ69 Blue Helos #005",
	"FJ69 Blue Helos #006",
	"FJ69 Blue Helos #007",
	"FJ69 Blue Helos #008",
	"FJ69 Blue Helos #009",
	"FJ69 Blue Helos #010",
	"FJ69 Blue Helos #011",
	"FJ69 Blue Helos #012",
	"FJ69 Blue Helos #013",
	"FJ69 Blue Helos #014",
	"FJ69 Blue Helos #015",
	"FJ69 Blue Helos #016",
	
	"FJ69 Red Helos #001",
	"FJ69 Red Helos #002",
	"FJ69 Red Helos #003",
	"FJ69 Red Helos #004",
	"FJ69 Red Helos #005",
	"FJ69 Red Helos #006",
	"FJ69 Red Helos #007",
	"FJ69 Red Helos #008",
	"FJ69 Red Helos #009",
	"FJ69 Red Helos #010",
	"FJ69 Red Helos #011",
	"FJ69 Red Helos #012",
	"FJ69 Red Helos #013",
	"FJ69 Red Helos #014",
	"FJ69 Red Helos #015",
	"FJ69 Red Helos #016",

	"FJ95 Blue Helos #001",
	"FJ95 Blue Helos #002",
	"FJ95 Blue Helos #003",
	"FJ95 Blue Helos #004",
	"FJ95 Blue Helos #005",
	"FJ95 Blue Helos #006",
	"FJ95 Blue Helos #007",
	"FJ95 Blue Helos #008",
	"FJ95 Blue Helos #009",
	"FJ95 Blue Helos #010",
	"FJ95 Blue Helos #011",
	"FJ95 Blue Helos #012",
	"FJ95 Blue Helos #013",
	"FJ95 Blue Helos #014",
	"FJ95 Blue Helos #015",
	"FJ95 Blue Helos #016",
	
	"FJ95 Red Helos #001",
	"FJ95 Red Helos #002",
	"FJ95 Red Helos #003",
	"FJ95 Red Helos #004",
	"FJ95 Red Helos #005",
	"FJ95 Red Helos #006",
	"FJ95 Red Helos #007",
	"FJ95 Red Helos #008",
	"FJ95 Red Helos #009",
	"FJ95 Red Helos #010",
	"FJ95 Red Helos #011",
	"FJ95 Red Helos #012",
	"FJ95 Red Helos #013",
	"FJ95 Red Helos #014",
	"FJ95 Red Helos #015",
	"FJ95 Red Helos #016",

	"GJ22 Blue Helos #001",
	"GJ22 Blue Helos #002",
	"GJ22 Blue Helos #003",
	"GJ22 Blue Helos #004",
	"GJ22 Blue Helos #005",
	"GJ22 Blue Helos #006",
	"GJ22 Blue Helos #007",
	"GJ22 Blue Helos #008",
	"GJ22 Blue Helos #009",
	"GJ22 Blue Helos #010",
	"GJ22 Blue Helos #011",
	"GJ22 Blue Helos #012",
	"GJ22 Blue Helos #013",
	"GJ22 Blue Helos #014",
	"GJ22 Blue Helos #015",
	"GJ22 Blue Helos #016",
	
	"GJ22 Red Helos #001",
	"GJ22 Red Helos #002",
	"GJ22 Red Helos #003",
	"GJ22 Red Helos #004",
	"GJ22 Red Helos #005",
	"GJ22 Red Helos #006",
	"GJ22 Red Helos #007",
	"GJ22 Red Helos #008",
	"GJ22 Red Helos #009",
	"GJ22 Red Helos #010",
	"GJ22 Red Helos #011",
	"GJ22 Red Helos #012",
	"GJ22 Red Helos #013",
	"GJ22 Red Helos #014",
	"GJ22 Red Helos #015",
	"GJ22 Red Helos #016",

	"LN21 Blue Helos #001",
	"LN21 Blue Helos #002",
	"LN21 Blue Helos #003",
	"LN21 Blue Helos #004",
	"LN21 Blue Helos #005",
	"LN21 Blue Helos #006",
	"LN21 Blue Helos #007",
	"LN21 Blue Helos #008",
	"LN21 Blue Helos #009",
	"LN21 Blue Helos #010",
	"LN21 Blue Helos #011",
	"LN21 Blue Helos #012",
	"LN21 Blue Helos #013",
	"LN21 Blue Helos #014",
	"LN21 Blue Helos #015",
	"LN21 Blue Helos #016",
	
	"LN21 Red Helos #001",
	"LN21 Red Helos #002",
	"LN21 Red Helos #003",
	"LN21 Red Helos #004",
	"LN21 Red Helos #005",
	"LN21 Red Helos #006",
	"LN21 Red Helos #007",
	"LN21 Red Helos #008",
	"LN21 Red Helos #009",
	"LN21 Red Helos #010",
	"LN21 Red Helos #011",
	"LN21 Red Helos #012",
	"LN21 Red Helos #013",
	"LN21 Red Helos #014",
	"LN21 Red Helos #015",
	"LN21 Red Helos #016",

	"LN16 Blue Helos #001",
	"LN16 Blue Helos #002",
	"LN16 Blue Helos #003",
	"LN16 Blue Helos #004",
	"LN16 Blue Helos #005",
	"LN16 Blue Helos #006",
	"LN16 Blue Helos #007",
	"LN16 Blue Helos #008",
	"LN16 Blue Helos #009",
	"LN16 Blue Helos #010",
	"LN16 Blue Helos #011",
	"LN16 Blue Helos #012",
	"LN16 Blue Helos #013",
	"LN16 Blue Helos #014",
	"LN16 Blue Helos #015",
	"LN16 Blue Helos #016",
	
	"LN16 Red Helos #001",
	"LN16 Red Helos #002",
	"LN16 Red Helos #003",
	"LN16 Red Helos #004",
	"LN16 Red Helos #005",
	"LN16 Red Helos #006",
	"LN16 Red Helos #007",
	"LN16 Red Helos #008",
	"LN16 Red Helos #009",
	"LN16 Red Helos #010",
	"LN16 Red Helos #011",
	"LN16 Red Helos #012",
	"LN16 Red Helos #013",
	"LN16 Red Helos #014",
	"LN16 Red Helos #015",
	"LN16 Red Helos #016",

	"LP31 Blue Helos #001",
	"LP31 Blue Helos #002",
	"LP31 Blue Helos #003",
	"LP31 Blue Helos #004",
	"LP31 Blue Helos #005",
	"LP31 Blue Helos #006",
	"LP31 Blue Helos #007",
	"LP31 Blue Helos #008",
	"LP31 Blue Helos #009",
	"LP31 Blue Helos #010",
	"LP31 Blue Helos #011",
	"LP31 Blue Helos #012",
	"LP31 Blue Helos #013",
	"LP31 Blue Helos #014",
	"LP31 Blue Helos #015",
	"LP31 Blue Helos #016",
	
	"LP31 Red Helos #001",
	"LP31 Red Helos #002",
	"LP31 Red Helos #003",
	"LP31 Red Helos #004",
	"LP31 Red Helos #005",
	"LP31 Red Helos #006",
	"LP31 Red Helos #007",
	"LP31 Red Helos #008",
	"LP31 Red Helos #009",
	"LP31 Red Helos #010",
	"LP31 Red Helos #011",
	"LP31 Red Helos #012",
	"LP31 Red Helos #013",
	"LP31 Red Helos #014",
	"LP31 Red Helos #015",
	"LP31 Red Helos #016",

	"LP17 Blue Helos #001",
	"LP17 Blue Helos #002",
	"LP17 Blue Helos #003",
	"LP17 Blue Helos #004",
	"LP17 Blue Helos #005",
	"LP17 Blue Helos #006",
	"LP17 Blue Helos #007",
	"LP17 Blue Helos #008",
	"LP17 Blue Helos #009",
	"LP17 Blue Helos #010",
	"LP17 Blue Helos #011",
	"LP17 Blue Helos #012",
	"LP17 Blue Helos #013",
	"LP17 Blue Helos #014",
	"LP17 Blue Helos #015",
	"LP17 Blue Helos #016",
	
	"LP17 Red Helos #001",
	"LP17 Red Helos #002",
	"LP17 Red Helos #003",
	"LP17 Red Helos #004",
	"LP17 Red Helos #005",
	"LP17 Red Helos #006",
	"LP17 Red Helos #007",
	"LP17 Red Helos #008",
	"LP17 Red Helos #009",
	"LP17 Red Helos #010",
	"LP17 Red Helos #011",
	"LP17 Red Helos #012",
	"LP17 Red Helos #013",
	"LP17 Red Helos #014",
	"LP17 Red Helos #015",
	"LP17 Red Helos #016",

	"LP65 Blue Helos #001",
	"LP65 Blue Helos #002",
	"LP65 Blue Helos #003",
	"LP65 Blue Helos #004",
	"LP65 Blue Helos #005",
	"LP65 Blue Helos #006",
	"LP65 Blue Helos #007",
	"LP65 Blue Helos #008",
	"LP65 Blue Helos #009",
	"LP65 Blue Helos #010",
	"LP65 Blue Helos #011",
	"LP65 Blue Helos #012",
	"LP65 Blue Helos #013",
	"LP65 Blue Helos #014",
	"LP65 Blue Helos #015",
	"LP65 Blue Helos #016",
	
	"LP65 Red Helos #001",
	"LP65 Red Helos #002",
	"LP65 Red Helos #003",
	"LP65 Red Helos #004",
	"LP65 Red Helos #005",
	"LP65 Red Helos #006",
	"LP65 Red Helos #007",
	"LP65 Red Helos #008",
	"LP65 Red Helos #009",
	"LP65 Red Helos #010",
	"LP65 Red Helos #011",
	"LP65 Red Helos #012",
	"LP65 Red Helos #013",
	"LP65 Red Helos #014",
	"LP65 Red Helos #015",
	"LP65 Red Helos #016",

	"LM56 Blue Helos #001",
	"LM56 Blue Helos #002",
	"LM56 Blue Helos #003",
	"LM56 Blue Helos #004",
	"LM56 Blue Helos #005",
	"LM56 Blue Helos #006",
	"LM56 Blue Helos #007",
	"LM56 Blue Helos #008",
	"LM56 Blue Helos #009",
	"LM56 Blue Helos #010",
	"LM56 Blue Helos #011",
	"LM56 Blue Helos #012",
	"LM56 Blue Helos #013",
	"LM56 Blue Helos #014",
	"LM56 Blue Helos #015",
	"LM56 Blue Helos #016",
	
	"LM56 Red Helos #001",
	"LM56 Red Helos #002",
	"LM56 Red Helos #003",
	"LM56 Red Helos #004",
	"LM56 Red Helos #005",
	"LM56 Red Helos #006",
	"LM56 Red Helos #007",
	"LM56 Red Helos #008",
	"LM56 Red Helos #009",
	"LM56 Red Helos #010",
	"LM56 Red Helos #011",
	"LM56 Red Helos #012",
	"LM56 Red Helos #013",
	"LM56 Red Helos #014",
	"LM56 Red Helos #015",
	"LM56 Red Helos #016",

	"LM95 Blue Helos #001",
	"LM95 Blue Helos #002",
	"LM95 Blue Helos #003",
	"LM95 Blue Helos #004",
	"LM95 Blue Helos #005",
	"LM95 Blue Helos #006",
	"LM95 Blue Helos #007",
	"LM95 Blue Helos #008",
	"LM95 Blue Helos #009",
	"LM95 Blue Helos #010",
	"LM95 Blue Helos #011",
	"LM95 Blue Helos #012",
	"LM95 Blue Helos #013",
	"LM95 Blue Helos #014",
	"LM95 Blue Helos #015",
	"LM95 Blue Helos #016",
	
	"LM95 Red Helos #001",
	"LM95 Red Helos #002",
	"LM95 Red Helos #003",
	"LM95 Red Helos #004",
	"LM95 Red Helos #005",
	"LM95 Red Helos #006",
	"LM95 Red Helos #007",
	"LM95 Red Helos #008",
	"LM95 Red Helos #009",
	"LM95 Red Helos #010",
	"LM95 Red Helos #011",
	"LM95 Red Helos #012",
	"LM95 Red Helos #013",
	"LM95 Red Helos #014",
	"LM95 Red Helos #015",
	"LM95 Red Helos #016",

	"MM25 Blue Helos #001",
	"MM25 Blue Helos #002",
	"MM25 Blue Helos #003",
	"MM25 Blue Helos #004",
	"MM25 Blue Helos #005",
	"MM25 Blue Helos #006",
	"MM25 Blue Helos #007",
	"MM25 Blue Helos #008",
	"MM25 Blue Helos #009",
	"MM25 Blue Helos #010",
	"MM25 Blue Helos #011",
	"MM25 Blue Helos #012",
	"MM25 Blue Helos #013",
	"MM25 Blue Helos #014",
	"MM25 Blue Helos #015",
	"MM25 Blue Helos #016",
	
	"MM25 Red Helos #001",
	"MM25 Red Helos #002",
	"MM25 Red Helos #003",
	"MM25 Red Helos #004",
	"MM25 Red Helos #005",
	"MM25 Red Helos #006",
	"MM25 Red Helos #007",
	"MM25 Red Helos #008",
	"MM25 Red Helos #009",
	"MM25 Red Helos #010",
	"MM25 Red Helos #011",
	"MM25 Red Helos #012",
	"MM25 Red Helos #013",
	"MM25 Red Helos #014",
	"MM25 Red Helos #015",
	"MM25 Red Helos #016",

	"Soganlug Blue Helos #001",
	"Soganlug Blue Helos #002",
	"Soganlug Blue Helos #003",
	"Soganlug Blue Helos #004",
	"Soganlug Blue Helos #005",
	"Soganlug Blue Helos #006",
	"Soganlug Blue Helos #007",
	"Soganlug Blue Helos #008",
	"Soganlug Blue Helos #009",
	"Soganlug Blue Helos #010",
	"Soganlug Blue Helos #011",
	"Soganlug Blue Helos #012",
	"Soganlug Blue Helos #013",
	"Soganlug Blue Helos #014",
	"Soganlug Blue Helos #015",
	"Soganlug Blue Helos #016",
	
	"Soganlug Red Helos #001",
	"Soganlug Red Helos #002",
	"Soganlug Red Helos #003",
	"Soganlug Red Helos #004",
	"Soganlug Red Helos #005",
	"Soganlug Red Helos #006",
	"Soganlug Red Helos #007",
	"Soganlug Red Helos #008",
	"Soganlug Red Helos #009",
	"Soganlug Red Helos #010",
	"Soganlug Red Helos #011",
	"Soganlug Red Helos #012",
	"Soganlug Red Helos #013",
	"Soganlug Red Helos #014",
	"Soganlug Red Helos #015",
	"Soganlug Red Helos #016",

	"Tbilisi Blue Helos #001",
	"Tbilisi Blue Helos #002",
	"Tbilisi Blue Helos #003",
	"Tbilisi Blue Helos #004",
	"Tbilisi Blue Helos #005",
	"Tbilisi Blue Helos #006",
	"Tbilisi Blue Helos #007",
	"Tbilisi Blue Helos #008",
	"Tbilisi Blue Helos #009",
	"Tbilisi Blue Helos #010",
	"Tbilisi Blue Helos #011",
	"Tbilisi Blue Helos #012",
	"Tbilisi Blue Helos #013",
	"Tbilisi Blue Helos #014",
	"Tbilisi Blue Helos #015",
	"Tbilisi Blue Helos #016",
	
	"Tbilisi Red Helos #001",
	"Tbilisi Red Helos #002",
	"Tbilisi Red Helos #003",
	"Tbilisi Red Helos #004",
	"Tbilisi Red Helos #005",
	"Tbilisi Red Helos #006",
	"Tbilisi Red Helos #007",
	"Tbilisi Red Helos #008",
	"Tbilisi Red Helos #009",
	"Tbilisi Red Helos #010",
	"Tbilisi Red Helos #011",
	"Tbilisi Red Helos #012",
	"Tbilisi Red Helos #013",
	"Tbilisi Red Helos #014",
	"Tbilisi Red Helos #015",
	"Tbilisi Red Helos #016",

	"MM75 Blue Helos #001",
	"MM75 Blue Helos #002",
	"MM75 Blue Helos #003",
	"MM75 Blue Helos #004",
	"MM75 Blue Helos #005",
	"MM75 Blue Helos #006",
	"MM75 Blue Helos #007",
	"MM75 Blue Helos #008",
	"MM75 Blue Helos #009",
	"MM75 Blue Helos #010",
	"MM75 Blue Helos #011",
	"MM75 Blue Helos #012",
	"MM75 Blue Helos #013",
	"MM75 Blue Helos #014",
	"MM75 Blue Helos #015",
	"MM75 Blue Helos #016",
	
	"MM75 Red Helos #001",
	"MM75 Red Helos #002",
	"MM75 Red Helos #003",
	"MM75 Red Helos #004",
	"MM75 Red Helos #005",
	"MM75 Red Helos #006",
	"MM75 Red Helos #007",
	"MM75 Red Helos #008",
	"MM75 Red Helos #009",
	"MM75 Red Helos #010",
	"MM75 Red Helos #011",
	"MM75 Red Helos #012",
	"MM75 Red Helos #013",
	"MM75 Red Helos #014",
	"MM75 Red Helos #015",
	"MM75 Red Helos #016",

	"MM69 Blue Helos #001",
	"MM69 Blue Helos #002",
	"MM69 Blue Helos #003",
	"MM69 Blue Helos #004",
	"MM69 Blue Helos #005",
	"MM69 Blue Helos #006",
	"MM69 Blue Helos #007",
	"MM69 Blue Helos #008",
	"MM69 Blue Helos #009",
	"MM69 Blue Helos #010",
	"MM69 Blue Helos #011",
	"MM69 Blue Helos #012",
	"MM69 Blue Helos #013",
	"MM69 Blue Helos #014",
	"MM69 Blue Helos #015",
	"MM69 Blue Helos #016",
	
	"MM69 Red Helos #001",
	"MM69 Red Helos #002",
	"MM69 Red Helos #003",
	"MM69 Red Helos #004",
	"MM69 Red Helos #005",
	"MM69 Red Helos #006",
	"MM69 Red Helos #007",
	"MM69 Red Helos #008",
	"MM69 Red Helos #009",
	"MM69 Red Helos #010",
	"MM69 Red Helos #011",
	"MM69 Red Helos #012",
	"MM69 Red Helos #013",
	"MM69 Red Helos #014",
	"MM69 Red Helos #015",
	"MM69 Red Helos #016",

	"MN61 Blue Helos #001",
	"MN61 Blue Helos #002",
	"MN61 Blue Helos #003",
	"MN61 Blue Helos #004",
	"MN61 Blue Helos #005",
	"MN61 Blue Helos #006",
	"MN61 Blue Helos #007",
	"MN61 Blue Helos #008",
	"MN61 Blue Helos #009",
	"MN61 Blue Helos #010",
	"MN61 Blue Helos #011",
	"MN61 Blue Helos #012",
	"MN61 Blue Helos #013",
	"MN61 Blue Helos #014",
	"MN61 Blue Helos #015",
	"MN61 Blue Helos #016",
	
	"MN61 Red Helos #001",
	"MN61 Red Helos #002",
	"MN61 Red Helos #003",
	"MN61 Red Helos #004",
	"MN61 Red Helos #005",
	"MN61 Red Helos #006",
	"MN61 Red Helos #007",
	"MN61 Red Helos #008",
	"MN61 Red Helos #009",
	"MN61 Red Helos #010",
	"MN61 Red Helos #011",
	"MN61 Red Helos #012",
	"MN61 Red Helos #013",
	"MN61 Red Helos #014",
	"MN61 Red Helos #015",
	"MN61 Red Helos #016",

	"MP24 Blue Helos #001",
	"MP24 Blue Helos #002",
	"MP24 Blue Helos #003",
	"MP24 Blue Helos #004",
	"MP24 Blue Helos #005",
	"MP24 Blue Helos #006",
	"MP24 Blue Helos #007",
	"MP24 Blue Helos #008",
	"MP24 Blue Helos #009",
	"MP24 Blue Helos #010",
	"MP24 Blue Helos #011",
	"MP24 Blue Helos #012",
	"MP24 Blue Helos #013",
	"MP24 Blue Helos #014",
	"MP24 Blue Helos #015",
	"MP24 Blue Helos #016",
	
	"MP24 Red Helos #001",
	"MP24 Red Helos #002",
	"MP24 Red Helos #003",
	"MP24 Red Helos #004",
	"MP24 Red Helos #005",
	"MP24 Red Helos #006",
	"MP24 Red Helos #007",
	"MP24 Red Helos #008",
	"MP24 Red Helos #009",
	"MP24 Red Helos #010",
	"MP24 Red Helos #011",
	"MP24 Red Helos #012",
	"MP24 Red Helos #013",
	"MP24 Red Helos #014",
	"MP24 Red Helos #015",
	"MP24 Red Helos #016",

	"MN19 Blue Helos #001",
	"MN19 Blue Helos #002",
	"MN19 Blue Helos #003",
	"MN19 Blue Helos #004",
	"MN19 Blue Helos #005",
	"MN19 Blue Helos #006",
	"MN19 Blue Helos #007",
	"MN19 Blue Helos #008",
	"MN19 Blue Helos #009",
	"MN19 Blue Helos #010",
	"MN19 Blue Helos #011",
	"MN19 Blue Helos #012",
	"MN19 Blue Helos #013",
	"MN19 Blue Helos #014",
	"MN19 Blue Helos #015",
	"MN19 Blue Helos #016",
	
	"MN19 Red Helos #001",
	"MN19 Red Helos #002",
	"MN19 Red Helos #003",
	"MN19 Red Helos #004",
	"MN19 Red Helos #005",
	"MN19 Red Helos #006",
	"MN19 Red Helos #007",
	"MN19 Red Helos #008",
	"MN19 Red Helos #009",
	"MN19 Red Helos #010",
	"MN19 Red Helos #011",
	"MN19 Red Helos #012",
	"MN19 Red Helos #013",
	"MN19 Red Helos #014",
	"MN19 Red Helos #015",
	"MN19 Red Helos #016",

	"MN34 Blue Helos #001",
	"MN34 Blue Helos #002",
	"MN34 Blue Helos #003",
	"MN34 Blue Helos #004",
	"MN34 Blue Helos #005",
	"MN34 Blue Helos #006",
	"MN34 Blue Helos #007",
	"MN34 Blue Helos #008",
	"MN34 Blue Helos #009",
	"MN34 Blue Helos #010",
	"MN34 Blue Helos #011",
	"MN34 Blue Helos #012",
	"MN34 Blue Helos #013",
	"MN34 Blue Helos #014",
	"MN34 Blue Helos #015",
	"MN34 Blue Helos #016",
	
	"MN34 Red Helos #001",
	"MN34 Red Helos #002",
	"MN34 Red Helos #003",
	"MN34 Red Helos #004",
	"MN34 Red Helos #005",
	"MN34 Red Helos #006",
	"MN34 Red Helos #007",
	"MN34 Red Helos #008",
	"MN34 Red Helos #009",
	"MN34 Red Helos #010",
	"MN34 Red Helos #011",
	"MN34 Red Helos #012",
	"MN34 Red Helos #013",
	"MN34 Red Helos #014",
	"MN34 Red Helos #015",
	"MN34 Red Helos #016",

	"MN12 Blue Helos #001",
	"MN12 Blue Helos #002",
	"MN12 Blue Helos #003",
	"MN12 Blue Helos #004",
	"MN12 Blue Helos #005",
	"MN12 Blue Helos #006",
	"MN12 Blue Helos #007",
	"MN12 Blue Helos #008",
	"MN12 Blue Helos #009",
	"MN12 Blue Helos #010",
	"MN12 Blue Helos #011",
	"MN12 Blue Helos #012",
	"MN12 Blue Helos #013",
	"MN12 Blue Helos #014",
	"MN12 Blue Helos #015",
	"MN12 Blue Helos #016",
	
	"MN12 Red Helos #001",
	"MN12 Red Helos #002",
	"MN12 Red Helos #003",
	"MN12 Red Helos #004",
	"MN12 Red Helos #005",
	"MN12 Red Helos #006",
	"MN12 Red Helos #007",
	"MN12 Red Helos #008",
	"MN12 Red Helos #009",
	"MN12 Red Helos #010",
	"MN12 Red Helos #011",
	"MN12 Red Helos #012",
	"MN12 Red Helos #013",
	"MN12 Red Helos #014",
	"MN12 Red Helos #015",
	"MN12 Red Helos #016",

	"LN90 Blue Helos #001",
	"LN90 Blue Helos #002",
	"LN90 Blue Helos #003",
	"LN90 Blue Helos #004",
	"LN90 Blue Helos #005",
	"LN90 Blue Helos #006",
	"LN90 Blue Helos #007",
	"LN90 Blue Helos #008",
	"LN90 Blue Helos #009",
	"LN90 Blue Helos #010",
	"LN90 Blue Helos #011",
	"LN90 Blue Helos #012",
	"LN90 Blue Helos #013",
	"LN90 Blue Helos #014",
	"LN90 Blue Helos #015",
	"LN90 Blue Helos #016",
	
	"LN90 Red Helos #001",
	"LN90 Red Helos #002",
	"LN90 Red Helos #003",
	"LN90 Red Helos #004",
	"LN90 Red Helos #005",
	"LN90 Red Helos #006",
	"LN90 Red Helos #007",
	"LN90 Red Helos #008",
	"LN90 Red Helos #009",
	"LN90 Red Helos #010",
	"LN90 Red Helos #011",
	"LN90 Red Helos #012",
	"LN90 Red Helos #013",
	"LN90 Red Helos #014",
	"LN90 Red Helos #015",
	"LN90 Red Helos #016",

} -- List of all the MEDEVAC _UNIT NAMES_ (the line where it says "Pilot" in the ME)!

csar.bluemash = {
    "Batumi PickUp",
    "Kobuleti PickUp",
	"LN90 PickUp",
	"MN12 PickUp",
	"MN34 PickUp",
	"MN19 PickUp",
	"MP24 PickUp",
	"MN61 PickUp",
	"MM69 PickUp",
	"MM75 PickUp",
	"Tbilisi PickUp",
	"Soganlug PickUp",
	"MM25 PickUp",
	"LM95 PickUp",
	"LM56 PickUp",
	"LP65 PickUp",
	"LP17 PickUp",
	"LP31 PickUp",
	"LN16 PickUp",
	"LN21 PickUp",
	"GJ22 PickUp",
	"FJ95 PickUp",
	"FJ69 PickUp",
	"FJ53 PickUp",
	"EJ98 PickUp",
	"EK51 PickUp",
	"EK20 PickUp",
	"EK14 PickUp",
	"DK65 PickUp",
	"Novorossiysk PickUp",
	"Sochi PickUp",
	"Gudauta PickUp",
	"DK61 PickUp",
	"EJ08 PickUp",
	"EJ34 PickUp",
	"GH17 PickUp",
	"KN76 PickUp",
	"GH03 PickUp",
	"KN53 PickUp",
	"KN70 PickUp",
	"GG19 PickUp",
	"RedBeachhead PickUp",
	"Anapa PickUp",
	"Gelendzhik PickUp",
	"Krymsk PickUp",
	"Krasnodar-Center PickUp",
	"Maykop PickUp",
	"Mineralnye Vody PickUp",
	"Nalchik PickUp",
	"Mozdok PickUp",
	"Beslan PickUp",
	"Vaziani PickUp",
	"Sukumi PickUp",
	"Kutaisi PickUp",
	"Senaki PickUp",
	
} -- The unit that serves as MASH for the blue side

csar.redmash = {
    "Batumi PickUp",
    "Batumi PickUp",
    "Kobuleti PickUp",
	"LN90 PickUp",
	"MN12 PickUp",
	"MN34 PickUp",
	"MN19 PickUp",
	"MP24 PickUp",
	"MN61 PickUp",
	"MM69 PickUp",
	"MM75 PickUp",
	"Tbilisi PickUp",
	"Soganlug PickUp",
	"MM25 PickUp",
	"LM95 PickUp",
	"LM56 PickUp",
	"LP65 PickUp",
	"LP17 PickUp",
	"LP31 PickUp",
	"LN16 PickUp",
	"LN21 PickUp",
	"GJ22 PickUp",
	"FJ95 PickUp",
	"FJ69 PickUp",
	"FJ53 PickUp",
	"EJ98 PickUp",
	"EK51 PickUp",
	"EK20 PickUp",
	"EK14 PickUp",
	"DK65 PickUp",
	"Novorossiysk PickUp",
	"Sochi PickUp",
	"Gudauta PickUp",
	"DK61 PickUp",
	"EJ08 PickUp",
	"EJ34 PickUp",
	"GH17 PickUp",
	"KN76 PickUp",
	"GH03 PickUp",
	"KN53 PickUp",
	"KN70 PickUp",
	"GG19 PickUp",
	"RedBeachhead PickUp",
	"Anapa PickUp",
	"Gelendzhik PickUp",
	"Krymsk PickUp",
	"Krasnodar-Center PickUp",
	"Maykop PickUp",
	"Mineralnye Vody PickUp",
	"Nalchik PickUp",
	"Mozdok PickUp",
	"Beslan PickUp",
	"Vaziani PickUp",
	"Sukumi PickUp",
	"Kutaisi PickUp",
	"Senaki PickUp",
} -- The unit that serves as MASH for the red side


csar.csarMode = 3

--      0 - No Limit - NO Aircraft disabling
--      1 - Disable Aircraft when its down - Timeout to reenable aircraft
--      2 - Disable Aircraft for Pilot when he's shot down -- timeout to reenable pilot for aircraft
--      3 - Pilot Life Limit - No Aircraft Disabling -- timeout to reset lives?

csar.maxLives = 6 -- Maximum pilot lives

csar.countCSARCrash = false -- If you set to true, pilot lives count for CSAR and CSAR aircraft will count.

csar.reenableIfCSARCrashes = true -- If a CSAR heli crashes, the pilots are counted as rescued anyway. Set to false to Stop this

-- - I recommend you leave the option on below IF USING MODE 1 otherwise the
-- aircraft will be disabled for the duration of the mission
csar.disableAircraftTimeout = true -- Allow aircraft to be used after 20 minutes if the pilot isnt rescued
csar.disableTimeoutTime = 240 -- Time in minutes for TIMEOUT

csar.destructionHeight = 150 -- height in meters an aircraft will be destroyed at if the aircraft is disabled

csar.enableForAI = false -- set to false to disable AI units from being rescued.

csar.enableForRED = true -- enable for red side

csar.enableForBLUE = true -- enable for blue side

csar.enableSlotBlocking = true -- if set to true, you need to put the csarSlotBlockGameGUI.lua
-- in C:/Users/<YOUR USERNAME>/DCS/Scripts for 1.5 or C:/Users/<YOUR USERNAME>/DCS.openalpha/Scripts for 2.0
-- For missions using FLAGS and this script, the CSAR flags will NOT interfere with your mission :)

csar.bluesmokecolor = 4 -- Color of smokemarker for blue side, 0 is green, 1 is red, 2 is white, 3 is orange and 4 is blue
csar.redsmokecolor = 1 -- Color of smokemarker for red side, 0 is green, 1 is red, 2 is white, 3 is orange and 4 is blue

csar.requestdelay = 2 -- Time in seconds before the survivors will request Medevac

csar.coordtype = 1 -- Use Lat/Long DDM (0), Lat/Long DMS (1), MGRS (2), Bullseye imperial (3) or Bullseye metric (4) for coordinates.
csar.coordaccuracy = 1 -- Precision of the reported coordinates, see MIST-docs at http://wiki.hoggit.us/view/GetMGRSString
-- only applies to _non_ bullseye coords

csar.immortalcrew = false -- Set to true to make wounded crew immortal
csar.invisiblecrew = false -- Set to true to make wounded crew insvisible

csar.messageTime = 30 -- Time to show the intial wounded message for in seconds

csar.loadDistance = 60 -- configure distance for pilot to get in helicopter in meters.

csar.radioSound = "beacon.ogg" -- the name of the sound file to use for the Pilot radio beacons. If this isnt added to the mission BEACONS WONT WORK!

csar.allowFARPRescue = true --allows pilot to be rescued by landing at a FARP or Airbase

-- SETTINGS FOR MISSION DESIGNER ^^^^^^^^^^^^^^^^^^^*

-- ***************************************************************
-- **************** Mission Editor Functions *********************
-- ***************************************************************

-----------------------------------------------------------------
-- Resets all life limits so everyone can spawn again. Usage:
-- csar.resetAllPilotLives()
--
function csar.resetAllPilotLives()

    --for x, _pilot in pairs(csar.pilotLives) do
	for _, _pilot in pairs(csar.pilotLives) do

        trigger.action.setUserFlag("CSAR_PILOT" .. _pilot:gsub('%W', ''), csar.maxLives + 1)
    end

    csar.pilotLives = {}
    env.info("Pilot Lives Reset!")
end

-----------------------------------------------------------------
-- Resets all life limits so everyone can spawn again. Usage:
-- csar.resetAllPilotLives()
--
function csar.resetPilotLife(_playerName)

    csar.pilotLives[_playerName] = nil

    trigger.action.setUserFlag("CSAR_PILOT" .. _playerName:gsub('%W', ''), csar.maxLives + 1)

    env.info("Pilot life Reset!")
end


-- ***************************************************************
-- **************** BE CAREFUL BELOW HERE ************************
-- ***************************************************************

-- Sanity checks of mission designer
assert(mist ~= nil, "\n\n** HEY MISSION-DESIGNER! **\n\nMiST has not been loaded!\n\nMake sure MiST 4.0.57 or higher is running\n*before* running this script!\n")

csar.addedTo = {}

csar.downedPilotCounterRed = 0
csar.downedPilotCounterBlue = 0

csar.woundedGroups = {} -- contains the new group of units
csar.inTransitGroups = {} -- contain a table for each SAR with all units he has with the
-- original name of the killed group

csar.radioBeacons = {}

csar.smokeMarkers = {} -- tracks smoke markers for groups
csar.heliVisibleMessage = {} -- tracks if the first message has been sent of the heli being visible

csar.heliCloseMessage = {} -- tracks heli close message  ie heli < 500m distance

csar.radioBeacons = {} -- all current beacons

csar.max_units = 6 --number of pilots that can be carried

csar.currentlyDisabled = {} --stored disabled aircraft

csar.hoverStatus = {} -- tracks status of a helis hover above a downed pilot

csar.pilotDisabled = {} -- tracks what aircraft a pilot is disabled for

csar.pilotLives = {} -- tracks how many lives a pilot has

csar.takenOff = {}

function csar.tableLength(T)

    if T == nil then
        return 0
    end


    local count = 0
    --for _ in pairs(T) do count = count + 1 end
	for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function csar.pilotsOnboard(_heliName)
    local count = 0
    if csar.inTransitGroups[_heliName] then
        for _, _group in pairs(csar.inTransitGroups[_heliName]) do
            count = count + 1
        end
    end
    return count
end

-- Handles all world events
csar.eventHandler = {}
function csar.eventHandler:onEvent(_event)
    local status, err = pcall(function(_event)

        if _event == nil or _event.initiator == nil then
            return false

--        elseif _event.id == 3 then -- taken offf
        elseif _event.id == world.event.S_EVENT_TAKEOFF then

        if _event.initiator:getName() then
            csar.takenOff[_event.initiator:getName()] = true
        end

        return true
		
--        elseif _event.id == 15 then --player entered unit
        elseif _event.id == world.event.S_EVENT_BIRTH then

        if _event.initiator:getName() then
            csar.takenOff[_event.initiator:getName()] = nil
        end

        -- if its a sar heli, re-add check status script
        for _, _heliName in pairs(csar.csarUnits) do

            if _heliName == _event.initiator:getName() then
                -- add back the status script
                for _woundedName, _groupInfo in pairs(csar.woundedGroups) do

                    if _groupInfo.side == _event.initiator:getCoalition() then

                        --env.info(string.format("Schedule Respawn %s %s",_heliName,_woundedName))
                        -- queue up script
                        -- Schedule timer to check when to pop smoke
                        timer.scheduleFunction(csar.checkWoundedGroupStatus, { _heliName, _woundedName }, timer.getTime() + 5)
                    end
                end
            end
        end
--Below is Commented out in the RSR CSAR
        if _event.initiator:getName() and _event.initiator:getPlayerName() then

            env.info("Checking Unit - " .. _event.initiator:getName())
            csar.checkDisabledAircraftStatus({ _event.initiator:getName(), _event.initiator:getPlayerName() })
        end

        return true

--        elseif (_event.id == 9) then
        elseif _event.id == world.event.S_EVENT_PILOT_DEAD then

            -- Pilot dead

            env.info("Event unit - Pilot Dead")

            local _unit = _event.initiator

            if _unit == nil then
                return -- error!
            end

            local _coalition = _unit:getCoalition()

            if _coalition == 1 and not csar.enableForRED then
                return --ignore!
            end

            if _coalition == 2 and not csar.enableForBLUE then
                return --ignore!
            end

            -- Catch multiple events here?
            if csar.takenOff[_event.initiator:getName()] == true or _unit:inAir() then

                if csar.doubleEjection(_unit) then
                    return
                end
                local message = "Mayday, mayday, mayday!  " .. _unit:getTypeName() .. " was shot down; no chute spotted" --added from RSR
--                trigger.action.outTextForCoalition(_unit:getCoalition(), "MAYDAY MAYDAY! " .. _unit:getTypeName() .. " shot down. No Chute!", 10)
				env.info(message) --added from RSR
				csar.handleEjectOrCrash(_unit, true)
            else
                env.info("Pilot Hasnt taken off, ignore")
            end

            return

        elseif world.event.S_EVENT_EJECTION == _event.id then

            env.info("Event unit - Pilot Ejected")

            local _unit = _event.initiator

            if _unit == nil then
                env.warning("No unit found for ejection event") --added from RSR
                return -- error!
            end

            local _coalition = _unit:getCoalition()

            if _coalition == 1 and not csar.enableForRED then
                env.info("Ignoring ejection as not enabled for red") --added from RSR
                return --ignore!
            end

            if _coalition == 2 and not csar.enableForBLUE then
                env.info("Ignoring ejection as not enabled for blue") --added from RSR
                return --ignore!
            end

            -- TODO catch ejection on runway?

            if csar.enableForAI == false and _unit:getPlayerName() == nil then
               env.info("Ignoring ejection as getPlayerName is nil") --added from RSR
                return
            end

            if csar.takenOff[_event.initiator:getName()] ~= true and not _unit:inAir() then
                env.info("Pilot Hasnt taken off, ignore")
                return -- give up, pilot hasnt taken off
            end

            if csar.doubleEjection(_unit) then
                env.info("Double ejection") --added from rsr
                return
            end

            env.info("Spawning CSAR group") --added from RSR
            local _spawnedGroup = csar.spawnGroup(_unit)
            csar.addSpecialParametersToGroup(_spawnedGroup)

            --trigger.action.outTextForCoalition(_unit:getCoalition(), "MAYDAY MAYDAY! " .. _unit:getTypeName() .. " shot down. Chute Spotted!", 10)

            local message = "Mayday, mayday, mayday!  " .. _unit:getTypeName() .. " was shot down; chute spotted" --added
            trigger.action.outTextForCoalition(_unit:getCoalition(), message, 10) --added
            env.info(message) --added
			
            local _freq = csar.generateADFFrequency()

            csar.addBeaconToGroup(_spawnedGroup:getName(), _freq)

            --handle lives and plane disabling
            csar.handleEjectOrCrash(_unit, false)

            -- Generate DESCRIPTION text
            local _text = " "
            if _unit:getPlayerName() ~= nil then
                _text = "Pilot " .. _unit:getPlayerName() .. " of " .. _unit:getName() .. " - " .. _unit:getTypeName()
            else
                _text = "AI Pilot of " .. _unit:getName() .. " - " .. _unit:getTypeName()
            end

            csar.woundedGroups[_spawnedGroup:getName()] = { side = _spawnedGroup:getCoalition(), originalUnit = _unit:getName(), frequency = _freq, desc = _text, player = _unit:getPlayerName() }

            csar.initSARForPilot(_spawnedGroup, _freq)

            return true

        elseif world.event.S_EVENT_LAND == _event.id then

            if _event.initiator:getName() then
                csar.takenOff[_event.initiator:getName()] = nil
            end

            if csar.allowFARPRescue then

                --env.info("Landing")

                local _unit = _event.initiator

                if _unit == nil then
                    env.info("Unit Nil on Landing")
                    return -- error!
                end

                csar.takenOff[_event.initiator:getName()] = nil

                local _place = _event.place

                if _place == nil then
                    env.info("Landing Place Nil")
                    return -- error!
                end
                -- Coalition == 3 seems to be a bug... unless it means contested?!
                if _place:getCoalition() == _unit:getCoalition() or _place:getCoalition() == 0 or _place:getCoalition() == 3 then
                    csar.rescuePilots(_unit)
                    --env.info("Rescued")
                    --   env.info("Rescued by Landing")

                else
                    --    env.info("Cant Rescue ")

                    env.info(string.format("airfield %d, unit %d", _place:getCoalition(), _unit:getCoalition()))
                end
            end

            return true
        end
    end, _event)
    if (not status) then
        env.error(string.format("Error while handling event %s", err), false)
    end
end

csar.lastCrash = {}

function csar.doubleEjection(_unit)

    if csar.lastCrash[_unit:getName()] then
        local _time = csar.lastCrash[_unit:getName()]

        if timer.getTime() - _time < 10 then
            env.info("Caught double ejection!")
            return true
        end
    end

    csar.lastCrash[_unit:getName()] = timer.getTime()

    return false
end

function csar.handleEjectOrCrash(_unit, _crashed)

    -- disable aircraft for ALL pilots
    if csar.csarMode == 1 then

        if csar.currentlyDisabled[_unit:getName()] ~= nil then
            return --already ejected once!
        end

        --                --mark plane as broken and unflyable
        if _unit:getPlayerName() ~= nil and csar.currentlyDisabled[_unit:getName()] == nil then

            if csar.countCSARCrash == false then
                for _, _heliName in pairs(csar.csarUnits) do

                    if _unit:getName() == _heliName then
                        -- IGNORE Crashed CSAR
                        return
                    end
                end
            end

            csar.currentlyDisabled[_unit:getName()] = { timeout = (csar.disableTimeoutTime * 60) + timer.getTime(), desc = "", noPilot = _crashed, unitId = _unit:getID(), name = _unit:getName() }

            -- disable aircraft

            trigger.action.setUserFlag("CSAR_AIRCRAFT" .. _unit:getID(), 100)

            env.info("Unit Disabled: " .. _unit:getName() .. " ID:" .. _unit:getID())
        end

    elseif csar.csarMode == 2 then -- disable aircraft for pilot

    --csar.pilotDisabled
    if _unit:getPlayerName() ~= nil and csar.pilotDisabled[_unit:getPlayerName() .. "_" .. _unit:getName()] == nil then

        if csar.countCSARCrash == false then
            for _, _heliName in pairs(csar.csarUnits) do

                if _unit:getName() == _heliName then
                    -- IGNORE Crashed CSAR
                    return
                end
            end
        end

        csar.pilotDisabled[_unit:getPlayerName() .. "_" .. _unit:getName()] = { timeout = (csar.disableTimeoutTime * 60) + timer.getTime(), desc = "", noPilot = true, unitId = _unit:getID(), player = _unit:getPlayerName(), name = _unit:getName() }

        -- disable aircraft

        -- strip special characters from name gsub('%W','')
        trigger.action.setUserFlag("CSAR_AIRCRAFT" .. _unit:getPlayerName():gsub('%W', '') .. "_" .. _unit:getID(), 100)

        env.info("Unit Disabled for player : " .. _unit:getName())
    end

    elseif csar.csarMode == 3 then -- No Disable - Just reduce player lives

    --csar.pilotDisabled
    if _unit:getPlayerName() ~= nil then

        if csar.countCSARCrash == false then
            for _, _heliName in pairs(csar.csarUnits) do

                if _unit:getName() == _heliName then
                    -- IGNORE Crashed CSAR
                    return
                end
            end
        end

        local _lives = csar.pilotLives[_unit:getPlayerName()]

        if _lives == nil then
            _lives = csar.maxLives + 1 --plus 1 because we'll use flag set to 1 to indicate NO MORE LIVES
        end

        csar.pilotLives[_unit:getPlayerName()] = _lives - 1

        trigger.action.setUserFlag("CSAR_PILOT" .. _unit:getPlayerName():gsub('%W', ''), _lives - 1)
		end
    end
end

function csar.enableAircraft(_name, _playerName)


    -- enable aircraft for ALL pilots
    if csar.csarMode == 1 then

        local _details = csar.currentlyDisabled[_name]

        if _details ~= nil then
            csar.currentlyDisabled[_name] = nil -- {timeout =  (csar.disableTimeoutTime*60) + timer.getTime(),desc="",noPilot = _crashed,unitId=_unit:getID() }

            --use flag to reenable
            trigger.action.setUserFlag("CSAR_AIRCRAFT" .. _details.unitId, 0)
        end

    elseif csar.csarMode == 2 and _playerName ~= nil then -- enable aircraft for pilot

    local _details = csar.pilotDisabled[_playerName .. "_" .. _name]

    if _details ~= nil then
        csar.pilotDisabled[_playerName .. "_" .. _name] = nil

        trigger.action.setUserFlag("CSAR_AIRCRAFT" .. _playerName:gsub('%W', '') .. "_" .. _details.unitId, 0)
    end

    elseif csar.csarMode == 3 and _playerName ~= nil then -- No Disable - Just reduce player lives

    -- give back life

    local _lives = csar.pilotLives[_playerName]

    if _lives == nil then
        _lives = csar.maxLives + 1 --plus 1 because we'll use flag set to 1 to indicate NO MORE LIVES
    else
        _lives = _lives + 1 -- give back live!

        if csar.maxLives + 1 <= _lives then
            _lives = csar.maxLives + 1 --plus 1 because we'll use flag set to 1 to indicate NO MORE LIVES
        end
    end

    csar.pilotLives[_playerName] = _lives

    trigger.action.setUserFlag("CSAR_PILOT" .. _playerName:gsub('%W', ''), _lives)
    end
end



function csar.reactivateAircraft()

    timer.scheduleFunction(csar.reactivateAircraft, nil, timer.getTime() + 5)

    -- disable aircraft for ALL pilots
    if csar.csarMode == 1 then

        for _unitName, _details in pairs(csar.currentlyDisabled) do

            if timer.getTime() >= _details.timeout then

                csar.enableAircraft(_unitName)
            end
        end

    elseif csar.csarMode == 2 then -- disable aircraft for pilot

    for _key, _details in pairs(csar.pilotDisabled) do

        if timer.getTime() >= _details.timeout then

            csar.enableAircraft(_details.name, _details.player)
        end
    end

    elseif csar.csarMode == 3 then -- No Disable - Just reduce player lives
    end
end

function csar.checkDisabledAircraftStatus(_args)

    local _name = _args[1]
    local _playerName = _args[2]

    local _unit = Unit.getByName(_name)

    --if its not the same user anymore, stop checking
    if _unit ~= nil and _unit:getPlayerName() ~= nil and _playerName == _unit:getPlayerName() then
        -- disable aircraft for ALL pilots
        if csar.csarMode == 1 then

            local _details = csar.currentlyDisabled[_unit:getName()]

            if _details ~= nil then

                local _time = _details.timeout - timer.getTime()

                if _details.noPilot then

                    if csar.disableAircraftTimeout then

                        local _text = string.format("This aircraft cannot be flow as the pilot was killed in a crash. Reinforcements in %.2dM,%.2dS\n\nIt will be DESTROYED on takeoff!", (_time / 60), _time % 60)

                        --display message,
                        csar.displayMessageToSAR(_unit, _text, 10, true)
                    else
                        --display message,
                        csar.displayMessageToSAR(_unit, "This aircraft cannot be flown again as the pilot was killed in a crash\n\nIt will be DESTROYED on takeoff!", 10, true)
                    end
                else
                    if csar.disableAircraftTimeout then
                        --display message,
                        csar.displayMessageToSAR(_unit, _details.desc .. " needs to be rescued or reinforcements arrive before this aircraft can be flown again! Reinforcements in " .. string.format("%.2dM,%.2d", (_time / 60), _time % 60) .. "\n\nIt will be DESTROYED on takeoff!", 10, true)
                    else
                        --display message,
                        csar.displayMessageToSAR(_unit, _details.desc .. " needs to be rescued before this aircraft can be flown again!\n\nIt will be DESTROYED on takeoff!", 10, true)
                    end
                end

                if csar.destroyUnit(_unit) then
                    return --plane destroyed
                else
                    --check again in 10 seconds
                    timer.scheduleFunction(csar.checkDisabledAircraftStatus, _args, timer.getTime() + 10)
                end
            end



        elseif csar.csarMode == 2 then -- disable aircraft for pilot

        local _details = csar.pilotDisabled[_unit:getPlayerName() .. "_" .. _unit:getName()]

        if _details ~= nil then

            local _time = _details.timeout - timer.getTime()

            if _details.noPilot then

                if csar.disableAircraftTimeout then

                    local _text = string.format("This aircraft cannot be flow as the pilot was killed in a crash. Reinforcements in %.2dM,%.2dS\n\nIt will be DESTROYED on takeoff!", (_time / 60), _time % 60)

                    --display message,
                    csar.displayMessageToSAR(_unit, _text, 10, true)
                else
                    --display message,
                    csar.displayMessageToSAR(_unit, "This aircraft cannot be flown again as the pilot was killed in a crash\n\nIt will be DESTROYED on takeoff!", 10, true)
                end
            else
                if csar.disableAircraftTimeout then
                    --display message,
                    csar.displayMessageToSAR(_unit, _details.desc .. " needs to be rescued or reinforcements arrive before this aircraft can be flown again! Reinforcements in " .. string.format("%.2dM,%.2d", (_time / 60), _time % 60) .. "\n\nIt will be DESTROYED on takeoff!", 10, true)
                else
                    --display message,
                    csar.displayMessageToSAR(_unit, _details.desc .. " needs to be rescued before this aircraft can be flown again!\n\nIt will be DESTROYED on takeoff!", 10, true)
                end
            end

            if csar.destroyUnit(_unit) then
                return --plane destroyed
            else
                --check again in 10 seconds
                timer.scheduleFunction(csar.checkDisabledAircraftStatus, _args, timer.getTime() + 10)
            end
        end


        elseif csar.csarMode == 3 then -- No Disable - Just reduce player lives

        local _lives = csar.pilotLives[_unit:getPlayerName()]

        if _lives == nil or _lives > 1 then

            if _lives == nil then
                _lives = csar.maxLives + 1
            end

            -- -1 for lives as we use 1 to indicate out of lives!
            local _text = string.format("CSAR ACTIVE! \n\nYou have " .. (_lives - 1) .. " lives remaining. Make sure you eject! This way you can be rescued by a friend or yourself to regain the life.")

            csar.displayMessageToSAR(_unit, _text, 20, true)

            return

        else

            local _text = string.format("You have run out of LIVES! Lives will be reset on mission restart or when your pilot is rescued.\n\nThis aircraft will be DESTROYED on takeoff! (Helicopters are exempt)")

            --display message,
            csar.displayMessageToSAR(_unit, _text, 10, true)

            if csar.destroyUnit(_unit) then
                return --plane destroyed
            else
                --check again in 10 seconds --think I need to bump the time out on this message until I can get it to only show on the fighters.
                timer.scheduleFunction(csar.checkDisabledAircraftStatus, _args, timer.getTime() + 10)
            end
        end
        end
    end
end

function csar.destroyUnit(_unit)

    --destroy if the SAME player is still in the aircraft
    -- if a new player got in it'll be destroyed in a bit anyways
    if _unit ~= nil and _unit:getPlayerName() ~= nil then

        if csar.heightDiff(_unit) > csar.destructionHeight then

            csar.displayMessageToSAR(_unit, "**** Aircraft Destroyed as the pilot needs to be rescued or you have no lives! ****", 10, true)
            --if we're off the ground then explode
            trigger.action.explosion(_unit:getPoint(), 100);

            return true
        end
        --_unit:destroy() destroy doesnt work for playes who arent the host in multiplayer
    end

    return false
end

function csar.heightDiff(_unit)

    local _point = _unit:getPoint()

    return _point.y - land.getHeight({ x = _point.x, y = _point.z })
end

csar.addBeaconToGroup = function(_woundedGroupName, _freq)

    local _group = Group.getByName(_woundedGroupName)

    if _group == nil then

        --return frequency to pool of available
        for _i, _current in ipairs(csar.usedVHFFrequencies) do
            if _current == _freq then
                table.insert(csar.freeVHFFrequencies, _freq)
                table.remove(csar.usedVHFFrequencies, _i)
            end
        end

        return
    end

    local _sound = "l10n/DEFAULT/" .. csar.radioSound

    trigger.action.radioTransmission(_sound, _group:getUnit(1):getPoint(), 0, false, _freq, 1000)

    timer.scheduleFunction(csar.refreshRadioBeacon, { _woundedGroupName, _freq }, timer.getTime() + 30)
end

csar.refreshRadioBeacon = function(_args)

    csar.addBeaconToGroup(_args[1], _args[2])
end

csar.addSpecialParametersToGroup = function(_spawnedGroup)

    -- Immortal code for alexej21
    local _setImmortal = {
        id = 'SetImmortal',
        params = {
            value = true
        }
    }
    -- invisible to AI, Shagrat
    local _setInvisible = {
        id = 'SetInvisible',
        params = {
            value = true
        }
    }

    local _controller = _spawnedGroup:getController()

    if (csar.immortalcrew) then
        Controller.setCommand(_controller, _setImmortal)
    end

    if (csar.invisiblecrew) then
        Controller.setCommand(_controller, _setInvisible)
    end
end

function csar.spawnGroup(_deadUnit)

    local _id = mist.getNextGroupId()

    local _groupName = "Downed Pilot #" .. _id

    local _side = _deadUnit:getCoalition()

    local _pos = _deadUnit:getPoint()

    local _group = {
        ["visible"] = false,
        ["groupId"] = _id,
        ["hidden"] = false,
        ["units"] = {},
        ["name"] = _groupName,
        ["task"] = {},
    }

    if _side == 2 then
        _group.units[1] = csar.createUnit(_pos.x + 50, _pos.z + 50, 120, "Soldier M4")
    else
        _group.units[1] = csar.createUnit(_pos.x + 50, _pos.z + 50, 120, "Infantry AK")
    end

    _group.category = Group.Category.GROUND;
    _group.country = _deadUnit:getCountry();

    local _spawnedGroup = Group.getByName(mist.dynAdd(_group).name)

    -- Turn off AI
    trigger.action.setGroupAIOff(_spawnedGroup)

    return _spawnedGroup
end


function csar.createUnit(_x, _y, _heading, _type)

    local _id = mist.getNextUnitId();

    local _name = string.format("Wounded Pilot #%s", _id)

    local _newUnit = {
        ["y"] = _y,
        ["type"] = _type,
        ["name"] = _name,
        ["unitId"] = _id,
        ["heading"] = _heading,
        ["playerCanDrive"] = false,
        ["skill"] = "Excellent",
        ["x"] = _x,
    }

    return _newUnit
end

function csar.initSARForPilot(_downedGroup, _freq)

    local _leader = _downedGroup:getUnit(1)

    local _coordinatesText = csar.getPositionOfWounded(_downedGroup)

    local
    _text = string.format("%s requests SAR at %s, beacon at %.2f KHz",
        _leader:getName(), _coordinatesText, _freq / 1000)

    local _randPercent = math.random(1, 100)

    -- Loop through all the medevac units
    for x, _heliName in pairs(csar.csarUnits) do
        local _status, _err = pcall(function(_args)
            local _unitName = _args[1]
            local _woundedSide = _args[2]
            local _medevacText = _args[3]
            local _leaderPos = _args[4]
            local _groupName = _args[5]
            local _group = _args[6]

            local _heli = csar.getSARHeli(_unitName)

            -- queue up for all SAR, alive or dead, we dont know the side if they're dead or not spawned so check
            --coalition in scheduled smoke

            if _heli ~= nil then

                -- Check coalition side
                if (_woundedSide == _heli:getCoalition()) then
                    -- Display a delayed message
                    timer.scheduleFunction(csar.delayedHelpMessage, { _unitName, _medevacText, _groupName }, timer.getTime() + csar.requestdelay)

                    -- Schedule timer to check when to pop smoke
                    timer.scheduleFunction(csar.checkWoundedGroupStatus, { _unitName, _groupName }, timer.getTime() + 1)
                end
            else
                --env.warning(string.format("Medevac unit %s not active", _heliName), false)

                -- Schedule timer for Dead unit so when the unit respawns he can still pickup units
                --timer.scheduleFunction(medevac.checkStatus, {_unitName,_groupName}, timer.getTime() + 5)
            end
        end, { _heliName, _leader:getCoalition(), _text, _leader:getPoint(), _downedGroup:getName(), _downedGroup })

        if (not _status) then
            env.warning(string.format("Error while checking with medevac-units %s", _err))
        end
    end
end

function csar.checkWoundedGroupStatus(_argument)

    local _status, _err = pcall(function(_args)
        local _heliName = _args[1]
        local _woundedGroupName = _args[2]

        local _woundedGroup = csar.getWoundedGroup(_woundedGroupName)
        local _heliUnit = csar.getSARHeli(_heliName)

        -- if wounded group is not here then message alread been sent to SARs
        -- stop processing any further
        if csar.woundedGroups[_woundedGroupName] == nil then
            return
        end

        if _heliUnit == nil then
            -- stop wounded moving, head back to smoke as target heli is DEAD

            -- in transit cleanup
            --  csar.inTransitGroups[_heliName] = nil
            return
        end

        -- double check that this function hasnt been queued for the wrong side

        if csar.woundedGroups[_woundedGroupName].side ~= _heliUnit:getCoalition() then
            return --wrong side!
        end

        if csar.checkGroupNotKIA(_woundedGroup, _woundedGroupName, _heliUnit, _heliName) then

            local _woundedLeader = _woundedGroup[1]
            local _lookupKeyHeli = _heliUnit:getID() .. "_" .. _woundedLeader:getID() --lookup key for message state tracking

            local _distance = csar.getDistance(_heliUnit:getPoint(), _woundedLeader:getPoint())

            if _distance < 3000 then

                if csar.checkCloseWoundedGroup(_distance, _heliUnit, _heliName, _woundedGroup, _woundedGroupName) == true then
                    -- we're close, reschedule
                    timer.scheduleFunction(csar.checkWoundedGroupStatus, _args, timer.getTime() + 1)
                end

            else
                csar.heliVisibleMessage[_lookupKeyHeli] = nil

                --reschedule as units arent dead yet , schedule for a bit slower though as we're far away
                timer.scheduleFunction(csar.checkWoundedGroupStatus, _args, timer.getTime() + 5)
            end
        end
    end, _argument)

    if not _status then

        env.error(string.format("error checkWoundedGroupStatus %s", _err))
    end
end

function csar.popSmokeForGroup(_woundedGroupName, _woundedLeader)
    -- have we popped smoke already in the last 5 mins
    local _lastSmoke = csar.smokeMarkers[_woundedGroupName]
    if _lastSmoke == nil or timer.getTime() > _lastSmoke then

        local _smokecolor
        if (_woundedLeader:getCoalition() == 2) then
            _smokecolor = csar.bluesmokecolor
        else
            _smokecolor = csar.redsmokecolor
        end
        trigger.action.smoke(_woundedLeader:getPoint(), _smokecolor)

        csar.smokeMarkers[_woundedGroupName] = timer.getTime() + 300 -- next smoke time
    end
end

function csar.pickupUnit(_heliUnit, _pilotName, _woundedGroup, _woundedGroupName)

    local _woundedLeader = _woundedGroup[1]

    -- GET IN!
    local _heliName = _heliUnit:getName()
    local _groups = csar.inTransitGroups[_heliName]
    local _unitsInHelicopter = csar.pilotsOnboard(_heliName)

    -- init table if there is none for this helicopter
    if not _groups then
        csar.inTransitGroups[_heliName] = {}
        _groups = csar.inTransitGroups[_heliName]
    end

    -- if the heli can't pick them up, show a message and return
    if _unitsInHelicopter + 1 > csar.max_units then
        csar.displayMessageToSAR(_heliUnit, string.format("%s, %s. We're already crammed with %d guys! Sorry!",
            _pilotName, _heliName, _unitsInHelicopter, _unitsInHelicopter), 10)
        return true
    end

    csar.inTransitGroups[_heliName][_woundedGroupName] =
    {
        originalUnit = csar.woundedGroups[_woundedGroupName].originalUnit,
        woundedGroup = _woundedGroupName,
        side = _heliUnit:getCoalition(),
        desc = csar.woundedGroups[_woundedGroupName].desc,
        player = csar.woundedGroups[_woundedGroupName].player,
    }

    Group.destroy(_woundedLeader:getGroup())

    csar.displayMessageToSAR(_heliUnit, string.format("%s: %s I'm in! Get to the MASH ASAP! ", _heliName, _pilotName), 10)

    timer.scheduleFunction(csar.scheduledSARFlight,
        {
            heliName = _heliUnit:getName(),
            groupName = _woundedGroupName
        },
        timer.getTime() + 1)

    return true
end


-- Helicopter is within 3km
function csar.checkCloseWoundedGroup(_distance, _heliUnit, _heliName, _woundedGroup, _woundedGroupName)

    local _woundedLeader = _woundedGroup[1]
    local _lookupKeyHeli = _heliUnit:getID() .. "_" .. _woundedLeader:getID() --lookup key for message state tracking

    local _pilotName = csar.woundedGroups[_woundedGroupName].desc

    local _woundedCount = 1

    local _reset = true

    csar.popSmokeForGroup(_woundedGroupName, _woundedLeader)

    if csar.heliVisibleMessage[_lookupKeyHeli] == nil then

        csar.displayMessageToSAR(_heliUnit, string.format("%s: %s. I hear you! Damn that thing is loud! Land or hover by the smoke.", _heliName, _pilotName), 30)

        --mark as shown for THIS heli and THIS group
        csar.heliVisibleMessage[_lookupKeyHeli] = true
    end

    if (_distance < 500) then

        if csar.heliCloseMessage[_lookupKeyHeli] == nil then

            csar.displayMessageToSAR(_heliUnit, string.format("%s: %s. You're close now! Land or hover at the smoke.", _heliName, _pilotName), 10)

            --mark as shown for THIS heli and THIS group
            csar.heliCloseMessage[_lookupKeyHeli] = true
        end

        -- have we landed close enough?
        if csar.inAir(_heliUnit) == false then

            -- if you land on them, doesnt matter if they were heading to someone else as you're closer, you win! :)
            if (_distance < csar.loadDistance) then

                return csar.pickupUnit(_heliUnit, _pilotName, _woundedGroup, _woundedGroupName)
            end

        else

            local _unitsInHelicopter = csar.pilotsOnboard(_heliName)

            if csar.inAir(_heliUnit) and _unitsInHelicopter + 1 <= csar.max_units then

                if _distance < 8.0 then

                    --check height!
                    local _height = _heliUnit:getPoint().y - _woundedLeader:getPoint().y

                    if _height <= 20.0 then

                        local _time = csar.hoverStatus[_lookupKeyHeli]

                        if _time == nil then
                            csar.hoverStatus[_lookupKeyHeli] = 10
                            _time = 10
                        else
                            _time = csar.hoverStatus[_lookupKeyHeli] - 1
                            csar.hoverStatus[_lookupKeyHeli] = _time
                        end

                        if _time > 0 then
                            csar.displayMessageToSAR(_heliUnit, "Hovering above " .. _pilotName .. ". \n\nHold hover for " .. _time .. " seconds to winch them up. \n\nIf the countdown stops you're too far away!", 10, true)
                        else
                            csar.hoverStatus[_lookupKeyHeli] = nil
                            return csar.pickupUnit(_heliUnit, _pilotName, _woundedGroup, _woundedGroupName)
                        end
                        _reset = false
                    else
                        csar.displayMessageToSAR(_heliUnit, "Too high to winch " .. _pilotName .. " \nReduce height and hover for 10 seconds!", 5, true)
                    end
                end
            end
        end
    end

    if _reset then
        csar.hoverStatus[_lookupKeyHeli] = nil
    end

    return true
end



function csar.checkGroupNotKIA(_woundedGroup, _woundedGroupName, _heliUnit, _heliName)

    -- check if unit has died or been picked up
    if #_woundedGroup == 0 and _heliUnit ~= nil then

        local inTransit = false

        for _currentHeli, _groups in pairs(csar.inTransitGroups) do

            if _groups[_woundedGroupName] then
                local _group = _groups[_woundedGroupName]
                if _group.side == _heliUnit:getCoalition() then
                    inTransit = true

                    csar.displayToAllSAR(string.format("%s has been picked up by %s", _woundedGroupName, _currentHeli), _heliUnit:getCoalition(), _heliName)

                    break
                end
            end
        end


        --display to all sar
        if inTransit == false then
            --DEAD

            csar.displayToAllSAR(string.format("%s is KIA ", _woundedGroupName), _heliUnit:getCoalition(), _heliName)
        end

        --     medevac.displayMessageToSAR(_heliUnit, string.format("%s: %s is dead", _heliName,_woundedGroupName ),10)

        --stops the message being displayed again
        csar.woundedGroups[_woundedGroupName] = nil

        return false
    end

    --continue
    return true
end


function csar.scheduledSARFlight(_args)

    local _status, _err = pcall(function(_args)

        local _heliUnit = csar.getSARHeli(_args.heliName)
        local _woundedGroupName = _args.groupName

        if (_heliUnit == nil) then

            --helicopter crashed?
            -- Put intransit pilots back
            --TODO possibly respawn the guys
            if csar.reenableIfCSARCrashes then
                local _rescuedGroups = csar.inTransitGroups[_args.heliName]

                if _rescuedGroups ~= nil then

                    -- enable pilots again
                    for _, _rescueGroup in pairs(_rescuedGroups) do

                        csar.enableAircraft(_rescueGroup.originalUnit, _rescuedGroups.player)
                    end
                end
            end

            csar.inTransitGroups[_args.heliName] = nil

            return
        end

        if csar.inTransitGroups[_heliUnit:getName()] == nil or csar.inTransitGroups[_heliUnit:getName()][_woundedGroupName] == nil then
            -- Groups already rescued
            return
        end


        local _dist = csar.getClosetMASH(_heliUnit)

        if _dist == -1 then
            -- Can now rescue to FARP
            -- Mash Dead
            --  csar.inTransitGroups[_heliUnit:getName()][_woundedGroupName] = nil

            --  csar.displayMessageToSAR(_heliUnit, string.format("%s: NO MASH! The pilot died of despair!", _heliUnit:getName()), 10)

            return
        end

        if _dist < 200 and _heliUnit:inAir() == false then

            csar.rescuePilots(_heliUnit)

            return
        end

        -- end
        --queue up
        timer.scheduleFunction(csar.scheduledSARFlight,
            {
                heliName = _heliUnit:getName(),
                groupName = _woundedGroupName
            },
            timer.getTime() + 1)
    end, _args)
    if (not _status) then
        env.error(string.format("Error in scheduledSARFlight\n\n%s", _err))
    end
end

function csar.rescuePilots(_heliUnit)
    local _rescuedGroups = csar.inTransitGroups[_heliUnit:getName()]

    if _rescuedGroups == nil then
        -- Groups already rescued
        return
    end

    csar.inTransitGroups[_heliUnit:getName()] = nil

    local _txt = string.format("%s: The pilots have been taken to the\nmedical clinic. Good job!", _heliUnit:getName())

    -- enable pilots again
    for _, _rescueGroup in pairs(_rescuedGroups) do

        csar.enableAircraft(_rescueGroup.originalUnit, _rescueGroup.player)
    end

    csar.displayMessageToSAR(_heliUnit, _txt, 10)

    -- env.info("Rescued")
end


function csar.getSARHeli(_unitName)

    local _heli = Unit.getByName(_unitName)

    if _heli ~= nil and _heli:isActive() and _heli:getLife() > 0 then

        return _heli
    end

    return nil
end


-- Displays a request for medivac
function csar.delayedHelpMessage(_args)
    local status, err = pcall(function(_args)
        local _heliName = _args[1]
        local _text = _args[2]
        local _injuredGroupName = _args[3]

        local _heli = csar.getSARHeli(_heliName)

        if _heli ~= nil and #csar.getWoundedGroup(_injuredGroupName) > 0 then
            csar.displayMessageToSAR(_heli, _text, csar.messageTime)


            local _groupId = csar.getGroupId(_heli)

            if _groupId then
                trigger.action.outSoundForGroup(_groupId, "l10n/DEFAULT/CSAR.ogg")
            end

        else
            env.info("No Active Heli or Group DEAD")
        end
    end, _args)

    if (not status) then
        env.error(string.format("Error in delayedHelpMessage "))
    end

    return nil
end

function csar.displayMessageToSAR(_unit, _text, _time, _clear)

    local _groupId = csar.getGroupId(_unit)

    if _groupId then
        if _clear == true then
            trigger.action.outTextForGroup(_groupId, _text, _time, _clear)
        else
            trigger.action.outTextForGroup(_groupId, _text, _time)
        end
    end
end

function csar.getWoundedGroup(_groupName)
    local _status, _result = pcall(function(_groupName)

        local _woundedGroup = {}
        local _units = Group.getByName(_groupName):getUnits()

        for _, _unit in pairs(_units) do

            if _unit ~= nil and _unit:isActive() and _unit:getLife() > 0 then
                table.insert(_woundedGroup, _unit)
            end
        end

        return _woundedGroup
    end, _groupName)

    if (_status) then
        return _result
    else
        --env.warning(string.format("getWoundedGroup failed! Returning 0.%s",_result), false)
        return {} --return empty table
    end
end


function csar.convertGroupToTable(_group)

    local _unitTable = {}

    for _, _unit in pairs(_group:getUnits()) do

        if _unit ~= nil and _unit:getLife() > 0 then
            table.insert(_unitTable, _unit:getName())
        end
    end

    return _unitTable
end

function csar.getPositionOfWounded(_woundedGroup)

    local _woundedTable = csar.convertGroupToTable(_woundedGroup)

    local _coordinatesText = ""
    if csar.coordtype == 0 then -- Lat/Long DMTM
    _coordinatesText = string.format("%s", mist.getLLString({ units = _woundedTable, acc = csar.coordaccuracy, DMS = 0 }))

    elseif csar.coordtype == 1 then -- Lat/Long DMS
    _coordinatesText = string.format("%s", mist.getLLString({ units = _woundedTable, acc = csar.coordaccuracy, DMS = 1 }))

    elseif csar.coordtype == 2 then -- MGRS
    _coordinatesText = string.format("%s", mist.getMGRSString({ units = _woundedTable, acc = csar.coordaccuracy }))

    elseif csar.coordtype == 3 then -- Bullseye Imperial
    _coordinatesText = string.format("bullseye %s", mist.getBRString({ units = _woundedTable, ref = coalition.getMainRefPoint(_woundedGroup:getCoalition()), alt = 0 }))

    else -- Bullseye Metric --(medevac.coordtype == 4)
    _coordinatesText = string.format("bullseye %s", mist.getBRString({ units = _woundedTable, ref = coalition.getMainRefPoint(_woundedGroup:getCoalition()), alt = 0, metric = 1 }))
    end

    return _coordinatesText
end

-- Displays all active MEDEVACS/SAR
function csar.displayActiveSAR(_unitName)
    local _msg = "Active MEDEVAC/SAR:"

    local _heli = csar.getSARHeli(_unitName)

    if _heli == nil then
        return
    end

    local _heliSide = _heli:getCoalition()

    local _csarList = {}

    for _groupName, _value in pairs(csar.woundedGroups) do

        local _woundedGroup = csar.getWoundedGroup(_groupName)

        if #_woundedGroup > 0 and (_woundedGroup[1]:getCoalition() == _heliSide) then

            local _coordinatesText = csar.getPositionOfWounded(_woundedGroup[1]:getGroup())

            local _distance = csar.getDistance(_heli:getPoint(), _woundedGroup[1]:getPoint())

            table.insert(_csarList, { dist = _distance, msg = string.format("%s at %s - %.2f KHz ADF - %.3fKM ", _value.desc, _coordinatesText, _value.frequency / 1000, _distance / 1000.0) })
        end
    end

    local function sortDistance(a, b)
        return a.dist < b.dist
    end

    table.sort(_csarList, sortDistance)

    for _, _line in pairs(_csarList) do
        _msg = _msg .. "\n" .. _line.msg
    end

    csar.displayMessageToSAR(_heli, _msg, 20)
end


function csar.getClosetDownedPilot(_heli)

    local _side = _heli:getCoalition()

    local _closetGroup = nil
    local _shortestDistance = -1
    local _distance = 0
    local _closetGroupInfo = nil

    for _woundedName, _groupInfo in pairs(csar.woundedGroups) do

        local _tempWounded = csar.getWoundedGroup(_woundedName)

        -- check group exists and not moving to someone else
        if #_tempWounded > 0 and (_tempWounded[1]:getCoalition() == _side) then

            _distance = csar.getDistance(_heli:getPoint(), _tempWounded[1]:getPoint())

            if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then


                _shortestDistance = _distance
                _closetGroup = _tempWounded[1]
                _closetGroupInfo = _groupInfo
            end
        end
    end

    return { pilot = _closetGroup, distance = _shortestDistance, groupInfo = _closetGroupInfo }
end

function csar.signalFlare(_unitName)

    local _heli = csar.getSARHeli(_unitName)

    if _heli == nil then
        return
    end

    local _closet = csar.getClosetDownedPilot(_heli)

    if _closet ~= nil and _closet.pilot ~= nil and _closet.distance < 8000.0 then

        local _clockDir = csar.getClockDirection(_heli, _closet.pilot)

        local _msg = string.format("%s - %.2f KHz ADF - %.3fM - Popping Signal Flare at your %s ", _closet.groupInfo.desc, _closet.groupInfo.frequency / 1000, _closet.distance, _clockDir)
        csar.displayMessageToSAR(_heli, _msg, 20)

        trigger.action.signalFlare(_closet.pilot:getPoint(), 1, 0)
    else
        csar.displayMessageToSAR(_heli, "No Pilots within 8KM", 20)
    end
end

function csar.displayToAllSAR(_message, _side, _ignore)

    for _, _unitName in pairs(csar.csarUnits) do

        local _unit = csar.getSARHeli(_unitName)

        if _unit ~= nil and _unit:getCoalition() == _side then

            if _ignore == nil or _ignore ~= _unitName then
                csar.displayMessageToSAR(_unit, _message, 10)
            end
        else
            -- env.info(string.format("unit nil %s",_unitName))
        end
    end
end

function csar.getClosetMASH(_heli)

    local _mashes = csar.bluemash

    if (_heli:getCoalition() == 1) then
        _mashes = csar.redmash
    end

    local _shortestDistance = -1
    local _distance = 0

    for _, _mashName in pairs(_mashes) do

        local _mashUnit = Unit.getByName(_mashName)

        if _mashUnit ~= nil and _mashUnit:isActive() and _mashUnit:getLife() > 0 then

            _distance = csar.getDistance(_heli:getPoint(), _mashUnit:getPoint())

            if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then

                _shortestDistance = _distance
            end
        end
    end

    if _shortestDistance ~= -1 then
        return _shortestDistance
    else
        return -1
    end
end

function csar.checkOnboard(_unitName)
    local _unit = csar.getSARHeli(_unitName)

    if _unit == nil then
        return
    end

    --list onboard pilots

    local _inTransit = csar.inTransitGroups[_unitName]

    if _inTransit == nil or csar.tableLength(_inTransit) == 0 then
        csar.displayMessageToSAR(_unit, "No Rescued Pilots onboard", 30)
    else

        local _text = "Onboard - RTB to FARP/Airfield or MASH: "

        for _, _onboard in pairs(csar.inTransitGroups[_unitName]) do
            _text = _text .. "\n" .. _onboard.desc
        end

        csar.displayMessageToSAR(_unit, _text, 30)
    end
end


-- Adds menuitem to all medevac units that are active
function csar.addMedevacMenuItem()
    -- Loop through all Medevac units

    timer.scheduleFunction(csar.addMedevacMenuItem, nil, timer.getTime() + 5)

    for _, _unitName in pairs(csar.csarUnits) do

        local _unit = csar.getSARHeli(_unitName)

        if _unit ~= nil then

            local _groupId = csar.getGroupId(_unit)

            if _groupId then

                if csar.addedTo[tostring(_groupId)] == nil then

                    csar.addedTo[tostring(_groupId)] = true

                    local _rootPath = missionCommands.addSubMenuForGroup(_groupId, "CSAR")

                    missionCommands.addCommandForGroup(_groupId, "List Active CSAR", _rootPath, csar.displayActiveSAR,
                        _unitName)

                    missionCommands.addCommandForGroup(_groupId, "Check Onboard", _rootPath, csar.checkOnboard, _unitName)

                    missionCommands.addCommandForGroup(_groupId, "Request Signal Flare", _rootPath, csar.signalFlare, _unitName)
                end
            end
        else
            -- env.info(string.format("unit nil %s",_unitName))
        end
    end

    return
end

--get distance in meters assuming a Flat world
function csar.getDistance(_point1, _point2)

    local xUnit = _point1.x
    local yUnit = _point1.z
    local xZone = _point2.x
    local yZone = _point2.z

    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone

    return math.sqrt(xDiff * xDiff + yDiff * yDiff)
end

-- 200 - 400 in 10KHz
-- 400 - 850 in 10 KHz
-- 850 - 1250 in 50 KHz
function csar.generateVHFrequencies()

    --ignore list
    --list of all frequencies in KHZ that could conflict with
    -- 191 - 1290 KHz, beacon range
    local _skipFrequencies = {
        745, --Astrahan
        381,
        384,
        300.50,
        312.5,
        1175,
        342,
        735,
        300.50,
        353.00,
        440,
        795,
        525,
        520,
        690,
        625,
        291.5,
        300.50,
        435,
        309.50,
        920,
        1065,
        274,
        312.50,
        580,
        602,
        297.50,
        750,
        485,
        950,
        214,
        1025, 730, 995, 455, 307, 670, 329, 395, 770,
        380, 705, 300.5, 507, 740, 1030, 515,
        330, 309.5,
        348, 462, 905, 352, 1210, 942, 435,
        324,
        320, 420, 311, 389, 396, 862, 680, 297.5,
        920, 662,
        866, 907, 309.5, 822, 515, 470, 342, 1182, 309.5, 720, 528,
        337, 312.5, 830, 740, 309.5, 641, 312, 722, 682, 1050,
        1116, 935, 1000, 430, 577
    }

    csar.freeVHFFrequencies = {}
    csar.usedVHFFrequencies = {}

    local _start = 200000

    -- first range
    while _start < 400000 do

        -- skip existing NDB frequencies
        local _found = false
        for _, value in pairs(_skipFrequencies) do
            if value * 1000 == _start then
                _found = true
                break
            end
        end


        if _found == false then
            table.insert(csar.freeVHFFrequencies, _start)
        end

        _start = _start + 10000
    end

    _start = 400000
    -- second range
    while _start < 850000 do

        -- skip existing NDB frequencies
        local _found = false
        for _, value in pairs(_skipFrequencies) do
            if value * 1000 == _start then
                _found = true
                break
            end
        end

        if _found == false then
            table.insert(csar.freeVHFFrequencies, _start)
        end

        _start = _start + 10000
    end

    _start = 850000
    -- third range
    while _start <= 1250000 do

        -- skip existing NDB frequencies
        local _found = false
        for _, value in pairs(_skipFrequencies) do
            if value * 1000 == _start then
                _found = true
                break
            end
        end

        if _found == false then
            table.insert(csar.freeVHFFrequencies, _start)
        end

        _start = _start + 50000
    end
end

function csar.generateADFFrequency()

    if #csar.freeVHFFrequencies <= 3 then
        csar.freeVHFFrequencies = csar.usedVHFFrequencies
        csar.usedVHFFrequencies = {}
    end

    local _vhf = table.remove(csar.freeVHFFrequencies, math.random(#csar.freeVHFFrequencies))

    return _vhf
    --- return {uhf=_uhf,vhf=_vhf}
end

function csar.inAir(_heli)

    if _heli:inAir() == false then
        return false
    end

    -- less than 5 cm/s a second so landed
    -- BUT AI can hold a perfect hover so ignore AI
    if mist.vec.mag(_heli:getVelocity()) < 0.05 and _heli:getPlayerName() ~= nil then
        return false
    end
    return true
end

function csar.getClockDirection(_heli, _crate)

    -- Source: Helicopter Script - Thanks!

    local _position = _crate:getPosition().p -- get position of crate
    local _playerPosition = _heli:getPosition().p -- get position of helicopter
    local _relativePosition = mist.vec.sub(_position, _playerPosition)

    local _playerHeading = mist.getHeading(_heli) -- the rest of the code determines the 'o'clock' bearing of the missile relative to the helicopter

    local _headingVector = { x = math.cos(_playerHeading), y = 0, z = math.sin(_playerHeading) }

    local _headingVectorPerpendicular = { x = math.cos(_playerHeading + math.pi / 2), y = 0, z = math.sin(_playerHeading + math.pi / 2) }

    local _forwardDistance = mist.vec.dp(_relativePosition, _headingVector)

    local _rightDistance = mist.vec.dp(_relativePosition, _headingVectorPerpendicular)

    local _angle = math.atan2(_rightDistance, _forwardDistance) * 180 / math.pi

    if _angle < 0 then
        _angle = 360 + _angle
    end
    _angle = math.floor(_angle * 12 / 360 + 0.5)
    if _angle == 0 then
        _angle = 12
    end

    return _angle
end

function csar.getGroupId(_unit)

    local _unitDB = mist.DBs.unitsById[tonumber(_unit:getID())]
    if _unitDB ~= nil and _unitDB.groupId then
        return _unitDB.groupId
    end

    return nil
end

csar.generateVHFrequencies()

-- Schedule timer to add radio item
timer.scheduleFunction(csar.addMedevacMenuItem, nil, timer.getTime() + 5)

if csar.disableAircraftTimeout then
    -- Schedule timer to reactivate things
    timer.scheduleFunction(csar.reactivateAircraft, nil, timer.getTime() + 5)
end

world.addEventHandler(csar.eventHandler)

env.info("CSAR event handler added")

--save CSAR MODE
trigger.action.setUserFlag("CSAR_MODE", csar.csarMode)

-- disable aircraft
if csar.enableSlotBlocking then

    trigger.action.setUserFlag("CSAR_SLOTBLOCK", 100)

    env.info("CSAR Slot block enabled")
end
