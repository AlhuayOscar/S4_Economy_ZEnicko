S4_AirdropData = S4_AirdropData or {}

S4_AirdropData.Weapon = {
    Chance1 = 2, -- How many times will you draw from list 1? / List can be up to 10
    List1 = { -- List 1 / Randomly paid according to the chance from the list
        "Base.Pistol",
        "Base.Pistol2",
        "Base.Pistol3",
        "Base.Revolver",
        "Base.Revolver_Short",
        "Base.Revolver_Long",
        "Base.ShotgunSawnoff",
        "Base.DoubleBarrelShotgun",
        "Base.DoubleBarrelShotgunSawnoff",
        "Base.AssaultRifle",
        "Base.AssaultRifle2",
        "Base.HuntingRifle",
    },
    Chance2 = 1,
    List2 = {
        "Base.KnifeButterfly",
        "Base.FightingKnife",
        "Base.HandguardDagger",
        "Base.HuntingKnifeForged",
        "Base.LongMace",
        "Base.LongSpikedClub",
        "Base.LongMace_Stone",
        "Base.Mace",
        "Base.ShortBat",
        "Base.SpikedShortBat",
        "Base.ShortSword",
        "Base.CrudeShortSword",
        "Base.CrudeSword",
        "Base.SpearLong",
        "Base.SpearShort",
        "Base.Mace_Stone",
        "Base.SwitchKnife",
        "Base.Sword",
        "Base.HuntingKnife",
        "Base.Nightstick",
        "Base.Katana",
    },
    Chance3 = 10,
    List3 = {
        "Base.223Box",
        "Base.308Box",
        "Base.Bullets38Box",
        "Base.Bullets44Box",
        "Base.Bullets45Box",
        "Base.556Box",
        "Base.Bullets9mmBox",
        "Base.ShotgunShellsBox",
    },
}
S4_AirdropData.Ammo = {
    Chance1 = 1,
    List1 = {
        "Base.223Carton",
        "Base.308Carton",
        "Base.Bullets38Carton",
        "Base.Bullets44Carton",
        "Base.Bullets45Carton",
        "Base.556Carton",
        "Base.Bullets9mmCarton",
        "Base.ShotgunShellsCarton",
    },
    Chance2 = 20,
    List2 = {
        "Base.223Box",
        "Base.308Box",
        "Base.Bullets38Box",
        "Base.Bullets44Box",
        "Base.Bullets45Box",
        "Base.556Box",
        "Base.Bullets9mmBox",
        "Base.ShotgunShellsBox",
    },
    Chance3 = 10,
    List3 = {
        "Base.M14Clip",
        "Base.44Clip",
        "Base.45Clip",
        "Base.556Clip",
        "Base.9mmClip",
    },
}
S4_AirdropData.Food = {
    Chance1 = 1,
    List1 = {
        "Base.TinnedBeans_Box",
        "Base.CannedCarrots_Box",
        "Base.CannedChili_Box",
        "Base.CannedCorn_Box",
        "Base.CannedCornedBeef_Box",
        "Base.CannedMilk_Box",
        "Base.CannedFruitBeverage_Box",
        "Base.CannedFruitCocktail_Box",
        "Base.CannedMushroomSoup_Box",
        "Base.CannedPeaches_Box",
        "Base.CannedPeas_Box",
        "Base.CannedPineapple_Box",
        "Base.CannedPotato_Box",
        "Base.CannedSardines_Box",
        "Base.CannedBolognese_Box",
        "Base.CannedTomato_Box",
        "Base.TunaTin_Box",
        "Base.TinnedSoup_Box",
        "Base.Macandcheese_Box",
        "Base.WineRed_Boxed",
        "Base.WineWhite_Boxed",
        -- "Base.Chocolate_HeartBox",
    },
    Chance2 = 5,
    List2 = {
        "Base.WaterRationCan_Box",
    },
    Chance3 = 5,
    List3 = {
        "Base.Dogfood_Box",
        "Base.MysteryCan_Box", -- unknown can
        "Base.MysteryCan_Box", -- unknown can
        "Base.DentedCan_Box", -- rotten can
        "Base.MysteryCan_Box", -- unknown can
    },
    Chance4 = 1,
    List4 = {
        "Base.BottleOpener",
        "Base.BottleOpener_Keychain",
        "Base.TinOpene",
        "Base.TinOpener_Old",
    },
}
S4_AirdropData.Medical = {
    Chance1 = 2,
    List1 = {
        "Base.AdhesiveBandageBox", -- adhesive plaster
        "Base.AntibioticsBox", -- antibiotics
        "Base.BandageBox", -- bandage
        -- "Base.ColdpackBox", -- Ice pack (not implemented?)
        "Base.CottonBallsBox", -- cotton ball
        "Base.SutureNeedleBox", -- suture needle
        -- "Base.TissueBox", -- tissue
        -- "Base.TongueDepressorBox", -- Tongue depressor bar (crap)
    },
    Chance2 = 5,
    List2 = {
        "Base.PillsBeta", -- relaxant
        "Base.PillsVitamins", -- vitamin
        "Base.Disinfectant", -- disinfectant
        "Base.PillsSleepingTablets", -- sleeping pills
        "Base.Pills", -- analgesic
        "Base.PillsAntiDep", -- antidepressants
    },
    Chance3 = 6,
    List3 = {
        "Base.Gloves_Surgical", -- medical gloves
        "Base.Hat_SurgicalCap", -- medical hat
        "Base.Hat_SurgicalMask", -- medical mask
        "Base.AlcoholWipes", -- alcohol swab
    },
    Chance4 = 1,
    List4 = {
        "Base.Tweezers", -- pincette
        "Base.Tweezers_Forged", -- tongs
        "Base.Forceps_Forged", -- tongs?
        "Base.ScissorsBluntMedical", -- medical scissors
        "Base.Stethoscope", -- stethoscope
        "Base.SutureNeedleHolder", -- suture forceps
        "Base.Splint", -- splint
    },
}
S4_AirdropData.Materials = {
    Chance1 = 2,
    List1 = {
        "Base.AdhesiveTapeBox", -- tape 12
        "Base.DuctTapeBox", -- duct tape 12
        "Base.NailsCarton", -- nail box 12
        "Base.ScrewsCarton", -- Screw box 12
    },
    Chance2 = 10,
    List2 = {
        "Base.LogStacks4", -- log 4
        "Base.LogStacks3", -- log 3
        "Base.LogStacks2", -- log 2
        "Base.log", -- log 1
    },
    Chance3 = 4,
    List3 = {
        "Base.PlasterPowder", -- plaster bag
        "Base.ConcretePowder", -- concrete sack
    },
    Chance4 = 15,
    List4 = {
        "Base.Glue", -- wood glue
        "Base.NailsBox", -- pond
        "Base.ScrewsBox", -- screw
        "Base.Twine", -- string
        "Base.Thread", -- line
        "Base.PropaneTank", -- propane tank
        "Base.Clay", -- clay
        "Base.LargeStone", -- big stone
        "Base.Rope", -- rope
    },
}
S4_AirdropData.Etc = {
    Chance1 = 1,
    List1 = {
        "Base.BookAimingSet", -- 
        "Base.BookHusbandrySet", -- 
        "Base.BookButcheringSet", -- 
        "Base.BookCarpentrySet", -- 
        "Base.BookCarvingSet", -- 
        "Base.BookCookingSet", -- 
        "Base.BookElectricianSet", -- 
        "Base.BookFarmingSet", -- 
        "Base.BookFirstAidSet", -- 
        "Base.BookFishingSet", -- 
        "Base.BookForagingSet", -- 
        "Base.BookGlassmakingSet", -- 
        "Base.BookFlintKnappingSet", -- 
        "Base.BookLongBladeSet", -- 
        "Base.BookMaintenanceSet", -- 
        "Base.BookMasonrySet", -- 
        "Base.BookMechanicsSet", -- 
        "Base.BookBlacksmithSet", -- 
        "Base.BookPotterySet", -- 
    },
    Chance2 = 10,
    List2 = {
        "Base.Book_Childs",
        "Base.Book_CrimeFiction",
        "Base.Book_Travel",
        "Base.Book_Religion",
        "Base.Book_Baseball",
        "Base.Book_Thriller",
        "Base.Book_GeneralNonFiction",
        "Base.HollowBook_Valuables",
        "Base.Book_Horror",
        "Base.Book_Art",
        "Base.Book_Fiction",
        "Base.HollowBook_Kids",
        "Base.Book_AdventureNonFiction",
        "Base.Book_GeneralReference",
        "Base.Book_Rich",
        "Base.Book_Quackery",
        "Base.Book_Cinema",
        "Base.Book_SadNonFiction",
        "Base.Book_Golf",
        "Base.Book_Military",
        "Base.Book_Fashion",
        "Base.Book_Biography",
        "Base.Book_Farming",
        "Base.Book_ClassicFiction",
        "Base.Book_Western",
        "Base.Book_Medical",
        "Base.Book_ClassicNonfiction",
        "Base.Book_Legal",
        "Base.Book_Romance",
        "Base.Book_Policing",
        "Base.HollowBook_Whiskey",
        "Base.Book_Business",
        "Base.Book_Nature",
        "Base.Book_Computer",
        "Base.Book_SchoolTextbook",
        "Base.Book_Sports",
        "Base.Book_Occult",
        "Base.Book_Music",
        "Base.HollowBook",
        "Base.Book_History",
        "Base.Book_Fantasy",
        "Base.HollowBook_Prison",
        "Base.Book_Philosophy",
        "Base.HollowBook_Handgun",
        "Base.Book_Classic",
        "Base.Book_Politics",
        "Base.Book_Science",
        "Base.Book_LiteraryFiction",
        "Base.Book_MilitaryHistory",
        "Base.Book_SciFi",
        "Base.Book_Bible",
        "Base.Catalog",
        "Base.ComicBook_Retail",
        "Base.BookFancy_Classic",
        "Base.BookFancy_Occult",
        "Base.BookFancy_Philosophy",
        "Base.HollowFancyBook",
        "Base.BookFancy_Religion",
        "Base.BookFancy_Legal",
        "Base.BookFancy_History",
        "Base.BookFancy_Politics",
        "Base.BookFancy_MilitaryHistory",
        "Base.BookFancy_Medical",
        "Base.BookFancy_ClassicNonfiction",
        "Base.BookFancy_ClassicFiction",
        "Base.BookFancy_Bible",
        "Base.Magazine_Art",
        "Base.Magazine_Health",
        "Base.Magazine_Hobby_New",
        "Base.Magazine_Military_New",
        "Base.Magazine_Tech",
        "Base.MagazineCrossword",
        "Base.Magazine_Police_New",
        "Base.Magazine_New",
        "Base.Magazine_Fashion",
        "Base.Magazine_Fashion_New",
        "Base.Magazine_Rich_New",
        "Base.Magazine_Humor",
        "Base.Magazine_Horror_New",
        "Base.Magazine_Golf",
        "Base.Magazine_Golf_New",
        "Base.Magazine_Hobby",
        "Base.Magazine_Tech_New",
        "Base.Magazine_Sports_New",
        "Base.Magazine_Horror",
        "Base.Magazine_Cinema_New",
        "Base.HunkZ",
        "Base.Magazine_Military",
        "Base.Magazine_Popular",
        "Base.Magazine_Business_New",
        "Base.Magazine_Humor_New",
        "Base.Magazine_Outdoors",
        "Base.Magazine_Rich",
        "Base.Magazine_Teens",
        "Base.Magazine_Car_New",
        "Base.Magazine_Music",
        "Base.Magazine_Car",
        "Base.Magazine_Cinema",
        "Base.Magazine_Popular_New",
        "Base.Magazine_Science_New",
        "Base.Magazine_Science",
        "Base.Magazine_Sports",
        "Base.Magazine_Gaming",
        "Base.Magazine_Gaming_New",
        "Base.Magazine_Childs",
        "Base.Magazine_Childs_New",
        "Base.Magazine_Art_New",
        "Base.Magazine_Police",
        "Base.Magazine_Teens_New",
        "Base.Magazine_Firearm",
        "Base.Magazine_Firearm_New",
        "Base.Magazine_Crime",
        "Base.Magazine_Outdoors_New",
        "Base.Magazine_Crime_New",
        "Base.TVMagazine_New",
        "Base.Magazine_Health_New",
        "Base.MagazineWordsearch",
        "Base.Magazine_Music_New",
        "Base.Magazine_Business",
        "Base.TVMagazine",
        "Base.Magazine",
        "Base.HottieZ",
        "Base.HottieZ_New",
    },
}

