stock int GetTeamAliveCount(int iTeamNum)
{
	int iCount;
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	if (IsClientInGame(iClient) && GetClientTeam(iClient) == iTeamNum && IsPlayerAlive(iClient))
		iCount++;
	return iCount;
}

stock int GetHumanAliveCount()
{
	int iCount;
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	if (IsClientInGame(iClient) && g_bInfected[iClient] == false && IsPlayerAlive(iClient))
		iCount++;
	return iCount;
}

stock int GetZombieAliveCount()
{
	int iCount;
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	if (IsClientInGame(iClient) && g_bInfected[iClient] == true && IsPlayerAlive(iClient))
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
		if (!IsValidClient(i, _, !alive))
			continue;
		
		if (g_bInfected[i] != false)
			continue;
		
		if (g_bWasFirstInfected[i] != false)
			continue;
		
		clients[clientCount++] = i;
	}
	
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
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
	
	if (i_Infection != 0)
		return Plugin_Continue;
	
	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if ((StrContains(sWeapon, "knife", false) != -1) || (StrContains(sWeapon, "bayonet", false) != -1) || (StrContains(sWeapon, "shield", false) != -1) || (StrContains(sWeapon, "smoke", false) != -1))
	{
		return Plugin_Continue;
	}
	
	return Plugin_Handled;
}

public int SpawnMarker(int client, char[] sprite)
{
	if (!IsPlayerAlive(client))
	{
		return -1;
	}
	
	float Origin[3];
	GetClientEyePosition(client, Origin);
	Origin[2] += 25.0;
	
	int Ent = CreateEntityByName("env_sprite");
	if (!Ent)return -1;
	
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
	if (!IsPlayerAlive(client))
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
	if (!Ent)return -1;
	
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
	if (i_spriteEntities[client] != -1 && IsValidEdict(i_spriteEntities[client]))
	{
		char m_szClassname[64];
		GetEdictClassname(i_spriteEntities[client], m_szClassname, sizeof(m_szClassname));
		if (strcmp("env_sprite", m_szClassname) == 0)
			AcceptEntityInput(i_spriteEntities[client], "Kill");
	}
	i_spriteEntities[client] = -1;
}

public void RemoveMarker(int client)
{
	if (i_markerEntities[client] != -1 && IsValidEdict(i_markerEntities[client]))
	{
		char m_szClassname[64];
		GetEdictClassname(i_markerEntities[client], m_szClassname, sizeof(m_szClassname));
		if (strcmp("env_sprite", m_szClassname) == 0)
			AcceptEntityInput(i_markerEntities[client], "Kill");
	}
	i_markerEntities[client] = -1;
}

void CheckTimer()
{
	switch (i_Infection)
	{
		case 10:EmitSoundToAll("ze_premium/10.mp3");
		case 9:EmitSoundToAll("ze_premium/9.mp3");
		case 8:EmitSoundToAll("ze_premium/8.mp3");
		case 7:EmitSoundToAll("ze_premium/7.mp3");
		case 6:EmitSoundToAll("ze_premium/6.mp3");
		case 5:EmitSoundToAll("ze_premium/5.mp3");
		case 4:EmitSoundToAll("ze_premium/4.mp3");
		case 3:EmitSoundToAll("ze_premium/3.mp3");
		case 2:EmitSoundToAll("ze_premium/2.mp3");
		case 1:EmitSoundToAll("ze_premium/1.mp3");
	}
}

void CheckTeam(int client)
{
	int T = GetTeamClientCount(2);
	int CT = GetTeamClientCount(3);
	if (CT > T)
	{
		if (GetClientTeam(client) == CS_TEAM_CT)
		{
			CS_SwitchTeam(client, CS_TEAM_T);
		}
	}
	
	if (T > CT)
	{
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			CS_SwitchTeam(client, CS_TEAM_CT);
		}
	}
}

