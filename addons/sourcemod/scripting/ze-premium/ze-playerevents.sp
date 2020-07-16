public void OnPlayerDeath(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	//int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if (IsValidClient(client))
	{	
		g_bFireHE[client] = false;
		g_bOnFire[client] = false;
		g_bFreezeFlash[client] = false;
		g_bHadHe[client] = false;
		if(GetClientTeam(client) == CS_TEAM_CT)
		{
			int die = GetRandomInt(1, 3);
			if(die == 3)
			{
				EmitSoundToAll("ze_premium/ze-ctdie3.mp3", client);
			}
			else if (die == 2)
			{
				EmitSoundToAll("ze_premium/ze-ctdie2.mp3", client);
			}
			else if (die == 1)
			{
				EmitSoundToAll("ze_premium/ze-ctdie.mp3", client);
			}
			if(g_bIsLeader[client] == true)
			{
				g_bIsLeader[client] = false;
				PrintToChatAll(" \x04[ZE-Leader]\x01 Leader \x04%N\x01 has died!", client);
			}
			if (H_Beacon[client] != null)
			{
				KillTimer(H_Beacon[client]);
				H_Beacon[client] = null;	
			}
			g_bBeacon[client] = false;
			g_bFireHE[client] = false;
			g_bHadHe[client] = false;
			g_bOnFire[client] = false;
			g_bFreezeFlash[client] = false;
			g_bInfected[client] = true;
			CS_SwitchTeam(client, CS_TEAM_T);
			CreateTimer(1.0, Respawn, client);
		}
		else
		{
			int die = GetRandomInt(1, 3);
			if(die == 3)
			{
				EmitSoundToAll("ze_premium/ze-die3.mp3", client);
			}
			else if (die == 2)
			{
				EmitSoundToAll("ze_premium/ze-die2.mp3", client);
			}
			else if (die == 1)
			{
				EmitSoundToAll("ze_premium/ze-die.mp3", client);
			}
			g_bIsNemesis[client] = false;
			CreateTimer(1.0, Respawn, client);
		}
	}
}