-------------------------------------------------------
------------- The operation below is not guaranteed if touched -------------
-------------------------------------------------------
S4_AirdropData.AreaType = { -- supply area
    "Muldraugh", -- Muldrow
    "WestPoint", -- west point
    "Rosewood", -- rosewood
    "Riverside", -- riverside
    "Brandenburg", -- Brendan Berg
    "Ekron", -- Akron
    "Irvington", -- Irvington
    "MarchRidge", -- March Ridge
    -- "DoeValley", -- Doe Valley
    "FallasLake", -- Doe Valley, Paula's Lake
    "EchoCreek", -- Doe Valley, Echo Creek
    "Louisville", -- louisville
}

S4_AirdropData.DropType = { -- Type of supplies
    "Weapon",
    "Ammo",
    "Food",
    "Medical",
    "Materials",
    "Book",
    -- "Etc",
}

S4_AirdropData.Muldraugh = { -- Muldrow: 23
    {MinX = 11541, MinY = 9641, MaxX = 9590, MaxY = 9787}, -- train depot 1
    {MinX = 11609, MinY = 9970, MaxX = 11654, MaxY = 10199}, -- train depot 2
    {MinX = 11498, MinY = 10036, MaxX = 11572, MaxY = 10065}, -- train depot 3
    {MinX = 11646, MinY = 9590, MaxX = 11749, MaxY = 9793}, -- train depot 4
    {MinX = 11820, MinY = 9734, MaxX = 11870, MaxY = 9762}, -- Warehouse 5 next to the train depot
    {MinX = 11845, MinY = 9777, MaxX = 11876, MaxY = 9809}, -- Warehouse 6 next to the train depot
    {MinX = 11071, MinY = 10624, MaxX = 11090, MaxY = 10670}, -- cabin in the woods 7
    {MinX = 10649, MinY = 10503, MaxX = 10708, MaxY = 10578}, -- Muldrow Ranch 8
    {MinX = 10743, MinY = 10462, MaxX = 10782, MaxY = 10526}, -- Muldrow Vacant Lot 9
    {MinX = 10649, MinY = 10409, MaxX = 10673, MaxY = 10431}, -- Muldrow Police Station Parking Lot 10
    {MinX = 10688, MinY = 10323, MaxX = 10718, MaxY = 10351}, -- Muldrow Office Parking Lot 11
    {MinX = 10786, MinY = 10312, MaxX = 10859, MaxY = 10398}, -- Muldrow Vacant Lot 12
    {MinX = 10433, MinY = 10048, MaxX = 10460, MaxY = 10093}, -- Muldrow Cornfield 13
    {MinX = 10901, MinY = 9872, MaxX = 10966, MaxY = 9953}, -- Muldrow Baseball Stadium Vacant Lot 14
    {MinX = 10644, MinY = 9948, MaxX = 10674, MaxY = 10023}, -- Muldrow Basketball/Soccer Field 15
    {MinX = 10822, MinY = 9611, MaxX = 10868, MaxY = 9694}, -- Muldrow construction site vacant lot 16
    {MinX = 10729, MinY = 9572, MaxX = 10762, MaxY = 9598}, -- Muldrow Vacant Lot 17
    {MinX = 10724, MinY = 9348, MaxX = 10817, MaxY = 9405}, -- Muldrow Vacant Lot 18
    {MinX = 10050, MinY = 9551, MaxX = 10106, MaxY = 9637}, -- Muldrow Construction Site 19
    {MinX = 10117, MinY = 9534, MaxX = 10166, MaxY = 9565}, -- Muldrow Construction Site 20
    {MinX = 10336, MinY = 9631, MaxX = 10376, MaxY = 9678}, -- Muldrow Lumberyard 21
    {MinX = 11079, MinY = 9178, MaxX = 11100, MaxY = 9219}, -- Muldrow Railway Station 22
    {MinX = 10781, MinY = 9118, MaxX = 10862, MaxY = 9188}, -- Muldrow Ranch 23
    {MinX = 11744, MinY = 8930, MaxX = 11209, MaxY = 8965}, -- Muldrow Ranch 23
}