void DisableAll(int client)
{
	g_bInfected[client] = false;
	i_typeofsprite[client] = 0;
	i_Maximum_Choose[client] = 0;
	g_bBeacon[client] = false;
	g_bIsLeader[client] = false;
	spended[client] = 0;
	i_Power[client] = 0;
	f_causeddamage[client] = 0.0;
	g_bUltimate[client] = false;
	i_respawn[client] = 0;
	g_bFireHE[client] = false;
	g_bOnFire[client] = false;
	g_bFreezeFlash[client] = false;
	g_bNoRespawn[client] = false;
	if (H_Beacon[client] != null)
	{
		KillTimer(H_Beacon[client]);
		H_Beacon[client] = null;	
	}
	if(H_Respawntimer[client] != null)
	{
		KillTimer(H_Respawntimer[client]);
		H_Respawntimer[client] = null;	
	}
	if (H_AmmoTimer[client] != null)
	{
		KillTimer(H_AmmoTimer[client]);
		H_AmmoTimer[client] = null;	
	}
}

void SetZombie(int client, bool respawn)
{
	g_bInfected[client] = true;
	CS_SwitchTeam(client, CS_TEAM_T);
	if (respawn == true)
	{
		CS_RespawnPlayer(client);
		EmitSoundToAll("ze_premium/ze-respawn.mp3", client);
	}
	int primweapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	if (IsValidEdict(primweapon) && primweapon != -1)
	{
		RemoveEdict(primweapon);
	}
	int secweapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if (IsValidEdict(secweapon) && secweapon != -1)
	{
		RemoveEdict(secweapon);
	}
	if (g_bIsLeader[client] == true)
	{
		g_bIsLeader[client] = false;
		CPrintToChatAll(" \x04[ZE-Leader]\x01 %t", "leader_died", client);
	}
	if (spended[client] > 0)
	{
		int money = GetEntProp(client, Prop_Send, "m_iAccount");
		SetEntProp(client, Prop_Send, "m_iAccount", money + spended[client]);
	}
	if (i_Riotround > 0 && g_cZEZombieShieldType.IntValue > 0)
	{
		GivePlayerItem(client, "weapon_shield");
	}
	SetPlayerAsZombie(client);
}

void HumanPain(int victim)
{
	i_pause[victim]++;
	if (i_pause[victim] >= 2)
	{
		i_pause[victim] = 0;
		int hit = GetRandomInt(1, 4);
		if (hit == 1)
		{
			EmitSoundToAll("ze_premium/ze-humanpain.mp3", victim);
		}
		else
		{
			char soundPath[PLATFORM_MAX_PATH];
			Format(soundPath, sizeof(soundPath), "ze_premium/ze-humanpain%i.mp3", hit);
			EmitSoundToAll(soundPath, victim);
		}
	}
}

void ZombiePain(int victim)
{
	i_pause[victim]++;
	if (i_pause[victim] >= 5)
	{
		i_pause[victim] = 0;
		if (g_bIsNemesis[victim] == true)
		{
			int hit = GetRandomInt(1, 3);
			if (hit == 1)
			{
				EmitSoundToAll("ze_premium/ze-nemesispain.mp3", victim);
			}
			else
			{
				char soundPath[PLATFORM_MAX_PATH];
				Format(soundPath, sizeof(soundPath), "ze_premium/ze-nemesispain%i.mp3", hit);
				EmitSoundToAll(soundPath, victim);
			}
		}
		else
		{
			int hit = GetRandomInt(1, 6);
			if (hit == 1)
			{
				EmitSoundToAll("ze_premium/ze-pain.mp3", victim);
			}
			else
			{
				char soundPath[PLATFORM_MAX_PATH];
				Format(soundPath, sizeof(soundPath), "ze_premium/ze-pain%i.mp3", hit);
				EmitSoundToAll(soundPath, victim);
			}
		}
	}
}

