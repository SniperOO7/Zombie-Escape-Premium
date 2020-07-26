public Action FirstInfection(Handle timer)
{
	int numberofplayers = GetTeamClientCount(2) + GetTeamClientCount(3);
	if (GameRules_GetProp("m_bWarmupPeriod") != 1)
	{
		if(g_bPause == false && numberofplayers >= g_cZEMinConnectedPlayers.IntValue)
		{
			i_Infection--;
			if(g_bWaitingForPlayer == true)
			{
				g_bWaitingForPlayer = false;
				CS_TerminateRound(5.0, CSRoundEnd_Draw, true);
			}
		}
		else if(numberofplayers <= g_cZEMinConnectedPlayers.IntValue)
		{
			if(g_bWaitingForPlayer == false)
			{
				g_bWaitingForPlayer = true;
			}
		}
	}
	
	if(i_Infection > 0)
	{	
		CheckTimer();
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i))
			{
				int numberinfected;
				if(numberofplayers < 4)
				{
					numberinfected = 1;
				}
				else
				{
					numberinfected = numberofplayers / 4;
				}
				float percent = float(numberofplayers) / 100;
				float newpercent = float(numberinfected) / percent;
				SetHudTextParams(-1.0, 0.1, 1.02, 0, 255, 0, 255, 0, 0.0, 0.0, 0.0);
				if(numberofplayers >= g_cZEMinConnectedPlayers.IntValue)
				{
					if(i_infectionban[i] > 0)
					{
						ShowHudText(i, -1, "First infected will be: %i sec\nYou will be infected [YOU HAVE: %i INFECTION BANS]", i_Infection, i_infectionban[i]);
					}
					else
					{
						if(g_bWasFirstInfected[i] == true)
						{
							ShowHudText(i, -1, "First infected will be: %i sec\nChance to be infected is: +0 percent", i_Infection);
						}
						else
						{
							ShowHudText(i, -1, "First infected will be: %i sec\nChance to be infected is: +%.1f percent", i_Infection, newpercent);
						}
					}
				}
				else
				{
					i_waitingforplayers++;
					char text[14];
					switch(i_waitingforplayers)
					{
						case 1: Format(text, sizeof(text), ".");
						case 2: Format(text, sizeof(text), "..");
						case 3: 
						{
							Format(text, sizeof(text), "...");
							i_waitingforplayers = 0;
						}
					}
					ShowHudText(i, -1, "Waiting for players%s\nPlayer on server: %i/%i", text, numberofplayers, g_cZEMinConnectedPlayers.IntValue);
				}
				if(g_bInfected[i] == false)
				{
					PrintHintText(i, "\n<font class='fontSize-l'><font color='#FF4500'>CHOSEN GUN:</font>%s | %s", Primary_Gun[i], Secondary_Gun[i]);
				}
				else
				{
					PrintHintText(i, "\n<font class='fontSize-l'>You will be respawned in: <font color='#00FF00'>%i</font> sec", i_Infection);
				}
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
				if(i_infectionban[i] > 0)
				{
					SetZombie(i, true);
				}
				else if(g_bInfected[i] == false)
				{
					CS_SwitchTeam(i, CS_TEAM_CT);
				}
				SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
			}
		}
		int numberinfected;
		if(numberofplayers < 4)
		{
			numberinfected = 1;
		}
		else
		{
			numberinfected = numberofplayers / 4;
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
				g_bFirstInfected[firstinfected] = true;
				CS_SwitchTeam(firstinfected, CS_TEAM_T);
				CS_RespawnPlayer(firstinfected);
				RemoveGuns(firstinfected);
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
						Format(Selected_Class_Zombie[firstinfected], sizeof(Selected_Class_Zombie), "Nemesis");
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
				Call_StartForward(gF_ClientInfected);
				Call_PushCell(firstinfected);
				Call_PushCell(firstinfected);
				Call_Finish();
			}
			else
			{
				user = GetRandomsPlayer();
				g_bInfected[user] = true;
				CS_SwitchTeam(user, CS_TEAM_T);
				CS_RespawnPlayer(user);
				RemoveGuns(user);
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
				Call_StartForward(gF_ClientInfected);
				Call_PushCell(user);
				Call_PushCell(user);
				Call_Finish();
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
			CS_RespawnPlayer(client);
			if(g_bInfected[client] == true)
			{
				if(i_Riotround > 0)
				{
					GivePlayerItem(client, "weapon_shield");
				}
				EmitSoundToAll("ze_premium/ze-respawn.mp3", client);
			}
			Call_StartForward(gF_ClientRespawned);
			Call_PushCell(client);
			Call_Finish();
		}
	}
}

