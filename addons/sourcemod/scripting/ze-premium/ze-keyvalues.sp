public ReadFileFolder(char[] path)
{
	Handle dirh = INVALID_HANDLE;
	char buffer[256];
	char tmp_path[256];
	FileType type = FileType_Unknown;
	int len;
	
	len = strlen(path);
	if (path[len-1] == '\n')
		path[--len] = '\0';

	TrimString(path);
	
	if(DirExists(path))
	{
		dirh = OpenDirectory(path);
		while(ReadDirEntry(dirh,buffer,sizeof(buffer),type))
		{
			len = strlen(buffer);
			if (buffer[len-1] == '\n')
				buffer[--len] = '\0';

			TrimString(buffer);

			if (!StrEqual(buffer,"",false) && !StrEqual(buffer,".",false) && !StrEqual(buffer,"..",false))
			{
				strcopy(tmp_path,255,path);
				StrCat(tmp_path,255,"/");
				StrCat(tmp_path,255,buffer);
				if(type == FileType_File)
				{
					StartToDownload(tmp_path);
				}
				else
				{
					ReadFileFolder(tmp_path);
				}
			}
		}
	}
	else
	{
		StartToDownload(path);
	}
	if(dirh != INVALID_HANDLE)
	{
		CloseHandle(dirh);
	}
}

public DownloadFiles(){
	char file[256];
	BuildPath(Path_SM, file, 255, "configs/ze_premium-download.ini");
	Handle fileh = OpenFile(file, "r");
	char buffer[256];
	int len;
	
	if(fileh == INVALID_HANDLE) return;
	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{
		len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';

		TrimString(buffer);

		if(!StrEqual(buffer,"",false))
		{
			ReadFileFolder(buffer);
		}
		
		if (IsEndOfFile(fileh))
			break;
	}
	if(fileh != INVALID_HANDLE){
		CloseHandle(fileh);
	}
}

public void StartToDownload(char[] buffer)
{
	int len = strlen(buffer);
	if (buffer[len-1] == '\n')
		buffer[--len] = '\0';
	
	TrimString(buffer);
	if(len >= 2 && buffer[0] == '/' && buffer[1] == '/')
	{
		//Comment
	}
	else if (!StrEqual(buffer,"",false) && FileExists(buffer))
	{
		AddFileToDownloadsTable(buffer);
	}
}

public Action CMD_ZMClass(int client, int args)
{
	if(GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT)
	{
		Menu zmmenu = new Menu(MenuHandler_ZombieClass);
		SetMenuTitle(zmmenu, "Zombie class");
	 	
	 	kvZombies.Rewind();
		if (!kvZombies.GotoFirstSubKey())
			return Plugin_Handled;
	 
		char ClassID[10];
		char name[150];
		do
		{
			kvZombies.GetSectionName(ClassID, sizeof(ClassID));
			kvZombies.GetString("name", name, sizeof(name));
			zmmenu.AddItem(ClassID, name);
		} while (kvZombies.GotoNextKey());
	 
		zmmenu.Display(client, 0);
	}
	return Plugin_Continue;
}

public int MenuHandler_ZombieClass(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			int SelectedZMClass = StringToInt(info);
			
			//Check for VIP class
			kvZombies.Rewind();
			char s_SelectedClass[10];
			IntToString(SelectedZMClass, s_SelectedClass, sizeof(s_SelectedClass));
			if (!kvZombies.JumpToKey(s_SelectedClass)) return;

			char flags[40] = "";
			kvZombies.GetString("flags", flags, sizeof(flags));
			
			if(StrEqual(flags, ""))
			{
				i_zclass[client] = SelectedZMClass;
				CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", s_SelectedClass);
			} 
			else
			{
				if(HasPlayerFlags(client, flags))
				{
					i_zclass[client] = SelectedZMClass;
					CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", s_SelectedClass);					
				} 
				else
				{
					PrintToChat(client, " \x04[ZE-Class]\x01 You don't have a \x04VIP");
				}
			}
		}
	}
}

