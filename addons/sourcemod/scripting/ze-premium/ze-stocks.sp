stock int GetTeamAliveCount(int iTeamNum)
{
	int iCount;
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	if (IsClientInGame(iClient) && GetClientTeam(iClient) == iTeamNum && IsPlayerAlive(iClient))
		iCount++;
	return iCount;
}

stock bool IsValidClient(int client, bool bots = true, bool dead = true)
{
	if (client <= 0)
		return false;

	if (client > MaxClients)
		return false;

	if (!IsClientInGame(client))
		return false;

	if (IsFakeClient(client) && !bots)
		return false;

	if (IsClientSourceTV(client))
		return false;

	if (IsClientReplay(client))
		return false;

	if (!IsPlayerAlive(client) && !dead)
		return false;

	return true;
}

stock int SetReserveAmmo(int client, int weapon, int ammo)
{
	SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);
	
	int ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (ammotype == -1)return;
	
	SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, ammotype);
}

stock int SetClipAmmo(int client, int weapon, int ammo)
{
	SetEntProp(weapon, Prop_Send, "m_iClip1", ammo);
	SetEntProp(weapon, Prop_Send, "m_iClip2", ammo);
} 

stock int GetRandomsPlayer(bool alive = true)
{
	int[] clients = new int[MaxClients];
	int clientCount;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i,_, !alive))
			continue;

		clients[clientCount++] = i;
	}

	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

stock bool IsClientAdmin(int client)
{
	return CheckCommandAccess(client, "", ADMFLAG_BAN);
}

stock bool IsClientLeader(int client)
{
	return CheckCommandAccess(client, "", ADMFLAG_CUSTOM1);
}

stock bool IsClientVIP(int client)
{
	return CheckCommandAccess(client, "", ADMFLAG_RESERVATION);
}

//TAKING GUNS ZOMBIES
public Action OnWeaponCanUse(int client, int weapon)
{
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	if (GetClientTeam(client) != CS_TEAM_T)
		return Plugin_Continue;
		
	if(i_Infection != 0)
		return Plugin_Continue;
	
	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if ((StrContains(sWeapon, "knife", false) != -1) || (StrContains(sWeapon, "bayonet", false) != -1))
	{
		return Plugin_Continue;
	}
	
	return Plugin_Handled;
}

public int SpawnMarker(int client, char[] sprite)
{
	if(!IsPlayerAlive(client))
	{
		return -1;
	}

	float Origin[3];
	GetClientEyePosition(client, Origin);
	Origin[2] += 25.0;

	int Ent = CreateEntityByName("env_sprite");
	if(!Ent) return -1;

	DispatchKeyValue(Ent, "model", sprite);
	DispatchKeyValue(Ent, "classname", "env_sprite");
	DispatchKeyValue(Ent, "spawnflags", "1");
	DispatchKeyValue(Ent, "scale", "0.1");
	DispatchKeyValue(Ent, "rendermode", "1");
	DispatchKeyValue(Ent, "rendercolor", "255 255 255");
	DispatchSpawn(Ent);
	TeleportEntity(Ent, Origin, NULL_VECTOR, NULL_VECTOR);

	return Ent;
}

public int AttachSprite(int client, char[] sprite) //https://forums.alliedmods.net/showpost.php?p=1880207&postcount=5
{
	if(!IsPlayerAlive(client))
	{
		return -1;
	}

	char iTarget[16], sTargetname[64];
	GetEntPropString(client, Prop_Data, "m_iName", sTargetname, sizeof(sTargetname));

	Format(iTarget, sizeof(iTarget), "Client%d", client);
	DispatchKeyValue(client, "targetname", iTarget);

	float Origin[3];
	GetClientEyePosition(client, Origin);
	Origin[2] += 45.0;

	int Ent = CreateEntityByName("env_sprite");
	if(!Ent) return -1;

	DispatchKeyValue(Ent, "model", sprite);
	DispatchKeyValue(Ent, "classname", "env_sprite");
	DispatchKeyValue(Ent, "spawnflags", "1");
	DispatchKeyValue(Ent, "scale", "0.1");
	DispatchKeyValue(Ent, "rendermode", "1");
	DispatchKeyValue(Ent, "rendercolor", "255 255 255");
	DispatchSpawn(Ent);
	TeleportEntity(Ent, Origin, NULL_VECTOR, NULL_VECTOR);
	SetVariantString(iTarget);
	AcceptEntityInput(Ent, "SetParent", Ent, Ent, 0);

	DispatchKeyValue(client, "targetname", sTargetname);

	return Ent;
}

