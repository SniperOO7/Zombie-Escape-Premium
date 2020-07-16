void openMenu(int client)
{
	Menu menu = new Menu(mZeHandler);
	
	menu.SetTitle("[Zombie Escape] Main menu:");
	
	menu.AddItem("menu1", "Weapons");
	menu.AddItem("menu2", "Zombie/Human classes");
	menu.AddItem("menu3", "Human Shop");
	if(IsClientAdmin(client) || IsClientLeader(client))
	{
		menu.AddItem("menu4", "Admin menu");
	}
	else
	{
		menu.AddItem("menu4", "Admin menu [NO ACCES]", ITEMDRAW_DISABLED);
	}
	
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
						ReplyToCommand(client, " \x04[Zombie-Escape]\x01 You have to be a human");
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
						PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen to \x07disable\x01 same guns every round");
						g_bSamegun[client] = false;
						openWeapons(client);
					}
					else
					{
						PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen to \x04enable\x01 same guns every round");
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
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_m4a1");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_m4a1_silencer");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_aug");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu5"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_sg556");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
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
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_negev");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_nova");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_xm1014");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu5"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_sawedoff");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
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
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_bizon");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_mp7");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_mp5sd");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu5"))
				{
					Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_ump45");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Primary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
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
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Secondary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					Format(Secondary_Gun[client], sizeof(Secondary_Gun), "weapon_elite");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Secondary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu3"))
				{
					Format(Secondary_Gun[client], sizeof(Secondary_Gun), "weapon_tec9");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Secondary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu4"))
				{
					Format(Secondary_Gun[client], sizeof(Secondary_Gun), "weapon_revolver");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Secondary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
					openWeapons(client);
				}
				else if (StrEqual(szItem, "menu5"))
				{
					Format(Secondary_Gun[client], sizeof(Secondary_Gun), "weapon_p250");
					PrintToChat(client, " \x04[ZE-Weapons]\x01 You chosen \x06%s \x01gun", Secondary_Gun[client]);
					PrintToChat(client, " \x04[ZE-Weapons]\x01 To get it, write in chat: \x06/get");
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
				
				if (StrEqual(szItem, "menu1"))
				{ 
					i_hclass[client] = 1;
					PrintToChat(client, " \x04[ZE-Class]\x01 You chosen \x04Bomber-Man \x01class, you will get it after you respawn");
				}
				else if (StrEqual(szItem, "menu2"))
				{
					i_hclass[client] = 2;
					PrintToChat(client, " \x04[ZE-Class]\x01 You chosen \x04Healer \x01class, you will get it after you respawn");
				}
				else if (StrEqual(szItem, "menu3"))
				{
					i_hclass[client] = 3;
					PrintToChat(client, " \x04[ZE-Class]\x01 You chosen \x04Heavy-man \x01class, you will get it after you respawn");
				}
				else if (StrEqual(szItem, "menu4"))
				{
					i_hclass[client] = 4;
					PrintToChat(client, " \x04[ZE-Class]\x01 You chosen \x04Big Boss \x01class, you will get it after you respawn");
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
				
				if (StrEqual(szItem, "menu1"))
				{ 
					i_zclass[client] = 1;
					PrintToChat(client, " \x04[ZE-Class]\x01 You chosen \x04Runner \x01class, you will get it after you respawn");
				}
				else if (StrEqual(szItem, "menu2"))
				{
					i_zclass[client] = 2;
					PrintToChat(client, " \x04[ZE-Class]\x01 You chosen \x04Tank \x01class, you will get it after you respawn");
				}
				else if (StrEqual(szItem, "menu3"))
				{
					i_zclass[client] = 3;
					PrintToChat(client, " \x04[ZE-Class]\x01 You chosen \x04Evil Clown \x01class, you will get it after you respawn");
				}
				else if (StrEqual(szItem, "menu4"))
				{
					i_zclass[client] = 4;
					PrintToChat(client, " \x04[ZE-Class]\x01 You chosen \x04Evil Clown \x01class, you will get it after you respawn");
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
	
	Format(text, sizeof(text), "Health-Shot [%i $]", g_cZEHealthShot.IntValue);
	menu.AddItem("menu1", text);
	Format(text, sizeof(text), "He Grenade [%i $]", g_cZEHeNade.IntValue);
	menu.AddItem("menu2", text);
	Format(text, sizeof(text), "Flash Grenade [%i $]", g_cZEFlashNade.IntValue);
	menu.AddItem("menu3", text);
	Format(text, sizeof(text), "Molotov [%i $]", g_cZEMolotov.IntValue);
	menu.AddItem("menu4", text);
	
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
				if(GetClientTeam(client) == CS_TEAM_CT || i_Infection > 0 && IsPlayerAlive(client))
				{
					int money = GetEntProp(client, Prop_Send, "m_iAccount");
					char szItem[32];
					menu.GetItem(index, szItem, sizeof(szItem));
					
					if (StrEqual(szItem, "menu1"))
					{
						if(money >= g_cZEHealthShot.IntValue)
						{
							GivePlayerItem(client, "weapon_healthshot");
							SetEntProp(client, Prop_Send, "m_iAccount", money - g_cZEHealthShot.IntValue);
							spended[client] += g_cZEHealthShot.IntValue;
							PrintToChat(client, " \x04[ZE-Shop]\x01 You bought \x06healthshot");
						}
						else
						{
							ReplyToCommand(client, " \x04[ZE-Shop]\x01 You don't have enough money!");
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
							PrintToChat(client, " \x04[ZE-Shop]\x01 You bought \x06he grenade");
						}
						else
						{
							ReplyToCommand(client, " \x04[ZE-Shop]\x01 You don't have enough money!");
							openShop(client);
						}
					}
					else if (StrEqual(szItem, "menu3"))
					{
						if(money >= g_cZEFlashNade.IntValue)
						{
							GivePlayerItem(client, "weapon_flashbang");
							g_bFreezeFlash[client] = true;
							SetEntProp(client, Prop_Send, "m_iAccount", money - g_cZEFlashNade.IntValue);
							spended[client] += g_cZEFlashNade.IntValue;
							PrintToChat(client, " \x04[ZE-Shop]\x01 You bought \x06flash grenade");
						}
						else
						{
							ReplyToCommand(client, " \x04[ZE-Shop]\x01 You don't have enough money!");
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
							PrintToChat(client, " \x04[ZE-Shop]\x01 You bought \x06molotov");
						}
						else
						{
							ReplyToCommand(client, " \x04[ZE-Shop]\x01 You don't have enough money!");
							openShop(client);
						}
					}
				}
				else
				{
					ReplyToCommand(client, " \x04[ZE-Shop]\x01 You have to be a human and alive!");
					openShop(client);
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
	}
	else
	{
		menu.AddItem("menu1", "Change team", ITEMDRAW_DISABLED);
		menu.AddItem("menu2", "Pause infection timer", ITEMDRAW_DISABLED);
	}
	menu.AddItem("menu3", "Leader");
	
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
							PrintToChatAll(" \x04[ZE-Admin]\x01 Admin\x06 %N\x01 paused infection timer!", client);
							openAdmin(client);
						}
						else
						{
							g_bPause = false;
							PrintToChatAll(" \x04[ZE-Admin]\x01 Admin\x06 %N\x01 unpased infection timer!", client);
							openAdmin(client);
						}
					}
					else
					{
						ReplyToCommand(client, " \x04[ZE-Admin]\x01 Infection timer expired, wait for next round!");
						openAdmin(client);
					}
				}
				else if (StrEqual(szItem, "menu3"))
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
							PrintToChat(client, " \x04[ZE-Leader]\x01 You turned \x07off \x01beacon");
							openLeader(client);
						}
					}
					else
					{
						g_bBeacon[client] = true;
						H_Beacon[client] = CreateTimer(0.2, Timer_Beacon, client, TIMER_REPEAT);
						PrintToChat(client, " \x04[ZE-Leader]\x01 You turned \x04on \x01beacon");
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
					PrintToChat(client, " \x04[ZE-Leader]\x01 You \x04spawned \x01DEFEND marker");
					openSpritesMarkers(client);
				}
				else if (StrEqual(szItem, "menu2"))
				{
					g_bMarker = false;
					RemoveMarker(client);
					openSpritesMarkers(client);
					PrintToChat(client, " \x04[ZE-Leader]\x01 You \x07removed \x01DEFEND marker");
				}
				else if (StrEqual(szItem, "menu3"))
				{
					RemoveSprite(client);
					spriteEntities[client] = AttachSprite(client, DEFEND);
					typeofsprite[client] = 1;
					EmitSoundToAll("ze_premium/ze-defend.mp3", client);
					openSpritesMarkers(client);
					PrintToChat(client, " \x04[ZE-Leader]\x01 You \x04chosen \x01DEFEND sprite");
				}
				else if (StrEqual(szItem, "menu4"))
				{
					RemoveSprite(client);
					spriteEntities[client] = AttachSprite(client, FOLLOWME);
					typeofsprite[client] = 2;
					EmitSoundToAll("ze_premium/ze-folowme.mp3", client);
					openSpritesMarkers(client);
					PrintToChat(client, " \x04[ZE-Leader]\x01 You \x04chosen \x01FOLLOW-ME sprite");
				}
				else if (StrEqual(szItem, "menu5"))
				{
					RemoveSprite(client);
					typeofsprite[client] = 0;
					openSpritesMarkers(client);
					PrintToChat(client, " \x04[ZE-Leader]\x01 You \x07removed \x01 your sprite");
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
						PrintToChatAll(" \x04[ZE-Admin]\x01 Player \x04%N\x01 was swaped to \x07ZOMBIES\x01 by \x06%N\x01 admin!", user, client);
						CS_SwitchTeam(user, CS_TEAM_T);
						g_bInfected[user] = true;
						SetEntityModel(user, ZOMBIEMODEL);
						SetEntityHealth(user, g_cZEZombieHP.IntValue);
						SetEntPropFloat(user, Prop_Data, "m_flLaggedMovementValue", g_cZEZombieSpeed.FloatValue);
					}
					else
					{
						PrintToChatAll(" \x04[ZE-Admin]\x01 Player \x04%N\x01 was swaped to \x0BHUMANS\x01 by \x06%N\x01 admin!", user, client);
						CS_SwitchTeam(user, CS_TEAM_CT);
						g_bInfected[user] = false;
						SetEntityModel(user, HUMANMODEL);
						SetEntityHealth(user, g_cZEHumanHP.IntValue);
						SetEntPropFloat(user, Prop_Data, "m_flLaggedMovementValue", 1.0);
						SetEntityGravity(user, 1.0);
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
	
	menu.SetTitle("[Change Team] Choose player:");
	
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
									PrintToChat(i, " \x04[ZE-Leader]\x01 You was \x07removed\x01 from \x06LEADER\x01 position!");
								}
							}
						}
						PrintToChatAll(" \x04[ZE-Leader]\x01 Player \x04%N\x01 is new \x06LEADER\x01!", user);
						g_bIsLeader[user] = true;
					}
					else
					{
						ReplyToCommand(client, " \x04[ZE-Leader]\x01 This player is dead or not human!");
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