//VOID FOR SHOP SYSTEM
void FireNade(int client)
{
	g_bFireHE[client] = true;
	GivePlayerItem(client, "weapon_hegrenade");
}

void FreezeNade(int client)
{
	g_bFreezeFlash[client] = true;
	GivePlayerItem(client, "weapon_decoy");
}

public Action SoundHook(int clients[64], int &numClients, char sound[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (g_cZEZombieSounds.IntValue > 0)
	{
		int player = GetPlayerHoldingKnife(entity);
		if (player > 0 && IsClientInGame(player) && IsPlayerAlive(player) && GetClientTeam(player) == CS_TEAM_T && g_bInfected[player] == true)
		{
			if (StrContains(sound, "weapons/knife/knife_hit_") != -1)
			{
				EmitSoundToAll("ze_premium/ze-wallhit.mp3", entity, channel, level, flags, volume, pitch);
				return Plugin_Stop;
			}
			
			else if (StrContains(sound, "weapons/knife/knife_slash") != -1)
			{
				int random = GetRandomInt(1, 6);
				char soundPath[PLATFORM_MAX_PATH];
				Format(soundPath, sizeof(soundPath), "ze_premium/ze-slash%i.mp3", random);
				EmitSoundToAll(soundPath, entity, channel, level, flags, volume, pitch);
				return Plugin_Stop;
			}
			
			else if (StrContains(sound, "weapons/knife/knife_hit") != -1)
			{
				int random = GetRandomInt(1, 4);
				char soundPath[PLATFORM_MAX_PATH];
				Format(soundPath, sizeof(soundPath), "ze_premium/ze-zombiehit%i.mp3", random);
				EmitSoundToAll(soundPath, entity, channel, level, flags, volume, pitch);
				return Plugin_Stop;
			}
			
			else if (StrContains(sound, "weapons/knife/knife_stab") != -1)
			{
				EmitSoundToAll("ze_premium/ze-stab.mp3", entity, channel, level, flags, volume, pitch);
				return Plugin_Stop;
			}
		}
	}
	
	return Plugin_Changed;
}

int GetPlayerHoldingKnife(int weapon)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			int knife = GetPlayerWeaponSlot(i, CS_SLOT_KNIFE);
			if (weapon == knife)
				return i;
		}
	}
	
	return -1;
}

public void StopMapMusic()
{
	char sSound[PLATFORM_MAX_PATH];
	int entity = INVALID_ENT_REFERENCE;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i)) { continue; }
		for (int u = 0; u < g_iNumSounds; u++) {
			entity = EntRefToEntIndex(g_iSoundEnts[u]);
			if (entity != INVALID_ENT_REFERENCE) {
				GetEntPropString(entity, Prop_Data, "m_iszSound", sSound, sizeof(sSound));
				Client_StopSound(i, entity, SNDCHAN_STATIC, sSound);
			}
		}
	}
}

void Client_StopSound(int client, int entity, int channel, const char[] name)
{
	EmitSoundToClient(client, name, entity, channel, SNDLEVEL_NONE, SND_STOP, 0.0, SNDPITCH_NORMAL, _, _, _, true);
}

public void Command_DataUpdate(int client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		char szSteamId[32], szQuery[512];
		GetClientAuthId(client, AuthId_Engine, szSteamId, sizeof(szSteamId));
		
		g_hDatabase.Format(szQuery, sizeof(szQuery), "SELECT * FROM ze_premium_sql WHERE steamid='%s'", szSteamId);
		g_hDatabase.Query(szQueryUpdateData, szQuery, GetClientUserId(client));
	}
}

public void OnHeGrenadeDetonate(Handle event, char[] name, bool dontBroadcast)
{
	if (g_cZEHeGrenadeEffect.IntValue == 0)
	{
		return;
	}
	
	float origin[3];
	origin[0] = GetEventFloat(event, "x"); origin[1] = GetEventFloat(event, "y"); origin[2] = GetEventFloat(event, "z");
	
	TE_SetupBeamRingPoint(origin, 10.0, 400.0, g_iBeamSprite, g_iHaloSprite, 1, 1, 0.2, 100.0, 1.0, FragColor, 0, 0);
	TE_SendToAll();
}