S4_AirdropData.WestPoint = { -- West Point: 11
    {MinX = 10800, MinY = 6612, MaxX = 10870, MaxY = 6756}, -- vacant lot 1
    {MinX = 10901, MinY = 6658, MaxX = 11266, MaxY = 6703}, -- vacant lot 2
    {MinX = 11109, MinY = 6765, MaxX = 11266, MaxY = 6847}, -- vacant lot 3
    {MinX = 10882, MinY = 6770, MaxX = 11089, MaxY = 6882}, -- vacant lot 4
    {MinX = 11925, MinY = 6630, MaxX = 12080, MaxY = 6726}, -- vacant lot 5
    {MinX = 11800, MinY = 6935, MaxX = 11841, MaxY = 6957}, -- Vacant lot next to parking lot 6
    {MinX = 11590, MinY = 6784, MaxX = 11626, MaxY = 6803}, -- Vacant lot next to residential area 7
    {MinX = 11787, MinY = 6712, MaxX = 11812, MaxY = 6765}, -- Vacant lot next to residential area 8
    {MinX = 12065, MinY = 6914, MaxX = 12096, MaxY = 6951}, -- Construction site vacant lot 9
    {MinX = 12052, MinY = 6842, MaxX = 12100, MaxY = 6885}, -- Mega Mart parking lot 10
    {MinX = 12075, MinY = 6752, MaxX = 12132, MaxY = 6833}, -- Vacant lot next to gun shop 11
}

