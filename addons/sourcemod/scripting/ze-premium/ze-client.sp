public void OnClientDisconnect(int client)
{
	Maximum_Choose[client] = 0;
	g_bSamegun[client] = false;
	i_zclass[client] = 0;
	typeofsprite[client] = 0;
	i_hclass[client] = 0;
	g_bBeacon[client] = false;
	g_bIsLeader[client] = false;
	g_bHadHe[client] = false;
	g_bInfected[client] = false;
	g_bFireHE[client] = false;
	g_bOnFire[client] = false;
	g_bFreezeFlash[client] = false;
}

public void OnClientPutInServer(int client)
{
	Maximum_Choose[client] = 0;
	g_bSamegun[client] = false;
	g_bIsLeader[client] = false;
	g_bInfected[client] = false;
	g_bBeacon[client] = false;
	g_bFireHE[client] = false;
	g_bHadHe[client] = false;
	g_bOnFire[client] = false;
	g_bFreezeFlash[client] = false;
	i_zclass[client] = 0;
	i_hclass[client] = 0;
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public void OnClientPostAdminCheck(int client)
{
	if(i_Infection <= 0)
	{
		CreateTimer(1.0, SwitchTeam, client);
	}
}