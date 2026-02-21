S4_Jobs_Lore = S4_Jobs_Lore or {}

S4_Jobs_Lore.MISSION_POINTS = {{
    x = 8065,
    y = 11652,
    z = 0,
    location = "Rosewood - Kentucky Court of Justice",
    missionName = "Court Record Purge",
    objective = "Eliminate targets and recover legal evidence",
    areaMinX = 8055,
    areaMaxX = 8075,
    areaMinY = 11642,
    areaMaxY = 11662,
    hiddenPadding = 14,
    zombieCount = 4
}, {
    x = 8123,
    y = 11550,
    z = 0,
    location = "Rosewood - Church",
    missionName = "Silent Sanctuary Sweep",
    objective = "Eliminate targets and take mission photos",
    areaMinX = 8114,
    areaMaxX = 8132,
    areaMinY = 11541,
    areaMaxY = 11559,
    hiddenPadding = 12,
    zombieCount = 3
}, {
    x = 8134,
    y = 11735,
    z = 0,
    location = "Rosewood - Fire Department",
    missionName = "Fireline Cleanup",
    objective = "Eliminate targets and recover legal evidence",
    areaMinX = 8123,
    areaMaxX = 8145,
    areaMinY = 11724,
    areaMaxY = 11746,
    hiddenPadding = 14,
    zombieCount = 5
}, {
    x = 8063,
    y = 11737,
    z = 0,
    location = "Rosewood - Police Station",
    missionName = "Blue Sector Breach",
    objective = "Eliminate targets and recover legal evidence",
    areaMinX = 8052,
    areaMaxX = 8074,
    areaMinY = 11726,
    areaMaxY = 11748,
    hiddenPadding = 14,
    zombieCount = 5
}, {
    x = 5687,
    y = 12472,
    z = 0,
    location = "Military Research Facility",
    missionName = "Black Lab Cleanup",
    objective = "Eliminate targets and recover legal evidence",
    areaMinX = 5673,
    areaMaxX = 5701,
    areaMinY = 12458,
    areaMaxY = 12486,
    hiddenPadding = 20,
    zombieCount = 9
}, {
    x = 8342,
    y = 11610,
    z = 0,
    location = "Rosewood - Elementary School",
    missionName = "Classroom Sweep",
    objective = "Eliminate targets and take mission photos",
    areaMinX = 8332,
    areaMaxX = 8352,
    areaMinY = 11600,
    areaMaxY = 11620,
    hiddenPadding = 14,
    zombieCount = 4
}, {
    x = 7718,
    y = 11881,
    z = 0,
    location = "Kentucky State Prison",
    missionName = "Iron Gate Lockdown",
    objective = "Eliminate targets and recover legal evidence",
    areaMinX = 7702,
    areaMaxX = 7734,
    areaMinY = 11865,
    areaMaxY = 11897,
    hiddenPadding = 18,
    zombieCount = 8
}, {
    x = 8242,
    y = 12231,
    z = 0,
    location = "Rosewood - Bus Station",
    missionName = "Terminal Intercept",
    objective = "Eliminate targets and take mission photos",
    areaMinX = 8230,
    areaMaxX = 8254,
    areaMinY = 12219,
    areaMaxY = 12243,
    hiddenPadding = 16,
    zombieCount = 6
}, {
    x = 8081,
    y = 11588,
    z = 0,
    location = "Rosewood - Knox Bank",
    missionName = "Rosewood - Knox bank 1: HEIST",
    objective = "Secure the bank area and drill the safe",
    areaMinX = 8077,
    areaMaxX = 8092,
    areaMinY = 11586,
    areaMaxY = 11602,
    hiddenPadding = 7,
    zombieCount = 6,
    missionMode = "drill_safe",
    missionGroup = "RosewoodKnoxBankHeist",
    missionPart = 1,
    missionPartTotal = 3,
    requiredItemType = "Base.MoneyBundle",
    requiredItemCount = 10,
    sourceAreaMinX = 8077,
    sourceAreaMaxX = 8092,
    sourceAreaMinY = 11586,
    sourceAreaMaxY = 11602,
    moneyDropX = 8091,
    moneyDropY = 11592,
    duffelSpawnX = 8078,
    duffelSpawnY = 11602,
    duffelSpawnZ = 0,
    requireMask = true,
    requireBulletVest = true,
    nonCompliantPenaltyPct = 50
}, {
    x = 8173,
    y = 11641,
    z = 0,
    location = "Rosewood - South Suburbs (Safe Houses)",
    missionName = "Rosewood - Knox bank 2: SAVE MONEY",
    objective = "Secure all dirty money obtained",
    areaMinX = 8116,
    areaMaxX = 8230,
    areaMinY = 11583,
    areaMaxY = 11700,
    hiddenPadding = 7,
    zombieCount = 0,
    missionMode = "stash_money",
    missionGroup = "RosewoodKnoxBankHeist",
    missionPart = 2,
    missionPartTotal = 3,
    requiredBag = "Duffelbag",
    requiredItemType = "Base.MoneyBundle",
    requiredItemCount = 10,
    sourceAreaMinX = 8077,
    sourceAreaMaxX = 8092,
    sourceAreaMinY = 11586,
    sourceAreaMaxY = 11602,
    duffelSpawnX = 8078,
    duffelSpawnY = 11602,
    duffelSpawnZ = 0
}, {
    x = 8090,
    y = 11537,
    z = 0,
    location = "Rosewood - Marple & Christie Legal Services",
    missionName = "Legal Office Recovery",
    objective = "Eliminate targets and recover legal evidence",
    areaMinX = 8082,
    areaMaxX = 8098,
    areaMinY = 11529,
    areaMaxY = 11545,
    hiddenPadding = 12,
    zombieCount = 4
}, {
    x = 8081,
    y = 11588,
    z = 0,
    location = "Rosewood - Knox Bank",
    missionName = "Rosewood - Knox bank 3: ESCAPE",
    objective = "Escape the hot zone and lose the trail",
    areaMinX = 8077,
    areaMaxX = 8092,
    areaMinY = 11586,
    areaMaxY = 11602,
    hiddenPadding = 7,
    zombieCount = 0,
    missionMode = "escape_bank",
    missionGroup = "RosewoodKnoxBankHeist",
    missionPart = 3,
    missionPartTotal = 3,
    escapeFromX = 8081,
    escapeFromY = 11588,
    escapeMinDistance = 350
}}

S4_Jobs_Lore.MISSION_OBJECTIVES = {"Clean the warehouse office", "Dispose of suspicious trash bags",
                                   "Disinfect a small clinic room", "Sanitize the motel hallway",
                                   "Clean blood traces in a storage unit", "Deep-clean a private garage"}

S4_Jobs_Lore.START_BUTTON_LABELS = {"Start", "Get that man", "Take their stuff", "You can do it."}

S4_Jobs_Lore.MISSION_PHOTO_LORE = {{
    title = "Hidden Route",
    note = "A photo of a man with a street number and threats written with curses."
}, {
    title = "Exchange Point",
    note = "A blurry parking lot deal. A plate number is underlined three times."
}, {
    title = "Stolen Goods",
    note = "Crates stacked in a dark room. Someone wrote: 'Move tonight or you're dead.'"
}, {
    title = "Contact Board",
    note = "A corkboard full of faces and arrows, with one name crossed in red."
}, {
    title = "Surveillance Shot",
    note = "Taken from a rooftop. The target is circled with the words: 'No mistakes.'"
}, {
    title = "Safehouse Entrance",
    note = "A hidden side door marked with chalk symbols and a warning: 'Stay out.'"
}}