S4_AirdropData.Rosewood = { -- Rosewood: 9
    {MinX = 7950, MinY = 11788, MaxX = 8196, MaxY = 11885}, -- vacant lot 1
    {MinX = 8207, MinY = 11838, MaxX = 8258, MaxY = 11887}, -- Sawmill vacant lot 2
    {MinX = 8390, MinY = 12192, MaxX = 8461, MaxY = 12287}, -- drive-in movie theater parking lot 3
    {MinX = 8030, MinY = 11588, MaxX = 8056, MaxY = 11626}, -- Commercial parking lot 4
    {MinX = 8123, MinY = 11756, MaxX = 8156, MaxY = 11770}, -- Fire station parking lot 5
    {MinX = 8326, MinY = 11634, MaxX = 8382, MaxY = 11672}, -- school playground 6
    {MinX = 8133, MinY = 11551, MaxX = 8174, MaxY = 11566}, -- Church parking lot 7
    {MinX = 8123, MinY = 11413, MaxX = 8160, MaxY = 11461}, -- Mega Mart parking lot 8
    {MinX = 7944, MinY = 12215, MaxX = 8071, MaxY = 12322}, -- vacant lot 9
}

S4_AirdropData.Riverside = { -- Riverside: 8
    {MinX = 5797, MinY = 5390, MaxX = 5860, MaxY = 5438}, -- junkyard 1
    {MinX = 6425, MinY = 5314, MaxX = 6484, MaxY = 5348}, -- parking lot 2
    {MinX = 6538, MinY = 5445, MaxX = 6561, MaxY = 5460}, -- road 3
    {MinX = 6319, MinY = 5207, MaxX = 6339, MaxY = 5233}, -- parking lot 4
    {MinX = 7364, MinY = 5942, MaxX = 7417, MaxY = 6170}, -- vacant lot 5
    {MinX = 5730, MinY = 6576, MaxX = 5796, MaxY = 6639}, -- parking lot 6
    {MinX = 5595, MinY = 5922, MaxX = 5628, MaxY = 5953}, -- Factory vacant lot 7
    {MinX = 5332, MinY = 5398, MaxX = 5380, MaxY = 5486}, -- field 8
}