public void RemoveSprite(int client)
{
	if (spriteEntities[client] != -1 && IsValidEdict(spriteEntities[client]))
	{
		char m_szClassname[64];
		GetEdictClassname(spriteEntities[client], m_szClassname, sizeof(m_szClassname));
		if(strcmp("env_sprite", m_szClassname)==0)
		AcceptEntityInput(spriteEntities[client], "Kill");
	}
	spriteEntities[client] = -1;
}

public void RemoveMarker(int client)
{
	if (markerEntities[client] != -1 && IsValidEdict(markerEntities[client]))
	{
		char m_szClassname[64];
		GetEdictClassname(markerEntities[client], m_szClassname, sizeof(m_szClassname));
		if(strcmp("env_sprite", m_szClassname)==0)
		AcceptEntityInput(markerEntities[client], "Kill");
	}
	markerEntities[client] = -1;
}

public Action Event_FlashFlashDetonate(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (!g_bFreezeFlash[client])
		return;
	
	g_bFreezeFlash[client] = false;
	
	float DetonateOrigin[3];
	DetonateOrigin[0] = event.GetFloat("x");
	DetonateOrigin[1] = event.GetFloat("y");
	DetonateOrigin[2] = event.GetFloat("z");
	
	for (int i = 1; i <= MaxClients; i++)
	{
		// Check that client is a real player who is alive and is a CT
		if (IsValidClient(i) && IsPlayerAlive(i))
		{
			if (GetClientTeam(i) == CS_TEAM_T)
			{
				float vec[3];
				GetClientAbsOrigin(i, vec);
				
				float distance = GetVectorDistance(vec, DetonateOrigin, false);
				
				if (RoundToFloor(180.0 - (distance / 2.0)) <= 0) // distance to ground zero
					continue;
				
				SetEntityRenderColor(i, 0, 191, 255);
				SetEntityMoveType(i, MOVETYPE_NONE);
				
				CreateTimer(5.0, Timer_Unfreeze, GetClientUserId(i));
			}
		}
	}
	
	EmitSoundToAllAny(FREEZE_SOUND);
}

void CheckTimer()
{
	if(i_Infection == 10)
	{
		EmitSoundToAll("ze_premium/10.mp3");
	}
	else if(i_Infection == 9)
	{
		EmitSoundToAll("ze_premium/9.mp3");
	}
	else if(i_Infection == 8)
	{
		EmitSoundToAll("ze_premium/8.mp3");
	}
	else if(i_Infection == 7)
	{
		EmitSoundToAll("ze_premium/7.mp3");
	}
	else if(i_Infection == 6)
	{
		EmitSoundToAll("ze_premium/6.mp3");
	}
	else if(i_Infection == 5)
	{
		EmitSoundToAll("ze_premium/5.mp3");
	}
	else if(i_Infection == 4)
	{
		EmitSoundToAll("ze_premium/4.mp3");
	}
	else if(i_Infection == 3)
	{
		EmitSoundToAll("ze_premium/3.mp3");
	}
	else if(i_Infection == 2)
	{
		EmitSoundToAll("ze_premium/2.mp3");
	}
	else if(i_Infection == 1)
	{
		EmitSoundToAll("ze_premium/1.mp3");
	}
}

void CheckTeam(int client)
{
	int T = GetTeamClientCount(2); 
	int CT = GetTeamClientCount(3);
	if(CT > T)
	{
		if(GetClientTeam(client) == CS_TEAM_CT)
		{
			CS_SwitchTeam(client, CS_TEAM_T);
		}
	}
	
	if(T > CT)
	{
		if(GetClientTeam(client) == CS_TEAM_T)
		{
			CS_SwitchTeam(client, CS_TEAM_CT);
		}
	}
}