public Action CMD_HumanClass(int client, int args)
{
	if(GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT)
	{
		Menu zmmenu = new Menu(MenuHandler_HumanClass);
		SetMenuTitle(zmmenu, "Human class");
	 	
	 	kvHumans.Rewind();
		if (!kvHumans.GotoFirstSubKey())
			return Plugin_Handled;
	 
		char ClassID[10];
		char name[150];
		do
		{
			kvHumans.GetSectionName(ClassID, sizeof(ClassID));
			kvHumans.GetString("name", name, sizeof(name));
			zmmenu.AddItem(ClassID, name);
		} while (kvHumans.GotoNextKey());
	 
		zmmenu.Display(client, 0);
	}
	return Plugin_Continue;
}

public int MenuHandler_HumanClass(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			int SelectedHumanClass = StringToInt(info);
			
			//Check for VIP class
			kvHumans.Rewind();
			char s_SelectedClass[10];
			IntToString(SelectedHumanClass, s_SelectedClass, sizeof(s_SelectedClass));
			if (!kvHumans.JumpToKey(s_SelectedClass)) return;

			char flags[40] = "";
			kvHumans.GetString("flags", flags, sizeof(flags));
			
			if(StrEqual(flags, ""))
			{
				i_hclass[client] = SelectedHumanClass;
				CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", s_SelectedClass);
			} 
			else
			{
				if(HasPlayerFlags(client, flags))
				{
					i_hclass[client] = SelectedHumanClass;
					CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", s_SelectedClass);					
				} 
				else
				{
					PrintToChat(client, " \x04[ZE-Class]\x01 You don't have a \x04VIP");
				}
			}
		}
	}
}

void SetPlayerAsZombie(int client)
{
	kvZombies.Rewind();
	char clientclass[10];
	IntToString(i_zclass[client], clientclass, sizeof(clientclass));
	if (!kvZombies.JumpToKey(clientclass)) 
	{
		SetEntityHealth(client, g_cZEZombieHP.IntValue);
		SetEntityModel(client, ZOMBIEMODEL);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_cZEZombieSpeed.FloatValue);
		return;		
	}
		
	char zmName[100];
	char zmGravity[10];
	char zmSpeed[10];
	char zmHeath[10];
	char zmModel[PLATFORM_MAX_PATH + 1];
	char flags[40] = "";
	flags = "";
	kvZombies.GetString("name", 		zmName, 	sizeof(zmName));
	kvZombies.GetString("gravity", 		zmGravity, 	sizeof(zmGravity));
	kvZombies.GetString("speed", 		zmSpeed, 	sizeof(zmSpeed));
	kvZombies.GetString("health", 		zmHeath, 	sizeof(zmHeath));
	kvZombies.GetString("model_path", 	zmModel, 	sizeof(zmModel));
	
	float fZmGravity; 
	float fZmSpeed;
	fZmGravity = StringToFloat(zmGravity);
	fZmSpeed = StringToFloat(zmSpeed);
	int iZmHealth = StringToInt(zmHeath);
	Selected_Class_Zombie[client] = zmName;
	
	SetEntityHealth(client, iZmHealth);
	SetEntityGravity(client, fZmGravity);
	SetEntityModel(client, zmModel);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", fZmSpeed);
}

