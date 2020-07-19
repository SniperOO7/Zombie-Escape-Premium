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
					if(GetClientTeam(client) == CS_TEAM_CT || i_Infection > 0)
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
					openWeaponsRifle(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					openWeaponsHeavy(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					openWeaponsSmg(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					openWeaponsPistols(client);
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
	}
}

void openWeaponsRifle(int client)
{
	Menu menu = new Menu(mZeRifleGunsHandler);
	
	menu.SetTitle("[Weapons] Rifle Guns:");
	
	menu.AddItem("menu1", "AK-47");
	menu.AddItem("menu2", "M4A4");
	menu.AddItem("menu3", "M4A1-S");
	menu.AddItem("menu4", "AUG");
	menu.AddItem("menu5", "SG 553");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeRifleGunsHandler(Menu menu, MenuAction action, int client, int index)
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
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_ak47");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_m4a1");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_m4a1_silencer");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_aug");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu5"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_sg556");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
			}
		}
	}
}

void openWeaponsHeavy(int client)
{
	Menu menu = new Menu(mZeHeavyGunsHandler);
	
	menu.SetTitle("[Weapons] Heavy Guns:");
	
	menu.AddItem("menu1", "M249");
	menu.AddItem("menu2", "NEGEV");
	menu.AddItem("menu3", "NOVA");
	menu.AddItem("menu4", "XM1014");
	menu.AddItem("menu5", "SAWEDOFF");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeHeavyGunsHandler(Menu menu, MenuAction action, int client, int index)
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
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_m249");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_negev");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_nova");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_xm1014");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu5"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_sawedoff");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
			}
		}
	}
}

void openWeaponsSmg(int client)
{
	Menu menu = new Menu(mZeSMGGunsHandler);
	
	menu.SetTitle("[Weapons] SMG Guns:");
	
	menu.AddItem("menu1", "P90");
	menu.AddItem("menu2", "PP-Bizon");
	menu.AddItem("menu3", "MP7");
	menu.AddItem("menu4", "MP5-SD");
	menu.AddItem("menu5", "UMP-45");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeSMGGunsHandler(Menu menu, MenuAction action, int client, int index)
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
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_p90");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_bizon");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_mp7");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_mp5sd");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu5"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_ump45");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
			}
		}
	}
}

void openWeaponsPistols(int client)
{
	Menu menu = new Menu(mZePistolGunsHandler);
	
	menu.SetTitle("[Weapons] Pistol Guns:");
	
	menu.AddItem("menu1", "Deagle");
	menu.AddItem("menu2", "Dual Berettas");
	menu.AddItem("menu3", "Tec-9");
	menu.AddItem("menu4", "Revolver");
	menu.AddItem("menu5", "P250");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZePistolGunsHandler(Menu menu, MenuAction action, int client, int index)
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
					Format(Secondary_Gun[client], sizeof(Secondary_Gun), "weapon_deagle");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Secondary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					Format(Secondary_Gun[client], sizeof(Secondary_Gun), "weapon_elite");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Secondary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					Format(Secondary_Gun[client], sizeof(Secondary_Gun), "weapon_tec9");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Secondary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					Format(Secondary_Gun[client], sizeof(Secondary_Gun), "weapon_revolver");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Secondary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu5"))
				{
					Format(Secondary_Gun[client], sizeof(Secondary_Gun), "weapon_p250");
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Secondary_Gun[client]);
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
					openWeapons(client);
				}
			}
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
					openHumanClass(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					openZombieClass(client);
				}
			}
		}
	}
}

void openHumanClass(int client)
{
	Menu menu = new Menu(mZeHumanClassHandler);
	
	menu.SetTitle("[Human Class] Choose:");
	
	menu.AddItem("menu1", "Bomber-Man [+ GRENADE]");
	menu.AddItem("menu2", "Healer [+ HEALTH-SHOT]");
	menu.AddItem("menu3", "Heavy-Man [+ HP]");
	if(IsClientVIP(client))
	{
		menu.AddItem("menu4", "[VIP] Big Boss [+ EXTRA LIFE]");
	}
	else
	{
		menu.AddItem("menu4", "[VIP] Big Boss [+ EXTRA LIFE]", ITEMDRAW_DISABLED);
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeHumanClassHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				char szClass[64];
				
				if (StrEqual(szItem, "menu1"))
				{ 
					i_hclass[client] = 1;
					Format(szClass, sizeof(szClass), "Bomber-Man");	
					CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", szClass);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					i_hclass[client] = 2;
					Format(szClass, sizeof(szClass), "Healer");	
					CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", szClass);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					i_hclass[client] = 3;
					Format(szClass, sizeof(szClass), "Heavy-Man");	
					CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", szClass);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					i_hclass[client] = 4;
					Format(szClass, sizeof(szClass), "Big Boss");	
					CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", szClass);
				}
			}
		}
	}
}

