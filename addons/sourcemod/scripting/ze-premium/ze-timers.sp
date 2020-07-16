public Action FirstInfection(Handle timer)
{
	if(g_bPause == false)
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
				ShowHudText(i, -1, "First infected will be: %i sec\nChance to be infected is: +%.1f percent", i_Infection, newpercent);
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
				CS_SwitchTeam(i, CS_TEAM_CT);
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
		int nemesis;
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
					PrintToChatAll(" \x04[ZE-Leader]\x01 Leader \x04%N\x01 has died!", firstinfected);
				}
				SetEntityHealth(firstinfected, g_cZEMotherZombieHP.IntValue);
				if(spended[firstinfected] > 0)
				{
					int money = GetEntProp(firstinfected, Prop_Send, "m_iAccount");
					SetEntProp(firstinfected, Prop_Send, "m_iAccount", money + spended[firstinfected]);
				}
				EmitSoundToAll("ze_premium/ze-respawn.mp3", firstinfected);
				if(g_cZENemesis.IntValue > 0)
				{
					int nemesischance = GetRandomInt(1, 100);
					if(nemesischance >= 1 && nemesischance <= g_cZENemesis.IntValue)
					{
						EmitSoundToAll("ze_premium/ze-nemesis.mp3");
						nemesis = 1;
						SetEntityHealth(firstinfected, g_cZENemesisHP.IntValue);
						SetEntityModel(firstinfected, NEMESISMODEL);
						SetEntPropFloat(firstinfected, Prop_Data, "m_flLaggedMovementValue", g_cZENemesisSpeed.FloatValue);
						SetEntityGravity(firstinfected, g_cZENemesisGravity.FloatValue);
					}
				}
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
					PrintToChatAll(" \x04[ZE-Leader]\x01 Leader \x04%N\x01 has died!", user);
				}
				if(spended[user] > 0)
				{
					int money = GetEntProp(user, Prop_Send, "m_iAccount");
					SetEntProp(user, Prop_Send, "m_iAccount", money + spended[user]);
				}
				SetEntityHealth(user, g_cZEMotherZombieHP.IntValue);
				EmitSoundToAll("ze_premium/ze-respawn.mp3", user);
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
		PrintToChatAll(" \x04[Zombie-Escape]\x01 Player \x04%N\x01 is first zombie! Apocalypse has started...", firstinfected);
		KillTimer(H_FirstInfection);
		H_FirstInfection = null;	
	}
}

public Action Timer_Beacon(Handle timer, int client)
{
	if(g_bBeacon[client] == true)
	{
		float fPos[3];
		GetClientAbsOrigin(client, fPos);
		TE_SetupBeamRingPoint(fPos, 50.0, 20.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.2, 4.0, 0.0, {255, 0, 0, 255}, 0, 0);
		TE_SendToAll();	
	}
}

public Action Respawn(Handle timer, int client)
{
	CS_RespawnPlayer(client);
	EmitSoundToAll("ze_premium/ze-respawn.mp3", client);
}

public Action SwitchTeam(Handle timer, int client)
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
			CS_SwitchTeam(client, CS_TEAM_T);
			CS_RespawnPlayer(client);
		}
		else
		{
			CS_SwitchTeam(client, CS_TEAM_CT);
			CS_RespawnPlayer(client);
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