S4_AirdropData.Brandenburg = { -- Brendan Berg: 12
    {MinX = 1976, MinY = 6242, MaxX = 2049, MaxY = 6337}, -- vacant lot 1
    {MinX = 2050, MinY = 6487, MaxX = 2092, MaxY = 6522}, -- parking lot 2
    {MinX = 2112, MinY = 6497, MaxX = 2147, MaxY = 6546}, -- parking lot 3
    {MinX = 2108, MinY = 6120, MaxX = 2164, MaxY = 6176}, -- baseball field 4
    {MinX = 1852, MinY = 5851, MaxX = 1893, MaxY = 5864}, -- tennis court 5
    {MinX = 1818, MinY = 5966, MaxX = 1880, MaxY = 5991}, -- Sports Complex Parking Lot 6
    {MinX = 1975, MinY = 6136, MaxX = 2061, MaxY = 6171}, -- soccer field 7
    {MinX = 1428, MinY = 5850, MaxX = 1451, MaxY = 5910}, -- Prison parking lot 8
    {MinX = 1374, MinY = 5886, MaxX = 1403, MaxY = 5908}, -- Prison Playground 9
    {MinX = 1324, MinY = 5810, MaxX = 1347, MaxY = 5938}, -- Prison vacant lot 10
    {MinX = 950, MinY = 6174, MaxX = 1020, MaxY = 6730}, -- airport runway 11
    {MinX = 1996, MinY = 6894, MaxX = 2188, MaxY = 7370}, -- vacant lot 12
}

