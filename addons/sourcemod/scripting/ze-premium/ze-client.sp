public void OnClientDisconnect(int client)
{
	if(g_bAntiDisconnect[client] == true)
	{
		char szSteamId[32], szQuery[512];
		GetClientAuthId(client, AuthId_Engine, szSteamId, sizeof(szSteamId));
		int newiban = i_infectionban[client] + g_cZEInfectionBans.IntValue;
		g_hDatabase.Format(szQuery, sizeof(szQuery), "UPDATE ze_premium_sql SET infectionban = '%i' WHERE steamid='%s'", newiban, szSteamId);
		g_hDatabase.Query(SQL_Error, szQuery);
		CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "infected_disconnected", client, newiban);
	}
	i_Maximum_Choose[client] = 0;
	g_bSamegun[client] = false;
	i_zclass[client] = 0;
	i_typeofsprite[client] = 0;
	i_hclass[client] = 0;
	i_respawn[client] = 0;
	g_bBeacon[client] = false;
	g_bIsLeader[client] = false;
	g_bInfected[client] = false;
	g_bFireHE[client] = false;
	g_bNoRespawn[client] = false;
	g_bIsNemesis[client] = false;
	g_bOnFire[client] = false;
	g_bFreezeFlash[client] = false;
	g_bAntiDisconnect[client] = false;
	g_bInfectNade[client] = false;
	PrintToChatAll(" \x04[Zombie Escape] \x01Player\x06 %N\x01 has disconnected from the server!", client);
}

public void OnClientPutInServer(int client)
{
	i_Maximum_Choose[client] = 0;
	g_bSamegun[client] = false;
	g_bIsLeader[client] = false;
	g_bInfected[client] = false;
	g_bBeacon[client] = false;
	g_bFireHE[client] = false;
	g_bIsNemesis[client] = false;
	g_bOnFire[client] = false;
	g_bFreezeFlash[client] = false;
	g_bNoRespawn[client] = false;
	g_bAntiDisconnect[client] = false;
	g_bInfectNade[client] = false;
	i_respawn[client] = 0;
	i_Power[client] = 0;
	g_bUltimate[client] = false;
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	PrintToChatAll(" \x04[Zombie Escape] \x01Player\x06 %N\x01 has join to the server!", client);
}

public void OnClientPostAdminCheck(int client)
{
	if(!IsFakeClient(client))
	{
		CheckDb(client);
	}
	
	if(i_Infection <= 0)
	{
		CreateTimer(1.0, SwitchTeam, client);
	}
	
	char szClass[32];
	GetClientCookie(client, g_hZombieClass, szClass, sizeof(szClass));
	i_zclass[client] = StringToInt(szClass);
	
	GetClientCookie(client, g_hHumanClass, szClass, sizeof(szClass));
	i_hclass[client] = StringToInt(szClass);
}
