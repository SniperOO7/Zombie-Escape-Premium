public Action FirstInfection(Handle timer)
{
	int numberofplayers = GetTeamClientCount(2) + GetTeamClientCount(3);
	if(g_bPause == false && numberofplayers > 0)
	{
		i_Infection--;
	}
	
	if(i_Infection > 0)
	{	
		CheckTimer();
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i))
			{
				int soucet = GetTeamClientCount(2) + GetTeamClientCount(3);
				int numberinfected;
				if(soucet < 4)
				{
					numberinfected = 1;
				}
				else
				{
					numberinfected = soucet / 4;
				}
				float percent = float(soucet) / 100;
				float newpercent = float(numberinfected) / percent;
				SetHudTextParams(-1.0, 0.1, 1.02, 0, 255, 0, 255, 0, 0.0, 0.0, 0.0);
				char sBuffer[12];
				GetClientCookie(i, H_hAntiDisconnect, sBuffer, sizeof(sBuffer));
				i_antidisconnect[i] = StringToInt(sBuffer);
				if(i_antidisconnect[i] > 0)
				{
					ShowHudText(i, -1, "First infected will be: %i sec\nYou will be infected [YOU HAVE: %i INFECTION BANS]", i_Infection, i_antidisconnect[i]);
				}
				else
				{
					ShowHudText(i, -1, "First infected will be: %i sec\nChance to be infected is: +%.1f percent", i_Infection, newpercent);
				}
				char ch_humanclass[64];
				if(i_hclass[i] == 1)
				{
					Format(ch_humanclass, sizeof(ch_humanclass), "Bomber-Man");
				}
				else if(i_hclass[i] == 2)
				{
					Format(ch_humanclass, sizeof(ch_humanclass), "Healer");
				}
				else if(i_hclass[i] == 3)
				{
					Format(ch_humanclass, sizeof(ch_humanclass), "Heavy-Man");
				}
				else if(i_hclass[i] == 4)
				{
					Format(ch_humanclass, sizeof(ch_humanclass), "Big Boss");
				}
				PrintHintText(i, "\n<font color='#FF4500'>CHOSEN GUN:</font>%s | %s\n<font color='#4169E1'>HUMAN CLASS:</font>%s", Primary_Gun[i], Secondary_Gun[i], ch_humanclass);
			}
		}
	}
	
	if(i_Infection <= 0)
	{
		g_bRoundStarted = true;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				char sBuffer[12];
				GetClientCookie(i, H_hAntiDisconnect, sBuffer, sizeof(sBuffer));
				i_antidisconnect[i] = StringToInt(sBuffer);
				if(i_antidisconnect[i] > 0)
				{
					SetZombie(i, true);
				}
				else
				{
					CS_SwitchTeam(i, CS_TEAM_CT);
				}
				SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
			}
		}
		int soucet = GetTeamClientCount(2) + GetTeamClientCount(3);
		int numberinfected;
		if(soucet < 4)
		{
			numberinfected = 1;
		}
		else
		{
			numberinfected = soucet / 4;
		}
		int infection;
		int firstinfected;
		int user;
		int nemesis = 0;
		if(g_cZEZombieRiots.IntValue > 0)
		{
			int riotchance = GetRandomInt(1, 100);
			if(riotchance >= 1 && riotchance <= g_cZEZombieRiots.IntValue)
			{
				i_Riotround = 1;
				i_SpecialRound = 1;
				CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "riot_round");
				CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "riot_round");
				CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "riot_round");
				EmitSoundToAll("ze_premium/ze-riotround.mp3");
			}
		}
		
		do
		{
			infection++;
			if(infection <= 1)
			{	
				firstinfected = GetRandomsPlayer();
				g_bInfected[firstinfected] = true;
				CS_SwitchTeam(firstinfected, CS_TEAM_T);
				CS_RespawnPlayer(firstinfected);
				int primweapon = GetPlayerWeaponSlot(firstinfected, CS_SLOT_PRIMARY);
				if(IsValidEdict(primweapon) && primweapon != -1)
				{
					RemoveEdict(primweapon);
				}
				int secweapon = GetPlayerWeaponSlot(firstinfected, CS_SLOT_SECONDARY);
				if(IsValidEdict(secweapon) && secweapon != -1)
				{
					RemoveEdict(secweapon);
				}
				if(g_bIsLeader[firstinfected] == true)
				{
					g_bIsLeader[firstinfected] = false;
					CPrintToChatAll(" \x04[ZE-Leader]\x01 %t", "leader_died", firstinfected);
				}
				SetEntityHealth(firstinfected, g_cZEMotherZombieHP.IntValue);
				if(spended[firstinfected] > 0)
				{
					int money = GetEntProp(firstinfected, Prop_Send, "m_iAccount");
					SetEntProp(firstinfected, Prop_Send, "m_iAccount", money + spended[firstinfected]);
				}
				if(i_Riotround > 0 && g_cZEZombieShieldType.IntValue > 0)
				{
					GivePlayerItem(firstinfected, "weapon_shield");
				}
				if(g_cZENemesis.IntValue > 0 && i_Riotround == 0)
				{
					int nemesischance = GetRandomInt(1, 100);
					if(nemesischance >= 1 && nemesischance <= g_cZENemesis.IntValue)
					{
						EmitSoundToAll("ze_premium/ze-nemesis.mp3");
						nemesis = 1;
						i_SpecialRound = 1;
						g_bIsNemesis[firstinfected] = true;
						SetEntityHealth(firstinfected, g_cZENemesisHP.IntValue);
						SetEntityModel(firstinfected, NEMESISMODEL);
						SetEntPropFloat(firstinfected, Prop_Data, "m_flLaggedMovementValue", g_cZENemesisSpeed.FloatValue);
						SetEntityGravity(firstinfected, g_cZENemesisGravity.FloatValue);
					}
				}
				
				if(nemesis == 0)
				{
					int random = GetRandomInt(1, 3);
					char soundPath[PLATFORM_MAX_PATH];
					Format(soundPath, sizeof(soundPath), "ze_premium/ze-firstzm%i.mp3", random);
					EmitSoundToAll(soundPath);
				}
				CreateTimer(g_cZEInfectionTime.FloatValue, AntiDisconnect, firstinfected);
				g_bAntiDisconnect[firstinfected] = true;
			}
			else
			{
				user = GetRandomsPlayer();
				g_bInfected[user] = true;
				CS_SwitchTeam(user, CS_TEAM_T);
				CS_RespawnPlayer(user);
				int primweapon = GetPlayerWeaponSlot(user, CS_SLOT_PRIMARY);
				if(IsValidEdict(primweapon) && primweapon != -1)
				{
					RemoveEdict(primweapon);
				}
				int secweapon = GetPlayerWeaponSlot(user, CS_SLOT_SECONDARY);
				if(IsValidEdict(secweapon) && secweapon != -1)
				{
					RemoveEdict(secweapon);
				}
				if(g_bIsLeader[user] == true)
				{
					g_bIsLeader[user] = false;
					CPrintToChatAll(" \x04[ZE-Leader]\x01 %t", "leader_died", user);
				}
				if(spended[user] > 0)
				{
					int money = GetEntProp(user, Prop_Send, "m_iAccount");
					SetEntProp(user, Prop_Send, "m_iAccount", money + spended[user]);
				}
				if(i_Riotround > 0 && g_cZEZombieShieldType.IntValue > 0)
				{
					GivePlayerItem(user, "weapon_shield");
				}
				SetEntityHealth(user, g_cZEMotherZombieHP.IntValue);
				EmitSoundToAll("ze_premium/ze-respawn.mp3", user);
				CreateTimer(g_cZEInfectionTime.FloatValue, AntiDisconnect, user);
				g_bAntiDisconnect[user] = true;
			}
		} 
		while (infection < numberinfected);
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				if(nemesis == 0)
				{
					SetHudTextParams(-1.0, 0.1, 4.02, 255, 0, 0, 255, 0, 0.0, 0.0, 0.0);
					ShowHudText(i, -1, "Player %N was infected ! Apocalypse has started...", firstinfected);
				}
				else
				{
					SetHudTextParams(-1.0, 0.1, 4.02, 139, 0, 0, 255, 0, 0.0, 0.0, 0.0);
					ShowHudText(i, -1, "Player %N is NEMESIS ! Run, run save your lives...", firstinfected);
				}
			}
		}
		CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "first_infected", firstinfected);
		KillTimer(H_FirstInfection);
		H_FirstInfection = null;	
	}
}