public bool FilterTarget(int entity, int contentsMask, any data)
{
	return (data == entity);
}

void LightCreate(int grenade, float pos[3])
{
	int iEntity = CreateEntityByName("light_dynamic");
	DispatchKeyValue(iEntity, "inner_cone", "0");
	DispatchKeyValue(iEntity, "cone", "80");
	DispatchKeyValue(iEntity, "brightness", "1");
	DispatchKeyValueFloat(iEntity, "spotlight_radius", 150.0);
	DispatchKeyValue(iEntity, "pitch", "90");
	DispatchKeyValue(iEntity, "style", "1");
	switch (grenade)
	{
		case SMOKE : 
		{
			DispatchKeyValue(iEntity, "_light", "75 75 255 255");
			DispatchKeyValueFloat(iEntity, "distance", g_cZEInfnadedistance.FloatValue);
			CreateTimer(0.2, Delete, iEntity, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	DispatchSpawn(iEntity);
	TeleportEntity(iEntity, pos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(iEntity, "TurnOn");
}

//TRAIL GRENADE
public void Grenade_SpawnPost(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (client == -1)return;
	
	char classname[64];
	GetEdictClassname(entity, classname, 64);
	
	if (!strcmp(classname, "hegrenade_projectile"))
	{
		if (g_cZEHeGrenadeEffect.IntValue == 1 && g_bFireHE[client] == true)
		{
			BeamFollowCreate(entity, FragColor);
		}
	}
	else if (!strcmp(classname, "decoy_projectile"))
	{
		if (g_cZEFlashbangEffect.IntValue == 1 && g_bFreezeFlash[client] == true)
		{
			BeamFollowCreate(entity, FlashColor);
			CreateTimer(1.3, CreateEvent_DecoyDetonate, entity, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else if (!strcmp(classname, "smokegrenade_projectile"))
	{
		if (g_cZESmokeEffect.IntValue == 1 && g_bInfectNade[client] == true)
		{
			BeamFollowCreate(entity, SmokeColor);
			CreateTimer(1.3, CreateEvent_SmokeDetonate, entity, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

//SMOKE GRENADE
void SmokeInfection(int client, float origin[3])
{
	origin[2] += 10.0;
	
	float targetOrigin[3];
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || ZR_IsClientZombie(i))
		{
			continue;
		}
		
		GetClientAbsOrigin(i, targetOrigin);
		targetOrigin[2] += 2.0;
		if (GetVectorDistance(origin, targetOrigin) <= g_cZEInfnadedistance.FloatValue)
		{
			Handle trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
			
			if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0))
			{
				int randominf = GetRandomInt(1, 5);
				char soundPath[PLATFORM_MAX_PATH];
				Format(soundPath, sizeof(soundPath), "ze_premium/ze-infected%i.mp3", randominf);
				EmitSoundToAll(soundPath, i);
				if (g_cZEInfectionNadeEffect.IntValue > 0)
				{
					SetZombie(i, false);
				}
				else
				{
					SetZombie(i, true);
				}
				CloseHandle(trace);
			}
			
			else
			{
				CloseHandle(trace);
				
				GetClientEyePosition(i, targetOrigin);
				targetOrigin[2] -= 2.0;
				
				trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
				
				if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0))
				{
					int randominf = GetRandomInt(1, 5);
					char soundPath[PLATFORM_MAX_PATH];
					Format(soundPath, sizeof(soundPath), "ze_premium/ze-infected%i.mp3", randominf);
					EmitSoundToAll(soundPath, i);
					if (g_cZEInfectionNadeEffect.IntValue > 0)
					{
						SetZombie(i, false);
					}
					else
					{
						SetZombie(i, true);
					}
				}
				
				CloseHandle(trace);
			}
		}
	}
	
	TE_SetupBeamRingPoint(origin, 10.0, g_cZEInfnadedistance.FloatValue, g_iBeamSprite, g_iHaloSprite, 1, 1, 0.2, 100.0, 1.0, SmokeColor, 0, 0);
	g_bInfectNade[client] = false;
	TE_SendToAll();
	LightCreate(SMOKE, origin);
}

//FREEZE GRENADE
void FlashFreeze(int client, float origin[3])
{
	origin[2] += 10.0;
	
	float targetOrigin[3];
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || ZR_IsClientHuman(i))
		{
			continue;
		}
		
		GetClientAbsOrigin(i, targetOrigin);
		targetOrigin[2] += 2.0;
		if (GetVectorDistance(origin, targetOrigin) <= g_cZEFreezenadedistance.FloatValue)
		{
			Handle trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
			
			if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0))
			{
				SetEntityRenderColor(i, 0, 191, 255);
				SetEntityMoveType(i, MOVETYPE_NONE);
				CreateTimer(5.0, Timer_Unfreeze, GetClientUserId(i));
				CloseHandle(trace);
			}
			
			else
			{
				CloseHandle(trace);
				
				GetClientEyePosition(i, targetOrigin);
				targetOrigin[2] -= 2.0;
				
				trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
				
				if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0))
				{
					SetEntityRenderColor(i, 0, 191, 255);
					SetEntityMoveType(i, MOVETYPE_NONE);
					CreateTimer(5.0, Timer_Unfreeze, GetClientUserId(i));
				}
				
				CloseHandle(trace);
			}
		}
	}
	
	TE_SetupBeamRingPoint(origin, 10.0, g_cZEFreezenadedistance.FloatValue, g_iBeamSprite, g_iHaloSprite, 1, 1, 0.2, 100.0, 1.0, FlashColor, 0, 0);
	g_bFreezeFlash[client] = false;
	TE_SendToAll();
	LightCreate(SMOKE, origin);
}