void SetPlayerAsHuman(int client)
{
	kvHumans.Rewind();
	char clientclass[10];
	IntToString(i_hclass[client], clientclass, sizeof(clientclass));
	if (!kvHumans.JumpToKey(clientclass)) 
	{
		SetEntityHealth(client, g_cZEHumanHP.IntValue);
		SetEntityModel(client, HUMANMODEL);
		SetEntityGravity(client, 1.0);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);	
		return;		
	}
		
	char humanName[100];
	char humanItem[32];
	char humanProtect[10];
	char humanGravity[10];
	char humanSpeed[10];
	char humanHeath[10];
	char humanModel[PLATFORM_MAX_PATH + 1];
	char flags[40] = "";
	flags = "";
	kvHumans.GetString("name", 			humanName, 	sizeof(humanName));
	kvHumans.GetString("item", 			humanItem, 	sizeof(humanItem));
	kvHumans.GetString("protection", 	humanProtect, 	sizeof(humanProtect));
	kvHumans.GetString("gravity", 		humanGravity, 	sizeof(humanGravity));
	kvHumans.GetString("speed", 		humanSpeed, 	sizeof(humanSpeed));
	kvHumans.GetString("health", 		humanHeath, 	sizeof(humanHeath));
	kvHumans.GetString("model_path", 	humanModel, 	sizeof(humanModel));
	
	float fhumanGravity; 
	float fhumanSpeed;
	fhumanGravity = StringToFloat(humanGravity);
	fhumanSpeed = StringToFloat(humanSpeed);
	int ihumanHealth = StringToInt(humanHeath);
	int ihumanProtect = StringToInt(humanProtect);
	Selected_Class_Human[client] = humanName;
	
	SetEntityHealth(client, ihumanHealth);
	if(humanItem[0] != '-')
	{
		GivePlayerItem(client, humanItem);
	}
	if(ihumanProtect > 0)
	{
		i_protection[client] = ihumanProtect;
	}
	SetEntityGravity(client, fhumanGravity);
	SetEntityModel(client, humanModel);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", fhumanSpeed);
}

public Action CMD_WeaponsRifle(int client, int args)
{
	if(g_bInfected[client] == false)
	{
		Menu zmmenu = new Menu(MenuHandler_WeaponsRifle);
		SetMenuTitle(zmmenu, "Rifle Guns:");
	 	
	 	kvWeapons.Rewind();
	 	if (!kvWeapons.JumpToKey("Rifles"))
	 		return Plugin_Handled;
	 	
		if (!kvWeapons.GotoFirstSubKey())
			return Plugin_Handled;
	 
		char ClassID[32];
		char name[150];
		do
		{
			kvWeapons.GetSectionName(ClassID, sizeof(ClassID));
			kvWeapons.GetString("name", name, sizeof(name));
			zmmenu.AddItem(ClassID, name);
		} while (kvWeapons.GotoNextKey());
	 
		zmmenu.Display(client, 0);
	}
	return Plugin_Continue;
}

public int MenuHandler_WeaponsRifle(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			Primary_Gun[client] = info;
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
			openWeapons(client);
		}
	}
}

public Action CMD_WeaponsHeavy(int client, int args)
{
	if(g_bInfected[client] == false)
	{
		Menu zmmenu = new Menu(MenuHandler_WeaponsHeavy);
		SetMenuTitle(zmmenu, "Heavy Guns:");
	 	
	 	kvWeapons.Rewind();
	 	if (!kvWeapons.JumpToKey("Heavyguns"))
	 		return Plugin_Handled;
	 	
		if (!kvWeapons.GotoFirstSubKey())
			return Plugin_Handled;
	 
		char ClassID[32];
		char name[150];
		do
		{
			kvWeapons.GetSectionName(ClassID, sizeof(ClassID));
			kvWeapons.GetString("name", name, sizeof(name));
			zmmenu.AddItem(ClassID, name);
		} while (kvWeapons.GotoNextKey());
	 
		zmmenu.Display(client, 0);
	}
	return Plugin_Continue;
}

public int MenuHandler_WeaponsHeavy(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			Primary_Gun[client] = info;
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
			openWeapons(client);
		}
	}
}