public Action Timer_Beacon(Handle timer, int client)
{
	if(g_bBeacon[client] == true && IsValidClient(client))
	{
		float fPos[3];
		GetClientAbsOrigin(client, fPos);
		TE_SetupBeamRingPoint(fPos, 50.0, 20.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.2, 4.0, 0.0, {255, 0, 0, 255}, 0, 0);
		TE_SendToAll();	
	}
}

public Action Respawn(Handle timer, int client)
{
	if(IsValidClient(client))
	{
		if(g_bNoRespawn[client] == false)
		{
			if(GetClientTeam(client) == CS_TEAM_T)
			{
				if(i_Riotround > 0)
				{
					GivePlayerItem(client, "weapon_shield");
				}
			}
			CS_RespawnPlayer(client);
			EmitSoundToAll("ze_premium/ze-respawn.mp3", client);
			Call_StartForward(gF_ClientRespawned);
			Call_PushCell(client);
			Call_Finish();
		}
	}
}

public Action AntiDisconnect(Handle timer, int client)
{
	if(IsValidClient(client))
	{
		g_bAntiDisconnect[client] = false;
	}
}

public Action EndCooldown(Handle timer, int client)
{
	if(IsValidClient(client))
	{
		g_hCooldown[client] = false;
	}
}

public Action SwitchTeam(Handle timer, int client)
{
	if(IsValidClient(client))
	{
		if(g_bRoundStarted == true)
		{
			g_bInfected[client] = true;
			CS_SwitchTeam(client, CS_TEAM_T);
			CS_RespawnPlayer(client);
		}
		else
		{
			int random = GetRandomInt(1, 2);
			if(random == 1)
			{
				ChangeClientTeam(client, CS_TEAM_T);
				CS_RespawnPlayer(client);
			}
			else
			{
				ChangeClientTeam(client, CS_TEAM_CT);
				CS_RespawnPlayer(client);
			}
		}
	}
}