void BeamFollowCreate(int entity, int color[4])
{
	TE_SetupBeamFollow(entity, g_iBeamSprite, 0, 1.0, 10.0, 10.0, 5, color);
	TE_SendToAll();
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrContains(classname, "_projectile") != -1)
	{
		SDKHook(entity, SDKHook_SpawnPost, Grenade_SpawnPost);
	}
}

void DisableSpells(int client)
{
	g_bFireHE[client] = false;
	g_bOnFire[client] = false;
	g_bFreezeFlash[client] = false;
	g_bBeacon[client] = false;
	g_bInfectNade[client] = false;
	i_Power[client] = 0;
	f_causeddamage[client] = 0.0;
	g_bUltimate[client] = false;
}

void RemoveGuns(int client)
{
	int primweapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	if (IsValidEdict(primweapon) && primweapon != -1)
	{
		RemoveEdict(primweapon);
	}
	
	int secweapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if (IsValidEdict(secweapon) && secweapon != -1)
	{
		RemoveEdict(secweapon);
	}
	
	RemoveNades(client);
}

stock int RemoveNades(int iClient)
{
	while (RemoveWeaponBySlot(iClient, 3)) {  }
	for (new i = 0; i < 6; i++)
	SetEntProp(iClient, Prop_Send, "m_iAmmo", 0, _, g_iaGrenadeOffsets[i]);
}

stock bool RemoveWeaponBySlot(int iClient, int iSlot)
{
	int iEntity = GetPlayerWeaponSlot(iClient, iSlot);
	if (IsValidEdict(iEntity)) {
		RemovePlayerItem(iClient, iEntity);
		AcceptEntityInput(iEntity, "Kill");
		return true;
	}
	return false;
}

