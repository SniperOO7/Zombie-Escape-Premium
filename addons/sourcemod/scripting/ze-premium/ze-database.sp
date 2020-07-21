public void CheckDb(int client)
{
	char szSteamId[32], szQuery[512];
	GetClientAuthId(client, AuthId_Engine, szSteamId, sizeof(szSteamId));
	
	g_hDatabase.Format(szQuery, sizeof(szQuery), "SELECT * FROM ze_premium_sql WHERE steamid='%s'", szSteamId);
	g_hDatabase.Query(SQL_CheckDbQuery, szQuery, GetClientUserId(client));
}

public void SQL_CheckDbQuery(Database hDatabase, DBResultSet hResults, const char[] szError, any iData)
{
	if (hResults == null)
	{
		ThrowError(szError);
	}
	
	int client = GetClientOfUserId(iData);
	
	hResults.FetchRow();
	
	if (hResults.RowCount > 0)
	{
		i_hwins[client] = hResults.FetchInt(3);
		i_infectedh[client] = hResults.FetchInt(4);
		i_infectionban[client] = hResults.FetchInt(6);
	}
	else
	{
		char szQuery[512], szName[MAX_NAME_LENGTH], szSafeName[MAX_NAME_LENGTH], szSteamId[64];
		GetClientName(client, szName, sizeof(szName));
		GetClientAuthId(client, AuthId_Engine, szSteamId, sizeof(szSteamId));
		SQL_EscapeString(g_hDatabase, szName, szSafeName, sizeof(szSafeName));
		int wins = 0;
		int infected = 0;
		int infectionban = 0;
		int killedzm = 0;
		
		g_hDatabase.Format(szQuery, sizeof(szQuery), "INSERT INTO ze_premium_sql (lastname, steamid, humanwins, infected, killedzm, infectionban) VALUES ('%s', '%s', '%i', '%i', '%i', '%i')", szSafeName, szSteamId, wins, infected, killedzm, infectionban);
		g_hDatabase.Query(SQL_Error, szQuery);
	}
}

public void szQueryUpdateData(Database hDatabase, DBResultSet hResults, const char[] szError, any data)
{
	if (hResults == null)
	{
		ThrowError(szError);
	}
	
	int client = GetClientOfUserId(data);
	char szQuery[515];
	
	hResults.FetchRow();
	if (hResults.RowCount > 0)
	{
		char szSteamId[32];
		hResults.FetchString(2, szSteamId, sizeof(szSteamId));
		int hwins = hResults.FetchInt(3);
		int infected = hResults.FetchInt(4);
		int killedzm = hResults.FetchInt(5);
		
		int finalwins = hwins + i_wins[client];
		int finalinfected = infected + i_infected[client];
		int finalzmkills = killedzm + i_killedzm[client];
		i_hwins[client] = finalwins;
		i_infectedh[client] = finalinfected;
		
		g_hDatabase.Format(szQuery, sizeof(szQuery), "UPDATE ze_premium_sql SET humanwins = '%i', infected = '%i', killedzm = '%i' WHERE steamid='%s'", finalwins, finalinfected, finalzmkills, szSteamId);
		g_hDatabase.Query(SQL_Error, szQuery);
		
		i_wins[client] = 0;
		i_infected[client] = 0;
		i_killedzm[client] = 0;
	}
}

public void SQL_QueryToplist(Database hDatabase, DBResultSet hResults, const char[] szError, any data)
{
	if (hResults == null)
	{
		ThrowError(szError);
	}
	
	ResetPack(g_hDataPackUser);
	int client = ReadPackCell(g_hDataPackUser);
	
	char szName[MAX_NAME_LENGTH + 8];
	char text[64];
	Menu ClenList = CreateMenu(ClenListHandler);
	SetMenuTitle(ClenList, "[TOP] Player by top wins:");
   	while(hResults.FetchRow())
    {
		char szSteamId[32];
		hResults.FetchString(1, szName, sizeof(szName));
		hResults.FetchString(2, szSteamId, sizeof(szSteamId));
		int hwin = hResults.FetchInt(3);
		if(hwin > 0)
		{
			Format(text, sizeof(text), "➸ Players: %s | Human wins: %i", szName, hwin);
			AddMenuItem(ClenList, szSteamId, text, ITEMDRAW_DISABLED);
		}
	}
	DisplayMenu(ClenList, client, 60);
}

public int ClenListHandler(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
	}
}

public void szQueryCallback(Database hDatabase, DBResultSet hResults, const char[] szError, any data)
{
	if (hResults == null)
	{
		ThrowError(szError);
	}
	
	int client = GetClientOfUserId(data);
	
	hResults.FetchRow();
	if (hResults.RowCount > 0)
	{
		int hwin = hResults.FetchInt(3);
		int infected = hResults.FetchInt(4);
		int zombiekilled = hResults.FetchInt(5);
		
		Menu VipSystem = CreateMenu(VipSystemHandler);
		char wins[64];
		Format(wins, sizeof(wins), "Human Wins: %i", hwin, infected, zombiekilled);
		char infectedzm[64];
		Format(infectedzm, sizeof(infectedzm), "Infected Humans: %i", infected);
		char killedzm[64];
		Format(killedzm, sizeof(killedzm), "Killed Zombies: %i", zombiekilled);
		SetMenuTitle(VipSystem, "[Zombie Escape] Your statistic:");
		AddMenuItem(VipSystem, "x", wins, ITEMDRAW_DISABLED);
		AddMenuItem(VipSystem, "x", infectedzm, ITEMDRAW_DISABLED);
		AddMenuItem(VipSystem, "x", killedzm, ITEMDRAW_DISABLED);
		DisplayMenu(VipSystem, client, 60);
	}
}

public int VipSystemHandler(Handle menu, MenuAction action, int client, int item)
{
	char cValue[32];
	GetMenuItem(menu, item, cValue, sizeof(cValue));
	if (action == MenuAction_Select)
	{
	}
}