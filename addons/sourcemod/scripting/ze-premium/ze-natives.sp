public int Native_StartingInfection(Handle plugin, int argc)
{
	if (i_Infection == 0)
	{
		return false;
	}
	return true;
}

public int Native_SpecialRound(Handle plugin, int argc)
{
	if (i_SpecialRound > 0)
	{
		return true;
	}
	return false;
}

public int Native_IsInfected(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	if (!g_bInfected[client])
	{
		return false;
	}
	return true;
}

public int Native_IsHuman(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	if (!g_bInfected[client])
	{
		return true;
	}
	return false;
}

public int Native_IsNemesis(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	if (!g_bIsNemesis[client])
	{
		return false;
	}
	return true;
}

public int Native_SetRespawnAction(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	if (!IsValidClient(client))
	{
		return;
	}
	
	int respawnaction = GetNativeCell(2);
	if (0 > respawnaction)
	{
		respawnaction = 0;
	}
	
	if (respawnaction > 1)
	{
		respawnaction = 1;
	}
	
	Forward_SetAnotherRespawn(client, respawnaction);
}

void Forward_SetAnotherRespawn(int client, int respawn)
{
	if(respawn > 0)
	{
		g_bNoRespawn[client] = true;
	}
	else
	{
		g_bNoRespawn[client] = false;
	}
}