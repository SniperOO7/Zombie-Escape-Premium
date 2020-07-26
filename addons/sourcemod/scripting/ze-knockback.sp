// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <zepremium>
#include <entWatch>
#include <cstrike>

ConVar gc_ZEKnockbackAmount;

bool g_bHaveItem[MAXPLAYERS + 1] = false;

// Info
public Plugin myinfo = {
	name = "Zombie KnockBack",
	author = "shanapu & Sniper007",
	description = "Knockback for zombies",
	version = "1.0",
	url = "https://steamcommunity.com/id/Sniper-oo7/"
};

// Start
public void OnPluginStart()
{
	HookEvent("player_hurt", Event_PlayerHurt);
	
	gc_ZEKnockbackAmount = CreateConVar("sm_zombie_knockback", "20.0", "Force of the knockback when shot at. Zombies only", _, true, 1.0, true, 100.0);
	
	CreateTimer(1.0, CheckItem, _, TIMER_REPEAT);
	
	AutoExecConfig(true, "ze_knockback");
}

// Natives
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Natives
	CreateNative("ZR_HaveItem", Native_HaveItem);
	
	RegPluginLibrary("zeknockback");
	
	return APLRes_Success;
}

public int Native_HaveItem(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	if (!g_bHaveItem[client])
	{
		return false;
	}
	return true;
}

public Action Event_PlayerHurt(Handle event, char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (!IsValidClient(attacker) || ZR_IsClientHuman(victim))
		return;

	int damage = GetEventInt(event, "dmg_health");

	float knockback;
	if(ZR_Power(attacker) == 1)
	{
		knockback = gc_ZEKnockbackAmount.FloatValue + 20.0; // knockback amount
	}
	else
	{
		knockback = gc_ZEKnockbackAmount.FloatValue; // knockback amount
	}
	float clientloc[3];
	float attackerloc[3];

	GetClientAbsOrigin(victim, clientloc);

	// Get attackers eye position.
	GetClientEyePosition(attacker, attackerloc);

	// Get attackers eye angles.
	float attackerang[3];
	GetClientEyeAngles(attacker, attackerang);

	// Calculate knockback end-vector.
	TR_TraceRayFilter(attackerloc, attackerang, MASK_ALL, RayType_Infinite, KnockbackTRFilter);
	TR_GetEndPosition(clientloc);

	// Apply damage knockback multiplier.
	knockback *= damage;

	if (GetEntPropEnt(victim, Prop_Send, "m_hGroundEntity") == -1) knockback *= 0.5;

	// Apply knockback.
	KnockbackSetVelocity(victim, attackerloc, clientloc, knockback);
}

void KnockbackSetVelocity(int client, const float startpoint[3], const float endpoint[3], float magnitude)
{
	// Create vector from the given starting and ending points.
	float vector[3];
	MakeVectorFromPoints(startpoint, endpoint, vector);

	// Normalize the vector (equal magnitude at varying distances).
	NormalizeVector(vector, vector);

	// Apply the magnitude by scaling the vector (multiplying each of its components).
	ScaleVector(vector, magnitude);

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vector);
}

public bool KnockbackTRFilter(int entity, int contentsMask)
{
	// If entity is a player, continue tracing.
	if (entity > 0 && entity < MAXPLAYERS)
	{
		return false;
	}

	// Allow hit.
	return true;
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

public Action CheckItem(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if (IsPlayerAlive(i))
			{
				if(entWatch_HasSpecialItem(i) == true)
				{
					g_bHaveItem[i] = true;
				}
				else
				{
					g_bHaveItem[i] = false;
				}
			}
		}	
	}	
}
