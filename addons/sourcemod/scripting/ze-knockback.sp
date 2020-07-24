// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <zepremium>
#include <cstrike>

ConVar gc_ZEKnockbackAmount;

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
	
	AutoExecConfig(true, "ze_knockback");
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