// Show overlay to all clients with lifetime | 0.0 = no auto remove
stock void ShowOverlayAll(char[] path, float lifetime)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || IsClientSourceTV(i) || IsClientReplay(i))
			continue;
		
		ClientCommand(i, "r_screenoverlay \"%s.vtf\"", path);
		
		if (lifetime != 0.0)
			CreateTimer(lifetime, DeleteOverlay, GetClientUserId(i));
	}
}

// Remove overlay from a client - Timer!
stock Action DeleteOverlay(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
		return;
	
	ClientCommand(client, "r_screenoverlay \"\"");
}

public Action CS_OnBuyCommand(int iClient, const char[] chWeapon)
{
    if(StrEqual(chWeapon, "smokegrenade") || StrEqual(chWeapon, "incgrenade") || StrEqual(chWeapon, "molotov") || StrEqual(chWeapon, "flashbang") || StrEqual(chWeapon, "hegrenade") || StrEqual(chWeapon, "decoy") || StrEqual(chWeapon, "g3sg1") || StrEqual(chWeapon, "scar20")) 
    {
        return Plugin_Handled; // Block the buy.
    }
    
    return Plugin_Continue; // Continue as normal.
} 

public Action Command_PowerH(int client, const char[] command, int args)
{
    if(IsValidClient(client) && g_bInfected[client] == false && i_hclass[client] > 0)
	{
    	if(g_bUltimate[client] == true)
    	{
			if (Human_Power[client][0] != '-')
			{
				char NameOfPower1[25];
				char NameOfPower2[25];
				char NameOfPower3[25];
				Format(NameOfPower1, sizeof(NameOfPower1), "SuperKnockback");
				Format(NameOfPower2, sizeof(NameOfPower2), "Healing");
				Format(NameOfPower3, sizeof(NameOfPower3), "Unlimited");
				if (StrEqual(Human_Power[client], NameOfPower1, false))
				{
					i_Power[client] = 1;
				}
				else if (StrEqual(Human_Power[client], NameOfPower2, false))
				{
					i_Power[client] = 2;	
					H_AmmoTimer[client] = CreateTimer(1.0, PowerOfTimer, client, TIMER_REPEAT);
				}
				else if (StrEqual(Human_Power[client], NameOfPower3, false))
				{
					i_Power[client] = 3;	
					H_AmmoTimer[client] = CreateTimer(1.0, PowerOfTimer, client, TIMER_REPEAT);
				}
				CreateTimer(6.0, EndPower, client);
				PrintToChatAll(" \x04[ZE-Class]\x01 Player \x06%N\x01 activated his ultimate power!", client);
				PrintHintText(client, "\n<font class='fontSize-l'><font color='#00FF00'>[ZE-Class]</font> <font color='#FFFFFF'>You activated:</font> <font color='#FF8C00'>%s", Human_Power[client]);
				EmitSoundToAll("ze_premium/ze-powereffect.mp3", client);
				g_bUltimate[client] = false;
			}
		}
		else
		{
			PrintToChat(client, " \x04[ZE-Class]\x01 Your ultimate power is \x07not\x01 ready !");
		}
	}
}

stock int CheckPlayerRange(int client)
{
	for (int i; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsValidClient(client))
		{
			if (i != client && IsPlayerAlive(i) && IsPlayerAlive(client))
			{
				if(g_bInfected[i] == false && g_bInfected[client] == false)
				{
					float iOrigin[3];
					GetClientAbsOrigin(client, iOrigin);
					float fOrigin[3];
					GetClientAbsOrigin(i, fOrigin);
					if (GetVectorDistance(iOrigin, fOrigin) <= 200)
					{
						iOrigin[2] += 30.0;
						fOrigin[2] += 30.0;
						SetEntityHealth(i, GetClientHealth(i) + 5);
						TE_SetupBeamPoints(iOrigin, fOrigin, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 0.33, 0.33, 10, 0.5, {0, 255, 0, 255}, 0);
						TE_SendToAll();
					}
				}
			}
		}
	}
	return false;
}