public Action Event_Spawn(Event gEventHook, const char[] gEventName, bool iDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(gEventHook, "userid"));
	
	if(i_Infection > 0)
	{
		if(i_hclass[iClient] == 1)
		{
			SetEntityHealth(iClient, g_cZEHumanHP.IntValue);
			GivePlayerItem(iClient, "weapon_hegrenade");
			SetEntityModel(iClient, HUMANMODEL);
			SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
		else if(i_hclass[iClient] == 2)
		{
			SetEntityHealth(iClient, g_cZEHumanHP.IntValue);
			GivePlayerItem(iClient, "weapon_healthshot");
			SetEntityModel(iClient, HUMANMODEL);
			SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
		else if(i_hclass[iClient] == 3)
		{
			int newhp = g_cZEHumanHP.IntValue + 50;
			SetEntityHealth(iClient, newhp);
			SetEntityModel(iClient, HUMANMODEL);
			SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
		else if(i_hclass[iClient] == 4)
		{
			SetEntityHealth(iClient, g_cZEHumanHP.IntValue);
			i_protection[iClient] = 1;
			SetEntityModel(iClient, HUMANMODEL);
			SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
		else
		{
			SetEntityHealth(iClient, g_cZEHumanHP.IntValue);
			SetEntityModel(iClient, HUMANMODEL);
			SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
	}
	else
	{
		if(GetClientTeam(iClient) == CS_TEAM_CT)
		{
			if(i_hclass[iClient] == 1)
			{
				SetEntityHealth(iClient, g_cZEHumanHP.IntValue);
				GivePlayerItem(iClient, "weapon_hegrenade");
				SetEntityModel(iClient, HUMANMODEL);
				SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", 1.0);
			}
			else if(i_hclass[iClient] == 2)
			{
				SetEntityHealth(iClient, g_cZEHumanHP.IntValue);
				GivePlayerItem(iClient, "weapon_healthshot");
				SetEntityModel(iClient, HUMANMODEL);
				SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", 1.0);
			}
			else if(i_hclass[iClient] == 3)
			{
				int newhp = g_cZEHumanHP.IntValue + 50;
				SetEntityHealth(iClient, newhp);
				SetEntityModel(iClient, HUMANMODEL);
				SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", 1.0);
			}
			else if(i_hclass[iClient] == 4)
			{
				int newhp = g_cZEHumanHP.IntValue + 50;
				SetEntityHealth(iClient, newhp);
				i_protection[iClient] = 1;
				SetEntityModel(iClient, HUMANMODEL);
				SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", 1.0);
			}
			else
			{
				SetEntityHealth(iClient, g_cZEHumanHP.IntValue);
				SetEntityModel(iClient, HUMANMODEL);
				SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", 1.0);
			}
		}
		else
		{
			if(i_zclass[iClient] == 1)
			{
				float newspeed = g_cZEZombieSpeed.FloatValue + 0.2;
				SetEntityHealth(iClient, g_cZEZombieHP.IntValue);
				SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", newspeed);
				SetEntityModel(iClient, ZOMBIEMODEL);
			}
			else if(i_zclass[iClient] == 2)
			{
				int newhp = g_cZEZombieHP.IntValue + 2000;
				SetEntityHealth(iClient, newhp);
				SetEntityModel(iClient, ZOMBIEMODEL);
			}
			else if(i_zclass[iClient] == 3)
			{
				SetEntityHealth(iClient, g_cZEZombieHP.IntValue);
				SetEntityGravity(iClient, 1.3);
				SetEntityModel(iClient, ZOMBIEMODEL);
			}
			else if(i_zclass[iClient] == 4)
			{
				float newspeed = g_cZEZombieSpeed.FloatValue + 0.1;
				int newhp = g_cZEZombieHP.IntValue + 1000;
				SetEntityHealth(iClient, newhp);
				SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", newspeed);
				SetEntityModel(iClient, ZOMBIEMODEL);
			}
			else
			{
				SetEntityHealth(iClient, g_cZEZombieHP.IntValue);
				SetEntityModel(iClient, ZOMBIEMODEL);
			}
		}
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (IsValidClient(attacker) && IsValidClient(victim))
	{
		if(attacker != victim)
		{	
			if(GetClientTeam(victim) == CS_TEAM_CT && i_Infection == 0)
			{
				if(i_protection[victim] > 0)
				{
					i_protection[victim]--;
					EmitSoundToAll("ze_premium/ze-hit.mp3", victim);
					return Plugin_Handled;
				}
				else
				{
					int primweapon = GetPlayerWeaponSlot(victim, CS_SLOT_PRIMARY);
					if(IsValidEdict(primweapon) && primweapon != -1)
					{
						RemoveEdict(primweapon);
					}
					int secweapon = GetPlayerWeaponSlot(victim, CS_SLOT_SECONDARY);
					if(IsValidEdict(secweapon) && secweapon != -1)
					{
						RemoveEdict(secweapon);
					}
					
					if(i_zclass[victim] == 1)
					{
						float newspeed = g_cZEZombieSpeed.FloatValue + 0.2;
						SetEntityHealth(victim, g_cZEZombieHP.IntValue);
						SetEntPropFloat(victim, Prop_Data, "m_flLaggedMovementValue", newspeed);
						SetEntityModel(victim, ZOMBIEMODEL);
					}
					else if(i_zclass[victim] == 2)
					{
						int newhp = g_cZEZombieHP.IntValue + 2000;
						SetEntityHealth(victim, newhp);
						SetEntityModel(victim, ZOMBIEMODEL);
					}
					else if(i_zclass[victim] == 3)
					{
						SetEntityHealth(victim, g_cZEZombieHP.IntValue);
						SetEntityGravity(victim, 1.3);
						SetEntityModel(victim, ZOMBIEMODEL);
					}
					else if(i_zclass[victim] == 4)
					{
						float newspeed = g_cZEZombieSpeed.FloatValue + 0.1;
						int newhp = g_cZEZombieHP.IntValue + 1000;
						SetEntityHealth(victim, newhp);
						SetEntPropFloat(victim, Prop_Data, "m_flLaggedMovementValue", newspeed);
						SetEntityModel(victim, ZOMBIEMODEL);
					}
					else
					{
						SetEntityHealth(victim, g_cZEZombieHP.IntValue);
						SetEntityModel(victim, ZOMBIEMODEL);
					}
					CS_SwitchTeam(victim, CS_TEAM_T);
					EmitSoundToAll("ze_premium/ze-respawn.mp3", victim);
					g_bInfected[victim] = true;
					PrintToChat(victim, " \x04[Zombie-Escape]\x01 You was infected by \x06%N\x01, now you have to infect other players!", attacker);
					if(GetTeamClientCount(3) <= 0)
					{
						CS_TerminateRound(5.0, CSRoundEnd_TerroristWin, true);
					}
				}
			}
			else
			{
				i_pause[victim]++;
				if(i_pause[victim] >= 5)
				{
					i_pause[victim] = 0;
					int hit = GetRandomInt(1, 6);
					if (hit == 6)
					{
						EmitSoundToAll("ze_premium/ze-pain6.mp3", victim);
					}
					else if (hit == 5)
					{
						EmitSoundToAll("ze_premium/ze-pain5.mp3", victim);
					}
					else if (hit == 4)
					{
						EmitSoundToAll("ze_premium/ze-pain4.mp3", victim);
					}
					else if(hit == 3)
					{
						EmitSoundToAll("ze_premium/ze-pain3.mp3", victim);
					}
					else if (hit == 2)
					{
						EmitSoundToAll("ze_premium/ze-pain2.mp3", victim);
					}
					else if (hit == 1)
					{
						EmitSoundToAll("ze_premium/ze-pain.mp3", victim);
					}
				}
			}
		}
	}
	
	if(damagetype & DMG_BLAST)
	{
		if(IsValidClient(victim) && attacker != victim && g_bHadHe[attacker] == true)
		{
			if(GetClientTeam(victim) == CS_TEAM_CT)
			{
				return Plugin_Handled;
			}
			else
			{
				g_bOnFire[victim] = true;
				g_bHadHe[attacker] = false;
				EmitSoundToAll("ze_premium/ze-fire.mp3", victim);
				CreateTimer(3.0, Onfire, victim);
				CreateTimer(5.0, Slowdown, victim);
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

	if (attacker == 0 || !g_bFireHE[attacker]) 
		return;

	if (victim != attacker && attacker !=0 && attacker <MAXPLAYERS)
	{
		char sWeaponUsed[50];
		GetEventString(event,"weapon",sWeaponUsed,sizeof(sWeaponUsed));

		if (StrEqual(sWeaponUsed,"hegrenade"))
		{			
			IgniteEntity(victim, 5.0);
		}
	}

	g_bFireHE[attacker] = false;
	g_bHadHe[attacker] = true;
}