public void OnClientDisconnect(int client)
{
	if(g_bAntiDisconnect[client] == true)
	{
		char sBuffer[12];
		GetClientCookie(client, H_hAntiDisconnect, sBuffer, sizeof(sBuffer));
		int amout = StringToInt(sBuffer);
		amout += g_cZEInfectionBans.IntValue;
		char defamout[16];
		Format(defamout, sizeof(defamout), "%i", amout);
		SetClientCookie(client, H_hAntiDisconnect, defamout);
		CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "infected_disconnected", client, amout);
	}
	Maximum_Choose[client] = 0;
	g_bSamegun[client] = false;
	i_zclass[client] = 0;
	typeofsprite[client] = 0;
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
	g_hCooldown[client] = false;
}

public void OnClientPutInServer(int client)
{
	Maximum_Choose[client] = 0;
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
	g_hCooldown[client] = false;
	g_bInfectNade[client] = false;
	i_zclass[client] = 0;
	i_respawn[client] = 0;
	i_hclass[client] = 0;
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
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
}
