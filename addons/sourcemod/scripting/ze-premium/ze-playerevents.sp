public void OnPlayerDeath(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	int numberofplayers = GetTeamClientCount(2) + GetTeamClientCount(3);
	
	if (GameRules_GetProp("m_bWarmupPeriod") != 1 && numberofplayers > g_cZEMinConnectedPlayers.IntValue)
	{
		if (IsValidClient(client))
		{	
			DisableSpells(client);
			if(g_bInfected[client] == false)
			{
				int die = GetRandomInt(1, 3);
				if(die == 1)
				{
					EmitSoundToAll("ze_premium/ze-ctdie.mp3", client);
				}
				else
				{
					char soundPath[PLATFORM_MAX_PATH];
					Format(soundPath, sizeof(soundPath), "ze_premium/ze-ctdie%i.mp3", die);
					EmitSoundToAll(soundPath, client);
				}
				if(g_bIsLeader[client] == true)
				{
					g_bIsLeader[client] = false;
					CPrintToChatAll(" \x04[ZE-Leader]\x01 %t", "leader_died", client);
				}
				if (H_Beacon[client] != null)
				{
					KillTimer(H_Beacon[client]);
					H_Beacon[client] = null;	
				}
				g_bInfected[client] = true;
				CS_SwitchTeam(client, CS_TEAM_T);
				SetPlayerAsZombie(client);
				if(i_Infection > 0)
				{
					float nextrespawn = float(i_Infection);
					H_Respawntimer[client] = CreateTimer(nextrespawn, Respawn, client);
				}
				else
				{
					CreateTimer(1.0, Respawn, client);
				}
				if(GetHumanAliveCount() == 0)
				{
					StopMapMusic();
					CS_TerminateRound(5.0, CSRoundEnd_TerroristWin, true);
					EmitSoundToAll("ze_premium/ze-zombiewin.mp3");
				}
			}
			else if(g_bInfected[client] == true)
			{
				if(g_bNotDied[client] == true)
				{
					g_bNotDied[client] = false;
				}
				else
				{
					i_killedzm[attacker]++;
					int die = GetRandomInt(1, 3);
					if(die == 1)
					{
						EmitSoundToAll("ze_premium/ze-die.mp3", client);
					}
					else
					{
						char soundPath[PLATFORM_MAX_PATH];
						Format(soundPath, sizeof(soundPath), "ze_premium/ze-die%i.mp3", die);
						EmitSoundToAll(soundPath, client);
					}
					g_bIsNemesis[client] = false;
					CreateTimer(1.0, Respawn, client);
					if(GetZombieAliveCount() == 0)
					{
						StopMapMusic();
						CS_TerminateRound(5.0, CSRoundEnd_CTWin, true);
						int random = GetRandomInt(1, 2);
						if (random == 1)
						{
							EmitSoundToAll("ze_premium/ze-humanwin1.mp3");
						}
						else
						{
							EmitSoundToAll("ze_premium/ze-humanwin2.mp3");
						}
					}
				}
			}
		}
	}
	else
	{
		CreateTimer(1.0, Respawn, client);
	}
}