void openZombieClass(int client)
{
	Menu menu = new Menu(mZeZombieClassHandler);
	
	menu.SetTitle("[Zombie Class] Choose:");
	
	menu.AddItem("menu1", "Runner [++ SPEED]");
	menu.AddItem("menu2", "Tank [++ HP]");
	menu.AddItem("menu3", "Gravity [++ GRAVITY]");
	if(IsClientVIP(client))
	{
		menu.AddItem("menu4", "[VIP] Evil Clown [+ SPEED, HP]");
	}
	else
	{
		menu.AddItem("menu4", "[VIP] Evil Clown [+ SPEED, HP]", ITEMDRAW_DISABLED);
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeZombieClassHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				char szClass[64];
				
				if (StrEqual(szItem, "menu1"))
				{ 
					i_zclass[client] = 1;
					Format(szClass, sizeof(szClass), "Runner");	
					CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", szClass);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					i_zclass[client] = 2;
					Format(szClass, sizeof(szClass), "Tank");	
					CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", szClass);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					i_zclass[client] = 3;
					Format(szClass, sizeof(szClass), "Gravity");	
					CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", szClass);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					i_zclass[client] = 4;
					Format(szClass, sizeof(szClass), "Evil Clown");	
					CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", szClass);
				}
			}
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
	Format(text, sizeof(text), "Freeze Grenade [%i $] [HUMAN]", g_cZEFlashNade.IntValue);
	menu.AddItem("menu3", text);
	Format(text, sizeof(text), "Molotov [%i $] [HUMAN]", g_cZEMolotov.IntValue);
	menu.AddItem("menu4", text);
	Format(text, sizeof(text), "Infetion Grenade [%i $] [ZOMBIE]", g_cZEInfnade.IntValue);
	menu.AddItem("menu5", text);
	
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
				
				if(GetClientTeam(client) == CS_TEAM_CT || i_Infection > 0 && IsPlayerAlive(client))
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
	if(typeofsprite[client] > 0)
	{
		if(typeofsprite[client] == 1)
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
				
				if (StrEqual(szItem, "menu1"))
				{
					RemoveMarker(client);
					markerEntities[client] = SpawnMarker(client, DEFEND);
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
					spriteEntities[client] = AttachSprite(client, DEFEND);
					typeofsprite[client] = 1;
					EmitSoundToAll("ze_premium/ze-defend.mp3", client);
					openSpritesMarkers(client);
					CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "chosen_defend_sprite");
				}
				else if (StrEqual(szItem, "menu4"))
				{
					RemoveSprite(client);
					spriteEntities[client] = AttachSprite(client, FOLLOWME);
					typeofsprite[client] = 2;
					EmitSoundToAll("ze_premium/ze-folowme.mp3", client);
					openSpritesMarkers(client);
					CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "chosen_follow_sprite");
				}
				else if (StrEqual(szItem, "menu5"))
				{
					RemoveSprite(client);
					typeofsprite[client] = 0;
					openSpritesMarkers(client);
					CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "sprite_removed");
				}
			}
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
			if(GetClientTeam(i) == CS_TEAM_CT)
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
					if(GetClientTeam(user) == CS_TEAM_CT)
					{
						CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "swaped_to_zombies", user, client);
						CS_SwitchTeam(user, CS_TEAM_T);
						g_bInfected[user] = true;
						RemoveGuns(user);
						DisableSpells(user);
						SetEntityModel(user, ZOMBIEMODEL);
						SetEntityHealth(user, g_cZEZombieHP.IntValue);
						SetEntPropFloat(user, Prop_Data, "m_flLaggedMovementValue", g_cZEZombieSpeed.FloatValue);
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
						SetEntityModel(user, HUMANMODEL);
						SetEntityHealth(user, g_cZEHumanHP.IntValue);
						SetEntPropFloat(user, Prop_Data, "m_flLaggedMovementValue", 1.0);
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
			if(GetClientTeam(i) == CS_TEAM_CT || i_Infection > 0)
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
					if(GetClientTeam(user) == CS_TEAM_CT || i_Infection > 0 && IsPlayerAlive(user))
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
			char sBuffer[12];
			GetClientCookie(i, H_hAntiDisconnect, sBuffer, sizeof(sBuffer));
			i_antidisconnect[i] = StringToInt(sBuffer);
			Format(username, sizeof(username), "%N [%i]", i, i_antidisconnect[i]);
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
				int ban;
				
				if (StrEqual(szItem, "menu1"))
				{
					char sBuffer[12];
					GetClientCookie(user, H_hAntiDisconnect, sBuffer, sizeof(sBuffer));
					int amout = StringToInt(sBuffer);
					ban = 2 + amout;
					char defamout[16];
					Format(defamout, sizeof(defamout), "%i", ban);
					SetClientCookie(user, H_hAntiDisconnect, defamout);
					CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_ban", user, ban);
					openInfectionBan(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					char sBuffer[12];
					GetClientCookie(user, H_hAntiDisconnect, sBuffer, sizeof(sBuffer));
					int amout = StringToInt(sBuffer);
					ban = 5 + amout;
					char defamout[16];
					Format(defamout, sizeof(defamout), "%i", ban);
					SetClientCookie(user, H_hAntiDisconnect, defamout);
					CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_ban", user, ban);
					openInfectionBan(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					char sBuffer[12];
					GetClientCookie(user, H_hAntiDisconnect, sBuffer, sizeof(sBuffer));
					int amout = StringToInt(sBuffer);
					ban = 10 + amout;
					char defamout[16];
					Format(defamout, sizeof(defamout), "%i", ban);
					SetClientCookie(user, H_hAntiDisconnect, defamout);
					CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_ban", user, ban);
					openInfectionBan(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					SetClientCookie(user, H_hAntiDisconnect, "0");
					CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_unban", user);
					openInfectionBan(client);
				}
			}
		}
	}
}