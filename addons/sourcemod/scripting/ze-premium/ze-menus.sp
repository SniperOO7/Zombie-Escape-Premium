void openMenu(int client)
{
	Menu menu = new Menu(mZeHandler);
	
	menu.SetTitle("[Zombie Escape] Main menu:");
	
	menu.AddItem("menu1", "Weapons");
	menu.AddItem("menu2", "Zombie/Human classes");
	menu.AddItem("menu3", "Human/Zombie Shop");
	if(IsClientAdmin(client) || IsClientLeader(client))
	{
		menu.AddItem("menu4", "Admin menu");
	}
	else
	{
		menu.AddItem("menu4", "Admin menu [NO ACCES]", ITEMDRAW_DISABLED);
	}
	menu.AddItem("menu5", ">Your stats<");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				if (StrEqual(szItem, "menu1"))
				{
					if(g_bInfected[client] == false)
					{
						openWeapons(client);
					}
					else
					{
						CReplyToCommand(client, " \x04[ZE-Weapons]\x01 %t", "no_human");
						openMenu(client);
					}
				}
				else if (StrEqual(szItem, "menu2"))
				{
					openClasses(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					openShop(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					if(IsClientAdmin(client) || IsClientLeader(client))
					{
						openAdmin(client);
					}
				}
				else if (StrEqual(szItem, "menu5"))
				{
					char szSteamId[32], szQuery[512];
					GetClientAuthId(client, AuthId_Engine, szSteamId, sizeof(szSteamId));
					
					g_hDatabase.Format(szQuery, sizeof(szQuery), "SELECT * FROM ze_premium_sql WHERE steamid='%s'", szSteamId);
					
					g_hDatabase.Query(szQueryCallback, szQuery, GetClientUserId(client));
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

//*****GUNS MENU*****

void openWeapons(int client)
{
	char text[84];
	
	Menu menu = new Menu(mZeGunsHandler);
	
	menu.SetTitle("[Weapons] Choose a gun:");
	
	if (Primary_Gun[client][0] == '\0' || Primary_Gun[client][0] == '1')
	{
		menu.AddItem("menu1", "Rifle guns");
		menu.AddItem("menu2", "Heavy guns");
		menu.AddItem("menu3", "SMG guns");
	}
	else
	{
		Format(text, sizeof(text), "Rifle guns [%s]", Primary_Gun[client]);
		menu.AddItem("menu1", text);
		Format(text, sizeof(text), "Heavy guns [%s]", Primary_Gun[client]);
		menu.AddItem("menu2", text);
		Format(text, sizeof(text), "SMG guns [%s]", Primary_Gun[client]);
		menu.AddItem("menu3", text);
	}
	
	if (Secondary_Gun[client][0] == '\0' || Secondary_Gun[client][0] == '1')
	{
		menu.AddItem("menu4", "Pistol guns");
	}
	else
	{
		Format(text, sizeof(text), "Pistol guns [%s]", Secondary_Gun[client]);
		menu.AddItem("menu4", text);
	}	

	if(g_bSamegun[client] == true)
	{
		menu.AddItem("menu5", "Same gun next round [ON]");
	}
	else
	{
		menu.AddItem("menu5", "Same gun next round [OFF]");
	}

	menu.AddItem("menu6", ">Get chosen guns<");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeGunsHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				if (StrEqual(szItem, "menu1"))
				{
					FakeClientCommand(client, "sm_rifle");
				}
				else if (StrEqual(szItem, "menu2"))
				{
					FakeClientCommand(client, "sm_heavygun");
				}
				else if (StrEqual(szItem, "menu3"))
				{
					FakeClientCommand(client, "sm_smg");
				}
				else if (StrEqual(szItem, "menu4"))
				{
					FakeClientCommand(client, "sm_pistols");
				}
				else if (StrEqual(szItem, "menu5"))
				{
					if(g_bSamegun[client] == true)
					{
						CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "samegun_false");
						g_bSamegun[client] = false;
						openWeapons(client);
					}
					else
					{
						CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "samegun_true");
						g_bSamegun[client] = true;
						openWeapons(client);
					}
				}
				else if (StrEqual(szItem, "menu6"))
				{
					FakeClientCommand(client, "sm_get");
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

//*****HUMAN/ZOMBIE CLASSES*****
void openClasses(int client)
{
	Menu menu = new Menu(mZeClassHandler);
	
	menu.SetTitle("[Classes] Main Menu:");
	
	menu.AddItem("menu1", "Human class");
	menu.AddItem("menu2", "Zombie class");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeClassHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				if (StrEqual(szItem, "menu1"))
				{
					FakeClientCommand(client, "sm_humanclass");
				}
				else if (StrEqual(szItem, "menu2"))
				{
					FakeClientCommand(client, "sm_zombieclass");
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

//*****SHOP*****
void openShop(int client)
{
	char text[84];
	
	Menu menu = new Menu(mZeShopHandler);
	
	menu.SetTitle("[Shop] Main Menu:");
	
	Format(text, sizeof(text), "Health-Shot [%i $] [HUMAN]", g_cZEHealthShot.IntValue);
	menu.AddItem("menu1", text);
	Format(text, sizeof(text), "Fire Grenade [%i $] [HUMAN]", g_cZEHeNade.IntValue);
	menu.AddItem("menu2", text);
	Format(text, sizeof(text), "[VIP] Freeze Grenade [%i $] [HUMAN]", g_cZEFlashNade.IntValue);
	if(IsClientVIP(client))
	{
		menu.AddItem("menu3", text);
	}
	else
	{
		menu.AddItem("menu3", text, ITEMDRAW_DISABLED);
	}
	Format(text, sizeof(text), "Molotov [%i $] [HUMAN]", g_cZEMolotov.IntValue);
	menu.AddItem("menu4", text);
	Format(text, sizeof(text), "[VIP] Infection Grenade [%i $] [ZOMBIE]", g_cZEInfnade.IntValue);
	if(IsClientVIP(client))
	{
		menu.AddItem("menu5", text);
	}
	else
	{
		menu.AddItem("menu5", text, ITEMDRAW_DISABLED);
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeShopHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				int money = GetEntProp(client, Prop_Send, "m_iAccount");
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				char szBoughtItem[64];
				
				if(g_bInfected[client] == false)
				{	
					if (StrEqual(szItem, "menu1"))
					{
						if(money >= g_cZEHealthShot.IntValue)
						{
							GivePlayerItem(client, "weapon_healthshot");
							SetEntProp(client, Prop_Send, "m_iAccount", money - g_cZEHealthShot.IntValue);
							spended[client] += g_cZEHealthShot.IntValue;
							Format(szBoughtItem, sizeof(szBoughtItem), "HealthShot");	
							CPrintToChat(client, " \x04[ZE-Shop]\x01 %t", "bought_item", szBoughtItem);
						}
						else
						{
							CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_money");
							openShop(client);
						}
					}
					else if (StrEqual(szItem, "menu2"))
					{
						if(money >= g_cZEHeNade.IntValue)
						{
							GivePlayerItem(client, "weapon_hegrenade");
							g_bFireHE[client] = true;
							SetEntProp(client, Prop_Send, "m_iAccount", money - g_cZEHeNade.IntValue);
							spended[client] += g_cZEHeNade.IntValue;
							Format(szBoughtItem, sizeof(szBoughtItem), "Fire Grenade");	
							CPrintToChat(client, " \x04[ZE-Shop]\x01 %t", "bought_item", szBoughtItem);
						}
						else
						{
							CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_money");
							openShop(client);
						}
					}
					else if (StrEqual(szItem, "menu3"))
					{
						if(money >= g_cZEFlashNade.IntValue)
						{
							GivePlayerItem(client, "weapon_decoy");
							g_bFreezeFlash[client] = true;
							SetEntProp(client, Prop_Send, "m_iAccount", money - g_cZEFlashNade.IntValue);
							spended[client] += g_cZEFlashNade.IntValue;
							Format(szBoughtItem, sizeof(szBoughtItem), "Freeze Grenade");	
							CPrintToChat(client, " \x04[ZE-Shop]\x01 %t", "bought_item", szBoughtItem);
						}
						else
						{
							CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_money");
							openShop(client);
						}
					}
					else if (StrEqual(szItem, "menu4"))
					{
						if(money >= g_cZEMolotov.IntValue)
						{
							GivePlayerItem(client, "weapon_molotov");
							SetEntProp(client, Prop_Send, "m_iAccount", money - g_cZEMolotov.IntValue);
							spended[client] += g_cZEMolotov.IntValue;
							Format(szBoughtItem, sizeof(szBoughtItem), "Molotov");	
							CPrintToChat(client, " \x04[ZE-Shop]\x01 %t", "bought_item", szBoughtItem);
						}
						else
						{
							CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_money");
							openShop(client);
						}
					}
					else if (StrEqual(szItem, "menu5"))
					{
						CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "no_zombie");
						openShop(client);
					}
				}
				else if(g_bInfected[client] == true)
				{
					if (StrEqual(szItem, "menu5"))
					{
						if(money >= g_cZEInfnade.IntValue)
						{
							if(g_cZEInfnadeusages.IntValue > i_binfnade)
							{
								GivePlayerItem(client, "weapon_smokegrenade");
								g_bInfectNade[client] = true;
								SetEntProp(client, Prop_Send, "m_iAccount", money - g_cZEInfnade.IntValue);
								spended[client] += g_cZEHealthShot.IntValue;
								Format(szBoughtItem, sizeof(szBoughtItem), "Infection Grenade");	
								CPrintToChat(client, " \x04[ZE-Shop]\x01 %t", "bought_item", szBoughtItem);
								i_binfnade++;
							}
							else
							{
								CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_infection_nades");
								openShop(client);
							}
						}
						else
						{
							CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_money");
							openShop(client);
						}
					}
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

//*****ADMIN MENU*****
void openAdmin(int client)
{
	Menu menu = new Menu(mZeAdminHandler);
	
	menu.SetTitle("[Admin-Menu] Main Menu:");
	
	if(IsClientAdmin(client))
	{
		menu.AddItem("menu1", "Change team");
		if(g_bPause == true)
		{
			menu.AddItem("menu2", "Pause infection timer [ACTIVE]");
		}
		else
		{
			menu.AddItem("menu2", "Pause infection timer");
		}
		menu.AddItem("menu3", "Infection Ban");
	}
	else
	{
		menu.AddItem("menu1", "Change team", ITEMDRAW_DISABLED);
		menu.AddItem("menu2", "Pause infection timer", ITEMDRAW_DISABLED);
		menu.AddItem("menu3", "Infection Ban", ITEMDRAW_DISABLED);
	}
	menu.AddItem("menu4", "Leader");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeAdminHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				if (StrEqual(szItem, "menu1"))
				{
					openSwapTeam(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					if(i_Infection > 0)
					{
						if(g_bPause == false)
						{
							g_bPause = true;
							CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_timer_paused", client);
							openAdmin(client);
						}
						else
						{
							g_bPause = false;
							CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_timer_unpaused", client);
							openAdmin(client);
						}
					}
					else
					{
						CReplyToCommand(client, " \x04[ZE-Admin]\x01 %t", "nextround_infection_timer");
						openAdmin(client);
					}
				}
				else if (StrEqual(szItem, "menu3"))
				{
					openInfectionBan(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					openLeader(client);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openLeader(int client)
{
	Menu menu = new Menu(mZeLeaderHandler);
	
	menu.SetTitle("[Leader] Main Menu:");
	
	if(IsClientAdmin(client))
	{
		menu.AddItem("menu1", "Choose leader");
	}
	menu.AddItem("menu2", "Sprites & Markers");
	if(g_bBeacon[client] == true)
	{
		menu.AddItem("menu3", "Beacon [ON]");
	}
	else
	{
		menu.AddItem("menu3", "Beacon [OFF]");
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeLeaderHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				if (StrEqual(szItem, "menu1"))
				{
					openChooseLeader(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					openSpritesMarkers(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					if(g_bBeacon[client] == true)
					{
						g_bBeacon[client] = false;
						if (H_Beacon[client] != null)
						{
							KillTimer(H_Beacon[client]);
							H_Beacon[client] = null;	
							CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "beacon_off");
							openLeader(client);
						}
					}
					else
					{
						g_bBeacon[client] = true;
						H_Beacon[client] = CreateTimer(0.2, Timer_Beacon, client, TIMER_REPEAT);
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "beacon_on");
						openLeader(client);
					}
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openSpritesMarkers(int client)
{
	Menu menu = new Menu(mZeLeaderSpritesHandler);
	
	menu.SetTitle("[Leader] Sprites & Markers:");
	
	if(g_bMarker == true)
	{
		menu.AddItem("menu1", "Defend Marker [ACTIVE]");
	}
	else
	{
		menu.AddItem("menu1", "Defend Marker");
	}
	menu.AddItem("menu2", "[Remove Marker]");
	if(i_typeofsprite[client] > 0)
	{
		if(i_typeofsprite[client] == 1)
		{
			menu.AddItem("menu3", "Defend Sprite [ACTIVE]");
			menu.AddItem("menu4", "Follow-me Sprite");
		}
		else
		{
			menu.AddItem("menu3", "Defend Sprite");
			menu.AddItem("menu4", "Follow-me Sprite [ACTIVE]");
		}
	}
	else
	{
		menu.AddItem("menu3", "Defend Sprite");
		menu.AddItem("menu4", "Follow-me Sprite");
	}
	menu.AddItem("menu5", "[Remove Sprite]");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeLeaderSpritesHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				if(g_bInfected[client] == false && g_bIsLeader[client] == true)
				{
					if (StrEqual(szItem, "menu1"))
					{
						RemoveMarker(client);
						i_markerEntities[client] = SpawnMarker(client, DEFEND);
						g_bMarker = true;
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "defend_marker_spawned");
						openSpritesMarkers(client);
					}
					else if (StrEqual(szItem, "menu2"))
					{
						g_bMarker = false;
						RemoveMarker(client);
						openSpritesMarkers(client);
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "defend_marker_removed");
					}
					else if (StrEqual(szItem, "menu3"))
					{
						RemoveSprite(client);
						i_spriteEntities[client] = AttachSprite(client, DEFEND);
						i_typeofsprite[client] = 1;
						EmitSoundToAll("ze_premium/ze-defend.mp3", client);
						openSpritesMarkers(client);
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "chosen_defend_sprite");
					}
					else if (StrEqual(szItem, "menu4"))
					{
						RemoveSprite(client);
						i_spriteEntities[client] = AttachSprite(client, FOLLOWME);
						i_typeofsprite[client] = 2;
						EmitSoundToAll("ze_premium/ze-folowme.mp3", client);
						openSpritesMarkers(client);
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "chosen_follow_sprite");
					}
					else if (StrEqual(szItem, "menu5"))
					{
						RemoveSprite(client);
						i_typeofsprite[client] = 0;
						openSpritesMarkers(client);
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "sprite_removed");
					}
				}
				else
				{
					CReplyToCommand(client, " \x04[ZE-Leader]\x01 %t", "no_human");
					CReplyToCommand(client, " \x04[ZE-Leader]\x01 %t", "no_leader");
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openSwapTeam(int client)
{
	char info1[255];
	
	Menu menu = new Menu(mRoundBanHandler);
	
	menu.SetTitle("[Change Team] Choose player:");
	
	int iValidCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			char userid[11];
			char username[MAX_NAME_LENGTH];
			IntToString(GetClientUserId(i), userid, sizeof(userid));
			if(g_bInfected[i] == false)
			{
				Format(username, sizeof(username), "%N [CT]", i);
			}
			else
			{
				Format(username, sizeof(username), "%N [T]", i);
			}
			menu.AddItem(userid, username);
			iValidCount++;
		}
	}

	if (iValidCount == 0)
	{
		Format(info1, sizeof(info1), "NO PLAYERS", client);
		menu.AddItem("", info1, ITEMDRAW_DISABLED);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int mRoundBanHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{	
				char name[32];
				menu.GetItem(index, name, sizeof(name));
				int user = GetClientOfUserId(StringToInt(name));
				
				if(IsValidClient(user))
				{
					if(g_bInfected[user] == false)
					{
						CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "swaped_to_zombies", user, client);
						CS_SwitchTeam(user, CS_TEAM_T);
						g_bInfected[user] = true;
						RemoveGuns(user);
						DisableSpells(user);
						SetPlayerAsZombie(user);
						Call_StartForward(gF_ClientInfected);
						Call_PushCell(user);
						Call_PushCell(client);
						Call_Finish();
					}
					else
					{
						CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "swaped_to_humans", user, client);
						CS_SwitchTeam(user, CS_TEAM_CT);
						g_bInfected[user] = false;
						DisableSpells(user);
						SetPlayerAsHuman(user);
						SetEntityGravity(user, 1.0);
						Call_StartForward(gF_ClientHumanPost);
						Call_PushCell(user);
						Call_Finish();
					}
					openSwapTeam(client);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openChooseLeader(int client)
{
	char info1[255];
	
	Menu menu = new Menu(mLeaderChooseHandler);
	
	menu.SetTitle("[Leader] Choose player:");
	
	int iValidCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i))
		{
			char userid[11];
			char username[MAX_NAME_LENGTH];
			IntToString(GetClientUserId(i), userid, sizeof(userid));
			if(g_bInfected[i] == false)
			{
				if(g_bIsLeader[i] == true)
				{
					Format(username, sizeof(username), "%N [L]", i);
				}
				else
				{
					Format(username, sizeof(username), "%N", i);
				}
				menu.AddItem(userid, username);
				iValidCount++;
			}
		}
	}

	if (iValidCount == 0)
	{
		Format(info1, sizeof(info1), "NO PLAYERS", client);
		menu.AddItem("", info1, ITEMDRAW_DISABLED);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int mLeaderChooseHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{	
				char name[32];
				menu.GetItem(index, name, sizeof(name));
				int user = GetClientOfUserId(StringToInt(name));
				
				if(IsValidClient(user))
				{
					if(g_bInfected[user] == false && IsPlayerAlive(user))
					{
						for (int i = 1; i <= MaxClients; i++)
						{
							if (IsValidClient(i))
							{
								if(g_bIsLeader[i] == true)
								{
									g_bIsLeader[i] = false;
									CPrintToChat(i, " \x04[ZE-Leader]\x01 %t", "removed_from_leader");
								}
							}
						}
						CPrintToChatAll(" \x04[ZE-Leader]\x01 %t", "new_leader", user);
						g_bIsLeader[user] = true;
					}
					else
					{
						CReplyToCommand(client, " \x04[ZE-Leader]\x01 %t", "player_is_dead");
						openChooseLeader(client);
					}
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openInfectionBan(int client)
{
	char info1[255];
	
	Menu menu = new Menu(mInfectionChooseHandler);
	
	menu.SetTitle("[Infection Ban] Choose player:");
	
	int iValidCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			char userid[11];
			char username[MAX_NAME_LENGTH];
			IntToString(GetClientUserId(i), userid, sizeof(userid));
			Format(username, sizeof(username), "%N [%i]", i, i_infectionban[i]);
			menu.AddItem(userid, username);
			iValidCount++;
		}
	}

	if (iValidCount == 0)
	{
		Format(info1, sizeof(info1), "NO PLAYERS", client);
		menu.AddItem("", info1, ITEMDRAW_DISABLED);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int mInfectionChooseHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{	
				char name[32];
				menu.GetItem(index, name, sizeof(name));
				int user = GetClientOfUserId(StringToInt(name));
				
				if(IsValidClient(user))
				{
					g_hDataPackUser = CreateDataPack();
					WritePackCell(g_hDataPackUser, user);
					openInfectionLong(client);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openInfectionLong(int client)
{
	Menu menu = new Menu(mZeInfectionLongHandler);
	
	menu.SetTitle("[Infection Ban] How long?");
	
	menu.AddItem("menu1", "2 rounds");
	menu.AddItem("menu2", "5 rounds");
	menu.AddItem("menu3", "10 rounds");
	menu.AddItem("menu4", "[Remove ban]");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeInfectionLongHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				ResetPack(g_hDataPackUser);
				int user = ReadPackCell(g_hDataPackUser);
				int newiban;
				char szSteamId[32], szQuery[512];
				GetClientAuthId(user, AuthId_Engine, szSteamId, sizeof(szSteamId));
				
				if (StrEqual(szItem, "menu1"))
				{
					newiban = i_infectionban[user] + 2;
					i_infectionban[user] = newiban;
					g_hDatabase.Format(szQuery, sizeof(szQuery), "UPDATE ze_premium_sql SET infectionban = '%i' WHERE steamid='%s'", newiban, szSteamId);
					g_hDatabase.Query(SQL_Error, szQuery);
					CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_ban", user, newiban);
					openInfectionBan(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					newiban = i_infectionban[user] + 5;
					i_infectionban[user] = newiban;
					g_hDatabase.Format(szQuery, sizeof(szQuery), "UPDATE ze_premium_sql SET infectionban = '%i' WHERE steamid='%s'", newiban, szSteamId);
					g_hDatabase.Query(SQL_Error, szQuery);
					CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_ban", user, newiban);
					openInfectionBan(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					newiban = i_infectionban[user] + 10;
					i_infectionban[user] = newiban;
					g_hDatabase.Format(szQuery, sizeof(szQuery), "UPDATE ze_premium_sql SET infectionban = '%i' WHERE steamid='%s'", newiban, szSteamId);
					g_hDatabase.Query(SQL_Error, szQuery);
					CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_ban", user, newiban);
					openInfectionBan(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					newiban = 0;
					i_infectionban[user] = newiban;
					g_hDatabase.Format(szQuery, sizeof(szQuery), "UPDATE ze_premium_sql SET infectionban = '%i' WHERE steamid='%s'", newiban, szSteamId);
					g_hDatabase.Query(SQL_Error, szQuery);
					CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_unban", user);
					openInfectionBan(client);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}