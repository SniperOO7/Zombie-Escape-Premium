public int Native_StartingInfection(Handle plugin, int argc)
{
	if (i_Infection == 0)
	{
		return false;
	}
	return true;
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

public int Native_IsNemesis(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	if (!g_bIsNemesis[client])
	{
		return false;
	}
	return true;
}