public Action CMD_WeaponsSmg(int client, int args)
{
	if(g_bInfected[client] == false)
	{
		Menu zmmenu = new Menu(MenuHandler_WeaponsSmg);
		SetMenuTitle(zmmenu, "SMG Guns:");
	 	
	 	kvWeapons.Rewind();
	 	if (!kvWeapons.JumpToKey("Smg"))
	 		return Plugin_Handled;
	 	
		if (!kvWeapons.GotoFirstSubKey())
			return Plugin_Handled;
	 
		char ClassID[32];
		char name[150];
		do
		{
			kvWeapons.GetSectionName(ClassID, sizeof(ClassID));
			kvWeapons.GetString("name", name, sizeof(name));
			zmmenu.AddItem(ClassID, name);
		} while (kvWeapons.GotoNextKey());
	 
		zmmenu.Display(client, 0);
	}
	return Plugin_Continue;
}

public int MenuHandler_WeaponsSmg(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			Primary_Gun[client] = info;
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
			openWeapons(client);
		}
	}
}

public Action CMD_WeaponsPistols(int client, int args)
{
	if(g_bInfected[client] == false)
	{
		Menu zmmenu = new Menu(MenuHandler_WeaponsPistols);
		SetMenuTitle(zmmenu, "Pistols Guns:");
	 	
	 	kvWeapons.Rewind();
	 	if (!kvWeapons.JumpToKey("Pistols"))
	 		return Plugin_Handled;
	 	
		if (!kvWeapons.GotoFirstSubKey())
			return Plugin_Handled;
	 
		char ClassID[32];
		char name[150];
		do
		{
			kvWeapons.GetSectionName(ClassID, sizeof(ClassID));
			kvWeapons.GetString("name", name, sizeof(name));
			zmmenu.AddItem(ClassID, name);
		} while (kvWeapons.GotoNextKey());
	 
		zmmenu.Display(client, 0);
	}
	return Plugin_Continue;
}

public int MenuHandler_WeaponsPistols(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			Secondary_Gun[client] = info;
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Secondary_Gun[client]);
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
			openWeapons(client);
		}
	}
}

public bool HasPlayerFlags(int client, char flags[40])
{
	
	if(StrContains(flags, "a") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_RESERVATION))
		{
			return true;
		}
	}		
	else if(StrContains(flags, "b") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_GENERIC))
		{
			return true;
		}
	}
	else if(StrContains(flags, "c") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_KICK))
		{
			return true;
		}
	}
	else if(StrContains(flags, "d") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_BAN))
		{
			return true;
		}
	}
	else if(StrContains(flags, "e") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_UNBAN))
		{
			return true;
		}
	}	
	else if(StrContains(flags, "f") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_SLAY))
		{
			return true;
		}
	}	
	else if(StrContains(flags, "g") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_CHANGEMAP))
		{
			return true;
		}
	}
	else if(StrContains(flags, "h") != -1)
	{
		if(Client_HasAdminFlags(client, 128))
		{
			return true;
		}
	}		
	else if(StrContains(flags, "i") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_CONFIG))
		{
			return true;
		}
	}
	else if(StrContains(flags, "j") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_CHAT))
		{
			return true;
		}
	}		
	else if(StrContains(flags, "k") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_VOTE))
		{
			return true;
		}
	}	
	else if(StrContains(flags, "l") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_PASSWORD))
		{
			return true;
		}
	}
	else if(StrContains(flags, "m") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_RCON))
		{
			return true;
		}
	}		
	else if(StrContains(flags, "n") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_CHEATS))
		{
			return true;
		}
	}		
	else if(StrContains(flags, "z") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_ROOT))
		{
			return true;
		}
	}		
	else if(StrContains(flags, "o") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_CUSTOM1))
		{
			return true;
		}
	}		
	else if(StrContains(flags, "p") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_CUSTOM2))
		{
			return true;
		}
	}
	else if(StrContains(flags, "q") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_CUSTOM3))
		{
			return true;
		}
	}		
	else if(StrContains(flags, "r") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_CUSTOM4))
		{
			return true;
		}
	}			
	else if(StrContains(flags, "s") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_CUSTOM5))
		{
			return true;
		}
	}			
	else if(StrContains(flags, "t") != -1)
	{
		if(Client_HasAdminFlags(client, ADMFLAG_CUSTOM6))
		{
			return true;
		}
	}
	
	return false;
}