public Action Event_Spawn(Event gEventHook, const char[] gEventName, bool iDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(gEventHook, "userid"));
	
	if(i_Infection > 0)
	{
		SetPlayerAsHuman(iClient);
	}
	else
	{
		if(GetClientTeam(iClient) == CS_TEAM_CT)
		{
			SetPlayerAsHuman(iClient);
		}
		else
		{
			SetPlayerAsZombie(iClient);
		}
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{	
	if(IsValidClient(victim))
	{
		if(damagetype & DMG_FALL)
		{
			return Plugin_Handled;
		}
	}
	
	if (GameRules_GetProp("m_bWarmupPeriod") != 1)
	{
		if(attacker != victim && i_Infection == 0)
		{	
			if(g_bInfected[attacker] == false)
			{
				if(g_bUltimate[attacker] == false && i_hclass[attacker] > 0)
				{
					f_causeddamage[attacker] += damage;
				}
				
				if(f_causeddamage[attacker] >= 5000.0)
				{
					PrintHintText(attacker, "\n<font class='fontSize-l'><font color='#00FF00'>[ZE-Class]</font> <font color='#FFFFFF'>You ultimate power is</font> <font color='#FFFF00'>ready!");
					PrintToChat(attacker, " \x04[ZE-Class]\x01 You have ready your \x0Bultimate power!");
					f_causeddamage[attacker] = 0.0;
					g_bUltimate[attacker] = true;
				}
			}
			
			if(g_bInfected[attacker] == true && g_bInfected[victim] == false)
			{
				if(i_protection[victim] > 0)
				{
					i_protection[victim]--;
					EmitSoundToAll("ze_premium/ze-hit.mp3", victim);
					return Plugin_Handled;
				}
				else
				{
					RemoveGuns(victim);
					DisableSpells(victim);
					if(g_bIsLeader[victim] == true)
					{
						g_bIsLeader[victim] = false;
						CPrintToChatAll(" \x04[ZE-Leader]\x01 %t", "leader_died", victim);
					}
					if (H_Beacon[victim] != null)
					{
						KillTimer(H_Beacon[victim]);
						H_Beacon[victim] = null;	
					}
					CS_SwitchTeam(victim, CS_TEAM_T);
					SetPlayerAsZombie(victim);
					EmitSoundToAll("ze_premium/ze-respawn.mp3", victim);
					g_bInfected[victim] = true;
					i_infected[attacker]++;
					CPrintToChat(victim, " \x04[Zombie-Escape]\x01 %t", "infected_by_player", attacker);
					SetEntProp(attacker, Prop_Data, "m_iFrags", GetClientFrags(attacker) + 1);
					CPrintToChat(attacker, " \x04[Zombie-Escape]\x01 %t", "infected_frag", victim);
					if(i_Riotround > 0 && g_cZEZombieShieldType.IntValue > 0)
					{
						GivePlayerItem(victim, "weapon_shield");
					}
					
					Call_StartForward(gF_ClientInfected);
					Call_PushCell(victim);
					Call_PushCell(attacker);
					Call_Finish();
					
					if(GetHumanAliveCount() == 0)
					{
						StopMapMusic();
						CS_TerminateRound(5.0, CSRoundEnd_TerroristWin, true);
						EmitSoundToAll("ze_premium/ze-zombiewin.mp3");
					}
				}
			}
		}
	}
	
	if(damagetype & DMG_BLAST)
	{
		if(IsValidClient(victim) && attacker != victim && g_bFireHE[attacker] == true)
		{
			if(ZR_IsClientHuman(victim))
			{
				return Plugin_Handled;
			}
			else if(ZR_IsClientZombie(victim))
			{
				g_bOnFire[victim] = true;
				g_bFireHE[attacker] = false;
				EmitSoundToAll("ze_premium/ze-fire.mp3", victim);
				CreateTimer(3.0, Onfire, victim);
				CreateTimer(5.0, Slowdown, victim);
				IgniteEntity(victim, 5.0);
				SetEntPropFloat(victim, Prop_Data, "m_flLaggedMovementValue", 0.5);
			}
		}
	}
	return Plugin_Continue;
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(event,"userid")); // get victim & attacker
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	if(IsValidClient(victim))
	{
		if(GetClientTeam(victim) == CS_TEAM_CT)
		{
			HumanPain(victim);
		}
		else if(GetClientTeam(victim) == CS_TEAM_T)
		{
			ZombiePain(victim);
		}
	}
	
	int zombie, human;
	char atkweapon[128];
	zombie = GetEventInt(event, "attacker");
	human = GetEventInt(event, "userid");
	if(victim != attacker && attacker !=0 && GetClientTeam(attacker) == CS_TEAM_T)
	{
		GetEventString(event, "weapon", atkweapon, sizeof(atkweapon));
		if (StrEqual(atkweapon, "knife") || StrEqual(atkweapon, "bayonet"))
		{
			g_bNotDied[victim] = true;
			Event event1 = CreateEvent("player_death");
			event1.SetInt("userid", human);
			event1.SetInt("attacker", zombie);
			event1.SetString("weapon", atkweapon);
			event1.Fire();
		}
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{	
	static bool s_ClientIsReloading[MAXPLAYERS + 1];
	if (!IsClientInGame(client))
		return Plugin_Continue;
	
	char sWeapon[64];
	int iWeapon = Client_GetActiveWeaponName(client, sWeapon, sizeof(sWeapon));
	if (iWeapon == INVALID_ENT_REFERENCE)
		return Plugin_Continue;
	
	bool bIsReloading = Weapon_IsReloading(iWeapon);
	// Shotguns don't use m_bInReload but have their own m_reloadState
	if (!bIsReloading && HasEntProp(iWeapon, Prop_Send, "m_reloadState") && GetEntProp(iWeapon, Prop_Send, "m_reloadState") > 0)
		bIsReloading = true;
	
	if (bIsReloading && !s_ClientIsReloading[client] && g_bInfected[client] == false)
	{
		if(g_cZEReloadingSound.IntValue > 0)
		{
			int random = GetRandomInt(1, 4);
			char soundPath[PLATFORM_MAX_PATH];
			Format(soundPath, sizeof(soundPath), "ze_premium/ze-reloading%i.mp3", random);
			if(g_cZEReloadingSoundType.IntValue > 0)
			{
				EmitSoundToAll(soundPath, client);
			}
			else
			{
				EmitSoundToClient(client, soundPath);
			}
			int Primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			int Secondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
			if (IsValidEdict(Primary))
			{
				SetReserveAmmo(client, Primary, 200);
				if (IsValidEdict(Secondary))
				{
					SetReserveAmmo(client, Secondary, 200);
				}
			}
			else if (IsValidEdict(Secondary))
			{
				SetReserveAmmo(client, Secondary, 200);
			}
		}
	}
	
	s_ClientIsReloading[client] = bIsReloading;
	
	return Plugin_Continue;
}
