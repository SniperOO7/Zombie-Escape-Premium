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
			if(GetTeamClientCount(3) <= 0)
			{
				CS_TerminateRound(5.0, CSRoundEnd_TerroristWin, true);
			}
		}
		else
		{
			if(g_bNotDied[client] == true)
			{
				g_bNotDied[client] = false;
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
}

public Action Event_Spawn(Event gEventHook, const char[] gEventName, bool iDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(gEventHook, "userid"));
	
	if(i_Infection > 0)
	{
		HumanClass(iClient);
	}
	else
	{
		if(GetClientTeam(iClient) == CS_TEAM_CT)
		{
			HumanClass(iClient);
		}
		else
		{
			ZombieClass(iClient);
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
					
					ZombieClass(victim);
					CS_SwitchTeam(victim, CS_TEAM_T);
					EmitSoundToAll("ze_premium/ze-respawn.mp3", victim);
					g_bInfected[victim] = true;
					PrintToChat(victim, " \x04[Zombie-Escape]\x01 You was infected by \x06%N\x01, now you have to infect other players!", attacker);
					SetEntProp(attacker, Prop_Data, "m_iFrags", GetClientFrags(attacker) + 1);
					PrintToChat(attacker, " \x04[Zombie-Escape]\x01 You got \x041\x01 frag for infecting \x07%N!", attacker, victim);
					
					Call_StartForward(gF_ClientInfected);
					Call_PushCell(victim);
					Call_PushCell(attacker);
					Call_Finish();
					
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
					if(g_bIsNemesis[victim] == true)
					{
						int hit = GetRandomInt(1, 3);
						if (hit == 3)
						{
							EmitSoundToAll("ze_premium/ze-nemesispain3.mp3", victim);
						}
						else if (hit == 2)
						{
							EmitSoundToAll("ze_premium/ze-nemesispain2.mp3", victim);
						}
						else if (hit == 1)
						{
							EmitSoundToAll("ze_premium/ze-nemesispain.mp3", victim);
						}
					}
					else
					{
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