S4_AirdropData.Ekron = { -- Ecknok: 10
    {MinX = 737, MinY = 9867, MaxX = 794, MaxY = 9887}, -- school parking lot 1
    {MinX = 544, MinY = 9681, MaxX = 549, MaxY = 9830}, -- railroad 2
    {MinX = 472, MinY = 9905, MaxX = 493, MaxY = 10000}, -- Church parking lot 3
    {MinX = 332, MinY = 9842, MaxX = 346, MaxY = 9853}, -- dumpster 4
    {MinX = 712, MinY = 9817, MaxX = 723, MaxY = 9835}, -- basketball court 5
    {MinX = 459, MinY = 9813, MaxX = 479, MaxY = 9861}, -- parking lot 6
    {MinX = 865, MinY = 9493, MaxX = 1048, MaxY = 9563}, -- field 7
    {MinX = 306, MinY = 9267, MaxX = 413, MaxY = 9435}, -- field 8
    {MinX = 2443, MinY = 10949, MaxX = 2541, MaxY = 11227}, -- shooting range 9
    {MinX = 21, MinY = 9743, MaxX = 199, MaxY = 9882}, -- field 10
}

S4_AirdropData.Irvington = { -- Irvington: 10
    {MinX = 1823, MinY = 14051, MaxX = 1880, MaxY = 14108}, -- shooting range 1
    {MinX = 2301, MinY = 14303, MaxX = 2392, MaxY = 14338}, -- soccer field 2
    {MinX = 2058, MinY = 14596, MaxX = 2083, MaxY = 14641}, -- construction site 3
    {MinX = 2027, MinY = 14035, MaxX = 2087, MaxY = 14095}, -- baseball field 4
    {MinX = 3750, MinY = 14696, MaxX = 3765, MaxY = 14753}, -- Slaughter factory vacant lot 5
    {MinX = 3060, MinY = 14525, MaxX = 3093, MaxY = 14580}, -- Construction site vacant lot 6
    {MinX = 1812, MinY = 14795, MaxX = 1869, MaxY = 14829}, -- Mart parking lot 7
    {MinX = 1092, MinY = 14139, MaxX = 1194, MaxY = 14381}, -- field 8
    {MinX = 3518, MinY = 14939, MaxX = 3813, MaxY = 15055}, -- field 9
    {MinX = 1834, MinY = 15045, MaxX = 1973, MaxY = 15124}, -- field 10
}

S4_AirdropData.MarchRidge = { -- March Ridge: 8
    {MinX = 9830, MinY = 12620, MaxX = 9840, MaxY = 12850}, -- Residential parking lot 1
    {MinX = 9830, MinY = 12950, MaxX = 9840, MaxY = 13120}, -- Residential parking lot 2
    {MinX = 9760, MinY = 12500, MaxX = 9810, MaxY = 13200}, -- outer road 3
    {MinX = 10050, MinY = 12830, MaxX = 10520, MaxY = 13200}, -- Outside vacant lot 4
    {MinX = 10300, MinY = 12739, MaxX = 10370, MaxY = 12779}, -- Church parking lot 5
    {MinX = 10020, MinY = 12754, MaxX = 10066, MaxY = 12820}, -- school parking lot 6
    {MinX = 10077, MinY = 12640, MaxX = 10158, MaxY = 12700}, -- Apartment(?) parking lot 7
    {MinX = 9950, MinY = 12589, MaxX = 10014, MaxY = 12640}, -- Vacant lot in front of bunker 8
}