public Action EndOfRound(Handle timer)
{
	if(GetHumanAliveCount() == 0 && g_bRoundEnd == false)
	{
		StopMapMusic();
		CS_TerminateRound(5.0, CSRoundEnd_TerroristWin, true);
	}
	else if(GetZombieAliveCount() == 0 && g_bRoundEnd == false)
	{
		StopMapMusic();
		CS_TerminateRound(5.0, CSRoundEnd_CTWin, true);
	}
}

public Action AntiDisconnect(Handle timer, int client)
{
	if(IsValidClient(client))
	{
		g_bAntiDisconnect[client] = false;
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
			SetPlayerAsZombie(client);
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
			SetEntProp(client, Prop_Send, "m_CollisionGroup", 2);
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
		if(g_bInfected[client] == true && g_bOnFire[client] == true)
		{
			float newspeed;
			newspeed = g_cZEZombieSpeed.FloatValue;
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", newspeed);
			g_bOnFire[client] = false;
		}
	}
}

public Action PointsCheck(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && !IsFakeClient(i))
		{
			Command_DataUpdate(i);
		}
	}
}

public Action EndFireHe(Handle timer, int client)
{
	g_bFireHE[client] = false;
}

public Action HUD(Handle timer)
{
	if(g_cZEHUDInfo.IntValue > 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i))
			{
				if(g_bInfected[i] == true)
				{
					SetHudTextParams(-1.0, -0.05, 1.02, 255, 0, 0, 255, 0, 0.0, 0.0, 0.0);
					ShowHudText(i, -1, "Type: Zombie | Class: %s | Infected players: %i", Selected_Class_Zombie[i], i_infectedh[i]);
				}
				else
				{
					char progress[32];
					if(g_bUltimate[i] == true)
					{
						Format(progress, sizeof(progress), "READY TO USE (F)");
					}
					else
					{
						if(f_causeddamage[i] >= 2000)Format(progress, sizeof(progress), "☒☒☒☒☐");
						else if(f_causeddamage[i] >= 1000)Format(progress, sizeof(progress), "☒☒☒☐☐");
						else if(f_causeddamage[i] >= 500)Format(progress, sizeof(progress), "☒☒☐☐☐");
						else if(f_causeddamage[i] < 500)Format(progress, sizeof(progress), "☒☐☐☐☐");
					}
					if(i_hclass[i] > 0)
					{
						SetHudTextParams(-1.0, -0.05, 1.02, 65, 105, 225, 255, 0, 0.0, 0.0, 0.0);
						ShowHudText(i, -1, "Type: Human | Class: %s | Won rounds: %i\nUltimate Power: %s", Selected_Class_Human[i], i_hwins[i], progress);
					}
					else
					{
						SetHudTextParams(-1.0, -0.05, 1.02, 65, 105, 225, 255, 0, 0.0, 0.0, 0.0);
						ShowHudText(i, -1, "Type: Human | Class: %s | Won rounds: %i", Selected_Class_Human[i], i_hwins[i]);
					}
				}
			}
		}
	}
	return Plugin_Continue;
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

public Action EndPower(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		i_Power[client] = 0;
		PrintHintText(client, "\n<font class='fontSize-l'><font color='#00FF00'>[ZE-Class]</font> <font color='#FF0000'>Your ultimate power has expired!");
		if (H_AmmoTimer[client] != INVALID_HANDLE)
		{
			delete H_AmmoTimer[client];
		}
	}	
}

public Action PowerOfTimer(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		if(i_Power[client] == 2)
		{
			float fPos[3];
			GetClientAbsOrigin(client, fPos);
			TE_SetupBeamRingPoint(fPos, 150.0, 10.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 4.0, 0.0, {255, 215, 0, 255}, 0, 0);
			TE_SendToAll();
			SetEntityHealth(client, GetClientHealth(client) + 5);
			CheckPlayerRange(client);
		}
		else if(i_Power[client] == 3)
		{
			int Primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			if (IsValidEdict(Primary))
			{
				char SecondaryName[30];
				GetEntityClassname(Primary, SecondaryName, sizeof(SecondaryName));
				if (StrEqual(SecondaryName, "weapon_negev", false) || StrEqual(SecondaryName, "weapon_m249", false))
				{
					SetClipAmmo(client, Primary, 100);
				}
				else if (StrEqual(SecondaryName, "weapon_bizon", false) || StrEqual(SecondaryName, "weapon_p90", false))
				{
					SetClipAmmo(client, Primary, 50);
				}
				else
				{
					SetClipAmmo(client, Primary, 40);
				}
			}
		}
	}	
}