public Action Timer_Unfreeze(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	
	if (!IsValidClient(client) && !IsPlayerAlive(client))
		return Plugin_Handled;
	
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntityRenderColor(client);
	
	return Plugin_Handled;
}

public Action Onfire(Handle timer, int client)
{
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		if(GetClientTeam(client) == CS_TEAM_T && g_bOnFire[client] == true)
		{
			EmitSoundToAll("ze_premium/ze-fire2.mp3", client);
		}
	}
}

public Action Slowdown(Handle timer, int client)
{
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		if(GetClientTeam(client) == CS_TEAM_T && g_bOnFire[client] == true)
		{
			float newspeed;
			if(i_zclass[client] == 1)
			{
				newspeed = g_cZEZombieSpeed.FloatValue + 0.2;
			}
			else
			{
				newspeed = g_cZEZombieSpeed.FloatValue;
			}
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", newspeed);
			g_bOnFire[client] = false;
		}
	}
}

public Action PointsCheck(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			Command_DataUpdate(i);
		}
	}
}

public Action CreateEvent_SmokeDetonate(Handle timer, any entity)
{
	if (!IsValidEdict(entity))
	{
		return Plugin_Stop;
	}
	
	char g_szClassname[64];
	GetEdictClassname(entity, g_szClassname, sizeof(g_szClassname));
	if (!strcmp(g_szClassname, "smokegrenade_projectile", false))
	{
		float origin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
		int client = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
		EmitSoundToAll("ze_premium/ze-infectionnade.mp3", entity);
		SmokeInfection(client, origin);
		AcceptEntityInput(entity, "kill");
	}
	
	return Plugin_Stop;
}

public Action CreateEvent_DecoyDetonate(Handle timer, any entity)
{
	if (!IsValidEdict(entity))
	{
		return Plugin_Stop;
	}
	
	char g_szClassname[64];
	GetEdictClassname(entity, g_szClassname, sizeof(g_szClassname));
	if (!strcmp(g_szClassname, "decoy_projectile", false))
	{
		float origin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
		int client = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
		EmitSoundToAll("ze_premium/freeze.mp3", entity);
		FlashFreeze(client, origin);
		AcceptEntityInput(entity, "kill");
	}
	
	return Plugin_Stop;
}

public Action Delete(Handle timer, any entity)
{
	if (IsValidEdict(entity))
	{
		AcceptEntityInput(entity, "kill");
	}
}