S4_AirdropData.FallasLake = { -- Polars Lake: 9
    {MinX = 7357, MinY = 8379, MaxX = 7393, MaxY = 8398}, -- Church parking lot 1
    {MinX = 7229, MinY = 8231, MaxX = 7240, MaxY = 8305}, -- Commercial parking lot 2
    {MinX = 7226, MinY = 8181, MaxX = 7250, MaxY = 8196}, -- Restaurant parking lot 3
    {MinX = 7288, MinY = 8573, MaxX = 7658, MaxY = 9318}, -- field 4
    {MinX = 6187, MinY = 9493, MaxX = 6346, MaxY = 9869}, -- field 5
    {MinX = 6544, MinY = 8950, MaxX = 6584, MaxY = 8975}, -- Parking lot in front of warehouse 6
    {MinX = 6760, MinY = 7024, MaxX = 6939, MaxY = 7161}, -- field 7
    {MinX = 8504, MinY = 8799, MaxX = 8558, MaxY = 8879}, -- field 8
    {MinX = 5439, MinY = 9649, MaxX = 5463, MaxY = 9672}, -- Repair shop parking lot 9
}

S4_AirdropData.EchoCreek = { -- Echo Creek: 8
    {MinX = 3668, MinY = 10904, MaxX = 3719, MaxY = 10917}, -- vehicle repair shop 1
    {MinX = 3473, MinY = 10994, MaxX = 3509, MaxY = 11023}, -- vacant lot 2
    {MinX = 3569, MinY = 10992, MaxX = 3594, MaxY = 11078}, -- vacant lot 3
    {MinX = 3536, MinY = 11185, MaxX = 3556, MaxY = 11195}, -- Church parking lot 4
    {MinX = 3815, MinY = 11109, MaxX = 3890, MaxY = 11250}, -- field 5
    {MinX = 3074, MinY = 9905, MaxX = 3591, MaxY = 10087}, -- field 6
    {MinX = 4295, MinY = 9731, MaxX = 4318, MaxY = 9758}, -- Gardening Mall 7
    {MinX = 3768, MinY = 12142, MaxX = 3837, MaxY = 12230}, -- field 8
}

S4_AirdropData.Louisville = { -- Louisville: 21
    {MinX = 13672, MinY = 5733, MaxX = 13865, MaxY = 5959}, -- Crossroads Mall 1
    {MinX = 12317, MinY = 3651, MaxX = 12351, MaxY = 3696}, -- hospital parking lot 2
    {MinX = 12581, MinY = 3607, MaxX = 12597, MaxY = 3621}, -- Factory complex parking lot 3
    {MinX = 12795, MinY = 3730, MaxX = 12845, MaxY = 3782}, -- Residential vacant lot 4
    {MinX = 15181, MinY = 3970, MaxX = 15289, MaxY = 4032}, -- Barbed wire vacant lot 5
    {MinX = 12665, MinY = 3056, MaxX = 12671, MaxY = 3380}, -- railway 6
    {MinX = 12136, MinY = 2699, MaxX = 12320, MaxY = 2827}, -- stadium 7
    {MinX = 12328, MinY = 2435, MaxX = 12426, MaxY = 2492}, -- rugby stadium 8
    {MinX = 13235, MinY = 2709, MaxX = 13250, MaxY = 2730}, -- park basketball court 9
    {MinX = 13336, MinY = 3088, MaxX = 13401, MaxY = 3100}, -- parking lot 10
    {MinX = 13480, MinY = 3307, MaxX = 13495, MaxY = 3343}, -- parking lot 11
    {MinX = 13686, MinY = 2533, MaxX = 13711, MaxY = 2566}, -- Church Backyard 12
    {MinX = 14185, MinY = 2857, MaxX = 14219, MaxY = 2893}, -- vacant lot 13
    {MinX = 13532, MinY = 2107, MaxX = 13547, MaxY = 2120}, -- parking lot 14
    {MinX = 13828, MinY = 1913, MaxX = 13858, MaxY = 2017}, -- parking lot 15
    {MinX = 12980, MinY = 1535, MaxX = 13065, MaxY = 1620}, -- baseball field 16
    {MinX = 12053, MinY = 1417, MaxX = 12059, MaxY = 1508}, -- factory 17
    {MinX = 13510, MinY = 1416, MaxX = 13773, MaxY = 1489}, -- Grand Mall 18
    {MinX = 12422, MinY = 1529, MaxX = 12448, MaxY = 1563}, -- Parking lot next to the police station 19
    {MinX = 15104, MinY = 2398, MaxX = 15199, MaxY = 3270}, -- airport runway 20
    {MinX = 15330, MinY = 2713, MaxX = 15605, MaxY = 2856}, -- Airport Berth 21

}