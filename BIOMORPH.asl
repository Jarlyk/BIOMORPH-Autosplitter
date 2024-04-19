state("BIOMORPH") {}

startup {
    
    refreshRate = 20;

    vars.debugPrint = true;
	vars.debugNewVars = true;

    dynamic unity = Assembly.Load(File.ReadAllBytes(@"Components\asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "BIOMORPH";
	//vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertGameTime();
    
	vars.started = false;
	vars.readyToSplit = false;
	vars.startTime = DateTime.UtcNow;
	vars._lua = null;
	vars._luaTable = null;
	vars._speedrunHandler = null;
	vars.luaVarsDict = new Dictionary<string, IntPtr>(128);
	vars.loadedLuaVars = new List<string>();
	vars.oldCount = 0;
	vars.newCount = 0;
	vars.pendingSplitCount = 0;
	vars.srhStart = false;
	vars.srhLoading = false;
    vars.debugPrinted = !vars.debugPrint;
	
	//These indices apply to both Lua and SRH splits
    vars.indexOfName = 0;
    vars.indexOfDefaultOn = 1;
    vars.indexOfCaption = 2;
    vars.indexOfFlag = 3;
    vars.indexOfIsSplit = 4;
	
	//These indices only apply to SRH splits
	vars.indexNewVal = 5;
	vars.indexOldVal = 6;

    var addSplits = (Action<object[,], string>)((splits, category) => {
		for (int i = 0; i <= splits.GetUpperBound(0); i++) {
			settings.Add((string)splits[i, vars.indexOfName], (bool)splits[i, vars.indexOfDefaultOn], (string)splits[i, vars.indexOfCaption], category);
		}
	});
	
	//Bosses
    vars.categoryBoss = "bosses";
	settings.Add(vars.categoryBoss, true, "Boss");
	settings.SetToolTip(vars.categoryBoss, "splits when the boss is defeated");	
    vars.bosses = new object[,] {
        {"boss_Z03_01", true, "Experiment ST-471", "SerializationData_Kills_Boss_Z03_01", false},
        {"boss_Z04_01", true, "Gorgerzer", "SerializationData_Kills_Boss_Z04_01", false},
        {"boss_Z01_01", true, "Miratos", "SerializationData_Kills_Boss_Z01_01", false},
        {"boss_Z02_02", true, "Roltaon", "SerializationData_Kills_Boss_Z02_02", false},
        {"boss_Z05_03", true, "Buzz", "SerializationData_Kills_Boss_Z05_03", false},
        {"boss_Z10_03", true, "Model 37", "SerializationData_Kills_Boss_Z10_03", false},
        {"boss_Z07_01", true, "Maiden of Protection", "SerializationData_Kills_Boss_Z07_01", false},
        {"boss_Z13_03", true, "Dustmoth", "Quest.MQ10_State4", false},
        {"boss_Z14_01", false, "Entity", "SerializationData_Kills_Boss_Z14_01", false}
    };
    addSplits(vars.bosses, vars.categoryBoss);

	//Abilities
    vars.categoryAbilities = "abilities";
	settings.Add(vars.categoryAbilities, true, "Abilities");
	settings.SetToolTip(vars.categoryAbilities, "splits when the ability is acquired");	
    vars.abilities = new object[,] {
        {"ability_biomorph", false, "Biomorph", "Abilities.Biomorph", false},
        {"ability_pin_map", false, "Pin Map", "Abilities.PinMap", false},
        {"ability_biomorph_arsenal", false, "Biomorph Arsenal", "Abilities.Biomorph_Arsernal", false},
        {"ability_walljump", true, "Wall Jump", "Abilities.WallJump", false},
        {"ability_zipline", true, "Voltage Flow", "Abilities.Zipline", false},
        {"ability_magnetism", false, "Ferromagnetism", "Abilities.MagneticFerrox", false},
        {"ability_dash", true, "Liquefaction Rush", "Abilities.Dash", false},
        {"ability_swim", true, "Freestyle Swimming", "Abilities.Swim", false},
        {"ability_glide", false, "Aerial Intelligence Wings", "Abilities.Glide", false},
        {"ability_synth_gateway", false, "Synthetic Rush", "Abilities.SyntheticGateway", false}
    };
    addSplits(vars.abilities, vars.categoryAbilities);
	
	//Chips
    vars.categoryChips = "chips";
	settings.Add(vars.categoryChips, true, "Chips");
	settings.SetToolTip(vars.categoryChips, "splits when the chip is acquired");	
    vars.chips = new object[,] {
        {"chip_bruisers", false, "The Bruisers", "Chips.TheBruisers.01.01", false},
        {"chip_executioner", true, "Executioner", "Chips.TheExecutioner.01", false},
        {"chip_little_helper", false, "Little Helper", "Chips.LittleHelper.01", false},
        {"chip_pain_legion", false, "Pain Legion", "Chips_PainLegion_01", false},
        {"chip_phoenix_blow", false, "Phoenix Blow", "Chips.PhoenixBlow.01", false},
        {"chip_calamity_bringer", false, "Calamity Bringer", "Chips.CalamityBringer.01", false},
        {"chip_ferrox_field", false, "Ferrox Field", "Chips_FerroxField_01", false},
        {"chip_ferrox_roar", false, "Ferrox Roar", "Chips.FerroxRoar.01", false},
        {"chip_ferrox_specter", false, "Ferrox Specter", "Chips.FerroxSpecter.01", false},
        {"chip_barb_drizzle", false, "Barb Drizzle", "Chips.BarbDrizzle.01", false},
        {"chip_mecha_crash", false, "Mecha Crash", "Chips.MechaCrash.01", false},
        {"chip_forsaken_eater", false, "Forsaken Eater", "Chips.ForsakenEater.01", false},
        {"chip_ferrox_hurricane", false, "Ferrox Hurricane", "Chips.FerroxHurricane.03", false},
        {"chip_shadow_sting", false, "Shadow Sting", "Chips.ShadowSting.01", false},
        {"chip_scargato_wrath", false, "Scargato Wrath", "Chips_ScargatoWrath_01", false}
    };
    addSplits(vars.chips, vars.categoryChips);
   
    //Progression Keys
    vars.categoryPKeys = "pkeys";
	settings.Add(vars.categoryPKeys, true, "Progression Keys");
	settings.SetToolTip(vars.categoryPKeys, "splits when progression key is acquired");	
    vars.pkeys = new object[,] {
		{"pkey_wrench", false, "Wrench", "Item.Wrench", false},
		{"pkey_guild_ring", false, "Kertar Guild Ring", "Item.KertarGuildRing", false},
		{"pkey_mom_trinket", false, "Mom Trinket", "Item.MomTrinket", false},
		{"pkey_map_key", false, "Map Key", "Item.MapKey", false},
		{"pkey_lucius_letter", false, "Lucius Letter", "Item.LuciusLetter", false},
		{"pkey_rocco_code", false, "Rocco Code", "Item.RoccoCode", false},
		{"pkey_toolbox", false, "Tool Box", "Item.ToolBox", false},
		{"pkey_bottle", false, "Bottle", "Item.ToolBox", false},
		{"pkey_sydelle_key", false, "Sydelle Key", "Item.SydelleKey", false},
		{"pkey_julia_ring", false, "Julia Ring", "Item.JuliaRing", false},
		{"pkey_thermosubmerger", false, "Thermosubmerger", "Item.Thermosubmerger", false},
		{"pkey_balloon_handle", false, "Hot Air Balloon Handle", "Item.HotAirBalloonHandle", false},
        {"pkey_sentinel_key1", true, "Round Key", "Items.AccessKey1", false},
        {"pkey_sentinel_key3", true, "Triangle Key", "Items.AccessKey3", false},
        {"pkey_sentinel_key2", true, "Square Key", "Items.AccessKey2", false},
        {"pkey_sentinel_key4", true, "Diamond Key", "Items.AccessKey4", false},
        {"pkey_cannon_part0", true, "Steel District Cannon Part", "Items.CannonPart0", false},
        {"pkey_cannon_part1", true, "High Rise District Cannon Part", "Items.CannonPart1", false},
        {"pkey_cannon_part2", true, "Defense District Cannon Part", "Items.CannonPart2", false},
    };
    addSplits(vars.pkeys, vars.categoryPKeys);
	
	//Cats
	vars.categoryCats = "cats";
	settings.Add(vars.categoryCats, true, "Scargatos");
	settings.SetToolTip(vars.categoryCats, "splits when Scargato is saved; names coming soon");
	vars.cats = new object[,] {
		{"cat_01", false, "Scargatos.01", "Items.Scargatos.01", false},
		{"cat_02", false, "Scargatos.02", "Items.Scargatos.02", false},
		{"cat_03", false, "Scargatos.03", "Items.Scargatos.03", false},
		{"cat_04", false, "Scargatos.04", "Items.Scargatos.04", false},
		{"cat_05", false, "Scargatos.05", "Items.Scargatos.05", false},
		{"cat_06", false, "Scargatos.06", "Items.Scargatos.06", false},
		{"cat_07", false, "Scargatos.07", "Items.Scargatos.07", false},
		{"cat_08", false, "Scargatos.08", "Items.Scargatos.08", false},
		{"cat_09", false, "Scargatos.09", "Items.Scargatos.09", false},
		{"cat_10", false, "Scargatos.10", "Items.Scargatos.10", false},
		{"cat_11", false, "Scargatos.11", "Items.Scargatos.11", false},
		{"cat_12", false, "Scargatos.12", "Items.Scargatos.12", false},
		{"cat_13", false, "Scargatos.13", "Items.Scargatos.13", false},
		{"cat_14", false, "Scargatos.14", "Items.Scargatos.14", false},
		{"cat_15", false, "Scargatos.15", "Items.Scargatos.15", false},
		{"cat_16", false, "Scargatos.16", "Items.Scargatos.16", false},
		{"cat_17", false, "Scargatos.17", "Items.Scargatos.17", false},
		{"cat_18", false, "Scargatos.18", "Items.Scargatos.18", false},
		{"cat_19", false, "Scargatos.19", "Items.Scargatos.19", false},
		{"cat_20", false, "Scargatos.20", "Items.Scargatos.20", false},
		{"cat_21", false, "Scargatos.21", "Items.Scargatos.21", false},
		{"cat_22", false, "Scargatos.22", "Items.Scargatos.22", false},
		{"cat_23", false, "Scargatos.23", "Items.Scargatos.23", false},
		{"cat_24", false, "Scargatos.24", "Items.Scargatos.24", false},
		{"cat_25", false, "Scargatos.25", "Items.Scargatos.25", false},
		{"cat_26", false, "Scargatos.26", "Items.Scargatos.26", false},
		{"cat_27", false, "Scargatos.27", "Items.Scargatos.27", false},
		{"cat_28", false, "Scargatos.28", "Items.Scargatos.28", false},
		{"cat_29", false, "Scargatos.29", "Items.Scargatos.29", false},
		{"cat_30", false, "Scargatos.30", "Items.Scargatos.30", false},
		{"cat_31", false, "Scargatos.31", "Items.Scargatos.31", false},
		{"cat_32", false, "Scargatos.32", "Items.Scargatos.32", false},
		{"cat_33", false, "Scargatos.33", "Items.Scargatos.33", false},
		{"cat_34", false, "Scargatos.34", "Items.Scargatos.34", false},
		{"cat_35", false, "Scargatos.35", "Items.Scargatos.35", false},
		{"cat_36", false, "Scargatos.36", "Items.Scargatos.36", false},
		{"cat_37", false, "Scargatos.37", "Items.Scargatos.37", false},
		{"cat_38", false, "Scargatos.38", "Items.Scargatos.38", false},
		{"cat_39", false, "Scargatos.39", "Items.Scargatos.39", false},
	};
	addSplits(vars.cats, vars.categoryCats);
	
	//Rooms
	vars.categoryRooms = "rooms";
	settings.Add(vars.categoryRooms, true, "Room Entry");
	settings.SetToolTip(vars.categoryRooms, "splits when the room is entered for the first time");
	vars.rooms = new object[,] {
		{"room_Z05_01", false, "Badlands (near Mezzo)", "SerializationData_Z05_Map_01", false},
		{"room_Z12_03", true, "Plains (near Mezzo)", "SerializationData_Z12_Map_03", false},
		{"room_Z12_10", false, "Plains (train)", "SerializationData_Z12_Map_10", false},
		{"room_Z09_08", true, "Anssey-sur-Prug (first town room)", "SerializationData_Z09_Map_08", false},
		{"room_Z13_01", true, "Dustborough", "SerializationData_Z13_Map_01", false},
		{"room_Z14_02", true, "Core", "SerializationData_Z14_Map_02", false},
		{"room_Z06_01", false, "Baro (Badlands side)", "SerializationData_Z06_Map_01", false},
		{"room_Z07_03", false, "Gloomy Burrows (near Baro)", "SerializationData_Z07_Map_03", false}
	};
	addSplits(vars.rooms, vars.categoryRooms);
	
	//Safes
	vars.categorySafes = "safes";
	settings.Add(vars.categorySafes, true, "SAFE Upgrades");
	settings.SetToolTip(vars.categorySafes, "splits when SAFE is upgraded");
	vars.safes = new object[,] {
		{"safe_Z04_05", false, "Upper Mezzo", "SerializationData_Z04_Save_05", false},		
		{"safe_Z04_09", false, "Lower Mezzo", "SerializationData_Z04_Save_09", false},		
		{"safe_Z12_02", true, "Plains", "SerializationData_Z12_Save_02", false},
		{"safe_Z10_01", false, "Outside Sentinel Complex", "SerializationData_Z10_Save_01", false}		
	};	
	addSplits(vars.safes, vars.categorySafes);
	
	//Arenas
	vars.categoryArenas = "arenas";
	settings.Add(vars.categoryArenas, true, "Arenas");
	settings.SetToolTip(vars.categoryArenas, "splits when the arena is completed");	
    vars.arenas = new object[,] {
        {"arena_mush_pit", true, "Mushroom Pit", "SerializationData_Z07_Battle_Arena_01", false}
    };
    addSplits(vars.arenas, vars.categoryArenas);

	//Cutscenes
	vars.categoryCutscenes = "cutscenes";
	settings.Add(vars.categoryCutscenes, true, "Cutscenes");
	settings.SetToolTip(vars.categoryCutscenes, "splits upon cutscene flag being set");	
    vars.cutscenes = new object[,] {
        {"cutscenes_tutorial_beacon", false, "Tutorial Beacon", "SerializationData_Z03_Z03Beacon1CS_01", false},
        {"cutscenes_tutorial_morph", false, "Tutorial Morph", "SerializationData_Z03_Z03MindBreakCS_01", false},
        {"cutscenes_athen_locked", true, "Athenaeum Locked", "SerializationData_Z01_Z01AthenaeumDoorCS_01", false},
        {"cutscenes_banditos_01", true, "Banditos (First Encounter)", "SerializationData_Z05_Banditos_01", false},
        {"cutscenes_banditos_02", false, "Banditos (Pre-Buzz)", "SerializationData_Z05_Banditos_02", false},
        {"cutscenes_major_CS01", true, "Major First Encounter (Etta Says Hello)", "SerializationData_Z13_MajorCS_01", false},
        {"cutscenes_major_CS03", false, "Major Squish", "SerializationData_Z13_MajorCS_03", false}
    };
    addSplits(vars.cutscenes, vars.categoryCutscenes);
	
	//Endings (SRH splits)
	vars.categoryEndings = "endings";
	settings.Add(vars.categoryEndings, true, "Endings");
	settings.SetToolTip(vars.categoryEndings, "splits upon triggering ending cutscene");
	vars.endings = new object[,] {
		{"ending_kill", true, "Kill Entity", 0x48, false, false, false},
		{"ending_spare", false, "Spare Entity", 0x49, false, false, false},
		{"ending_te", false, "True Ending", 0x4A, false, false, false}
	};
	addSplits(vars.endings, vars.categoryEndings);	
}

init {
    vars.Helper.TryLoad = (Func<dynamic, bool>)(helper =>
    {
        vars._lua = helper["Assembly-CSharp-firstpass", "PixelCrushers.DialogueSystem.Lua"];
		vars._luaTable = helper["Assembly-CSharp-firstpass", "Language.Lua.LuaTable"];
		vars._gameManager = helper["Assembly-CSharp", "LDS.Framework.Core.GameManager"];
		vars._speedrunHandler = helper["Assembly-CSharp","LDS.MindBreaker.Core.SpeedrunHandler"];		
		vars.Manager = helper;
        return true;
    });

	vars.readLuaDict = (Func<IntPtr, Dictionary<string, IntPtr>, bool>)((basePtr, result) => {
        var derefPtr = vars.Helper.Read<IntPtr>(basePtr);
		var entriesPtr = vars.Helper.Read<IntPtr>(derefPtr + 24);
		var count = vars.Helper.Read<int>(entriesPtr + 24);
		    if (!vars.debugPrinted) {			
				print("count: " + count);
			}
		if (count < 0) return false;
		if (count > 10000) {
		    if (!vars.debugPrinted) {			
				print("Resulting dictionary way too huge");
			}
			return false;
		}
		for (int i=0; i < count; i++) {
			var keyPtr = entriesPtr + 32 + i*24 + 8;
			if (keyPtr != IntPtr.Zero) {
				var luaKeyPtr = vars.Helper.Read<IntPtr>(keyPtr);
				var key = vars.Helper.ReadString(luaKeyPtr + 0x10);
				var valPtr = entriesPtr + 32 + i*24 + 16;
				var value = vars.Helper.Read<IntPtr>(valPtr);
				if (key != null && value != IntPtr.Zero) {
					result[key] = value;
				}
			}
		}
		return true;
	});
	
	vars.getUpdatedKeys = (Func<IntPtr, List<string>, bool>)((basePtr, existingKeys) => {
		var result = new List<string>();
        var derefPtr = vars.Helper.Read<IntPtr>(basePtr);
		var entriesPtr = vars.Helper.Read<IntPtr>(derefPtr + 24);
		var count = vars.Helper.Read<int>(entriesPtr + 24);
		if (count < 0) return false;
		if (count > 10000) {
		    if (!vars.debugPrinted) {			
				print("Resulting dictionary way too huge");
			}
			return false;
		}
		if (count <= existingKeys.Count) {
			return false;
		}
		
		int startIndex = existingKeys.Count;
		for (int i=startIndex; i < count; i++) {
			var keyPtr = entriesPtr + 32 + i*24 + 8;
			if (keyPtr != IntPtr.Zero) {
				var luaKeyPtr = vars.Helper.Read<IntPtr>(keyPtr);
				var key = vars.Helper.ReadString(luaKeyPtr + 0x10);
				if (key != null) {
					existingKeys.Add(key);
				}
			}			
		}
		return true;
	});
	
	vars.dumpSubDict = (Action<string>)((topKey) => {
		var tableOffset = vars._luaTable["dict"];
		var dictPtr = vars.luaVarsDict[topKey];
		var subDict = vars.readLuaDict(dictPtr + tableOffset, null);
		if (subDict != null) {
			var builder = new StringBuilder();
			builder.AppendLine(topKey + " (" + subDict.Count + ")");
			builder.AppendLine("-------------");
			foreach (string key in subDict.Keys) {
				var valPtr = subDict[key];
				var valDeref = vars.Helper.Read<IntPtr>(valPtr + 0x10);
				builder.AppendLine(key + " : " + valDeref.ToString("X8"));
			}				
			builder.AppendLine("-------------");
			print(builder.ToString());
		}
	});
	
	vars.checkLuaSplits = (Action<object[,]>)((splits) => {
		for (int i = 0; i <= splits.GetUpperBound(0); i++) {
			var didSplit = (bool)splits[i, vars.indexOfIsSplit];
			if (!settings[(string)splits[i, vars.indexOfName]] || didSplit) {
				continue;
			}
			for (int k = vars.oldCount; k < vars.newCount; k++) {
				if (vars.loadedLuaVars[k].Equals(splits[i, vars.indexOfFlag])) {
					if (vars.debugNewVars) {
						print("Split on: " + vars.loadedLuaVars[k]);
					}
					splits[i, vars.indexOfIsSplit] = true;
					vars.pendingSplitCount++;
				}
			}
		}
	});
	
	vars.readSrhValues = (Action<IntPtr, object[,]>)((srhPtr, splits) => {
		for (int i=0; i <= splits.GetUpperBound(0); i++) {
			splits[i, vars.indexOldVal] = splits[i, vars.indexNewVal];
			splits[i, vars.indexNewVal] = vars.Helper.Read<bool>(srhPtr + (int)splits[i, vars.indexOfFlag]);
		}
	});
	
	vars.checkSrhSplits = (Action<object[,]>)((splits) => {
		for (int i=0; i <= splits.GetUpperBound(0); i++) {
			if (settings[(string)splits[i, vars.indexOfName]] 
			&& !(bool)splits[i, vars.indexOfIsSplit]
			&& (bool)splits[i, vars.indexNewVal])
			{
				if (vars.debugNewVars) {
					print("Split on: " + (string)splits[i, vars.indexOfName]);
				}
				splits[i, vars.indexOfIsSplit] = true;
				vars.pendingSplitCount++;
			}
		}		
	});
	
	vars.resetSplits = (Action<object[,]>)((splits) => {
		for (int i = 0; i <= splits.GetUpperBound(0); i++) {
			splits[i, vars.indexOfIsSplit] = false;
		}
	});
	    
	vars.hasUpdated = false;
	current.activeScene = null;
}

update {
	//current.startingGame = false;
	//var sceneName = vars.Helper.Scenes.Active.Name;
	//current.activeScene = sceneName == null ? current.activeScene : sceneName;
	//current.sceneCount = vars.Helper.Scenes.Count;
	
	var lua = vars._lua;
	var gameManager = vars._gameManager;
	var speedrunHandler = vars._speedrunHandler;
	var table = vars._luaTable;
	if (lua.Static != IntPtr.Zero && gameManager.Static != IntPtr.Zero && speedrunHandler.Static != IntPtr.Zero) {		
		var tablePtr = vars.Helper.Read<IntPtr>(lua.Static + lua["m_environment"]);
		if (tablePtr != IntPtr.Zero) {
			var dictPtr = tablePtr + table["dict"];
			if (vars.readLuaDict(dictPtr, vars.luaVarsDict)) {
				if (!vars.debugPrinted) {
					print("tablePtr: " + tablePtr.ToString("X8"));
					print("dictPtr: " + dictPtr.ToString("X8"));
				}
				vars.readyToSplit = true;
			}
		}
		
		var gmPtr = vars.Helper.Read<IntPtr>(gameManager.Static + 0);
		if (gmPtr != IntPtr.Zero) {
			current.gameState = vars.Helper.Read<short>(gmPtr + 0x28);
		}
		
		var srhPtr = vars.Helper.Read<IntPtr>(speedrunHandler.Static + 0);
		if (srhPtr != IntPtr.Zero) {
			//Read special start and loading flags
			current.srhStart = vars.Helper.Read<bool>(srhPtr + 0x31);
			current.srhLoading = vars.Helper.Read<bool>(srhPtr + 0x32);
			
			//Read split flags
			vars.readSrhValues(srhPtr, vars.endings);
		}
	}
	
	if (vars.readyToSplit) {		
		if (!vars.debugPrinted) {
			vars.debugPrinted = true;
			if (vars.luaVarsDict.Count > 0) {
				var builder = new StringBuilder();
				builder.AppendLine("Lua Variables (" + vars.luaVarsDict.Count + ")");
				builder.AppendLine("-------------");
				foreach (string key in vars.luaVarsDict.Keys) {
					var valPtr = vars.luaVarsDict[key];
					var value = vars.Helper.Read<IntPtr>(valPtr + 0x10);
					builder.AppendLine(key + " : " + valPtr.ToString("X8"));
				}				
				builder.AppendLine("-------------");
				print(builder.ToString());
			}
			else {
				print("No Lua Variables Found");
			}
		}
		
		if (vars.started) {
			vars.oldCount = vars.loadedLuaVars.Count;
			if (vars.getUpdatedKeys(vars.luaVarsDict["Variable"] + table["dict"], vars.loadedLuaVars)) {
				vars.newCount = vars.loadedLuaVars.Count;
				if (vars.newCount > vars.oldCount && vars.debugNewVars) {
					var builder = new StringBuilder();
					builder.AppendLine("## New Lua Vars");
					for (int i = vars.oldCount; i < vars.newCount; i++) {
						builder.AppendLine(vars.loadedLuaVars[i]);
					}
					print(builder.ToString());
				}
			}
		}
		
		//var mainSceneChanged = current.activeScene != old.activeScene && current.activeScene != null;
		//var sceneCountChanged = current.sceneCount != old.sceneCount;
		//if (mainSceneChanged || sceneCountChanged) {			
		//	print("Scene Loaded: " + current.activeScene + " (" + current.sceneCount + ")");			
		//}
	}
	
	vars.hasUpdated = true;
}

start {
	if (!vars.hasUpdated) return false;
	return vars.readyToSplit && current.srhStart && !old.srhStart;
}

onStart {
	vars.started = true;
	vars.startTime = DateTime.UtcNow;
}

split {
	if (!vars.hasUpdated) return false;
	if (!vars.started) return false;
	if (!vars.readyToSplit) return false;
	
	//if (current.gameState != old.gameState) {
	//	print("Game State: " + current.gameState);
	//}		
	
	if (vars.newCount > vars.oldCount) {
		vars.checkLuaSplits(vars.bosses);
		vars.checkLuaSplits(vars.abilities);
		vars.checkLuaSplits(vars.chips);
		vars.checkLuaSplits(vars.pkeys);
		vars.checkLuaSplits(vars.cats);
		vars.checkLuaSplits(vars.rooms);
		vars.checkLuaSplits(vars.safes);
		vars.checkLuaSplits(vars.arenas);
		vars.checkLuaSplits(vars.cutscenes);
	}

	//SRH splits (currently only endings)
	vars.checkSrhSplits(vars.endings);
	
	//In case multiple splits occur on the same frame, dole out the split triggers per poll cycle until they are complete
	var split = vars.pendingSplitCount > 0;
	if (split) {
		vars.pendingSplitCount--;
	}
    return split;
}

onReset {
	vars.hasUpdated = false;
	vars.started = false;
	vars.readyToSplit = false;
    vars.debugPrinted = !vars.debugPrint;
	vars.luaVarsDict.Clear();
	vars.loadedLuaVars.Clear();
	vars.oldCount = 0;
	vars.newCount = 0;
	vars.pendingSplitCount = 0;
	
    vars.resetSplits(vars.bosses);
	vars.resetSplits(vars.abilities);
	vars.resetSplits(vars.chips);
	vars.resetSplits(vars.pkeys);
	vars.resetSplits(vars.rooms);
	vars.resetSplits(vars.cats);
	vars.resetSplits(vars.safes);
	vars.resetSplits(vars.arenas);
	vars.resetSplits(vars.cutscenes);
	vars.resetSplits(vars.endings);
}

isLoading {
	if (!vars.readyToSplit) return false;
	
	return current.srhLoading;
}