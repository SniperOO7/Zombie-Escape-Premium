#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Sniper007"
#define PLUGIN_VERSION "2.00"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <emitsoundany>

#include "ze-premium/ze-globals.sp"
#include "ze-premium/ze-client.sp"
#include "ze-premium/ze-timers.sp"
#include "ze-premium/ze-playerevents.sp"
#include "ze-premium/ze-menus.sp"
#include "ze-premium/ze-stocks.sp"
#include "ze-premium/ze-natives.sp"

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Zombie Escape Premium", 
	author = PLUGIN_AUTHOR, 
	description = "Zombie escape plugin with new features", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/Sniper-oo7/"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_menu", CMD_MainMenu);
	RegConsoleCmd("sm_zombieescape", CMD_MainMenu);
	RegConsoleCmd("sm_ze", CMD_MainMenu);
	RegConsoleCmd("sm_zr", CMD_MainMenu);
	RegConsoleCmd("sm_zm", CMD_MainMenu);
	
	RegConsoleCmd("sm_respawn", CMD_Respawn);
	RegConsoleCmd("sm_r", CMD_Respawn);
	
	RegConsoleCmd("sm_get", CMD_GetGun);
	RegConsoleCmd("sm_weapon", CMD_Weapon);
	RegConsoleCmd("sm_weapons", CMD_Weapon);
	RegConsoleCmd("sm_gun", CMD_Weapon);
	RegConsoleCmd("sm_guns", CMD_Weapon);
	
	RegConsoleCmd("sm_zclass", CMD_Class);
	RegConsoleCmd("sm_class", CMD_Class);
	RegConsoleCmd("sm_zclass", CMD_Class);
	RegConsoleCmd("sm_human", CMD_Class);
	RegConsoleCmd("sm_humanclass", CMD_Class);
	
	RegConsoleCmd("sm_leader", CMD_Leader);
	
	RegConsoleCmd("sm_za", CMD_Admin);
	RegConsoleCmd("sm_zea", CMD_Admin);
	RegConsoleCmd("sm_zadmin", CMD_Admin);
	RegConsoleCmd("sm_zeadmin", CMD_Admin);
	
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", OnPlayerDeath);
	HookEvent("round_end", OnRoundEnd);
	HookEvent("player_spawn", Event_Spawn, EventHookMode_Post);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
	HookEvent("flashbang_detonate", Event_FlashFlashDetonate, EventHookMode_Pre);
	
	g_cZEZombieModel = CreateConVar("sm_ze_zombie_model", "models/player/custom_player/kodua/frozen_nazi/frozen_nazi.mdl", "Model for zombies");
	g_cZEHumanModel = CreateConVar("sm_ze_human_model", "models/player/custom_player/pikajew/hlvr/hazmat_worker/hazmat_worker.mdl", "Model for humans");
	g_cZEDefendModelVmt = CreateConVar("sm_ze_defend_leader_material_vmt", "materials/ze_premium/defendhere.vmt", "Model for defend material sprite/marker (VMT)");
	g_cZEDefendModelVtf = CreateConVar("sm_ze_defend_leader_material_vtf", "materials/ze_premium/defendhere.vtf", "Model for defend material sprite/marker (VTF)");
	g_cZEFollowmeModelVmt = CreateConVar("sm_ze_followme_leader_material_vmt", "materials/ze_premium/followme.vmt", "Model for followme material sprite (VMT)");
	g_cZEFollowmeModelVtf = CreateConVar("sm_ze_followme_leader_material_vtf", "materials/ze_premium/followme.vtf", "Model for followme material sprite (VTF)");
	
	g_cZENemesis = CreateConVar("sm_ze_nemesis", "10", "How much chance in percent to first zombie will be nemesis, 0 = disabled");
	g_cZENemesisModel = CreateConVar("sm_ze_nemesis_model", "models/player/custom_player/owston/re3/nemesis/nemesis_remake1.mdl", "Model of Nemesis");
	g_cZENemesisHP = CreateConVar("sm_ze_nemesis_hp", "30000", "Amout of nemesis HP");
	g_cZENemesisSpeed = CreateConVar("sm_ze_nemesis_speed", "1.7", "Amout of nemesis speed");
	g_cZENemesisGravity = CreateConVar("sm_ze_nemesis_gravity", "0.7", "Amout of nemesis gravity");
	
	g_cZEFirstInfection = CreateConVar("sm_ze_infection", "30", "Time to first infection");
	g_cZEZombieHP = CreateConVar("sm_ze_zombiehp", "10000", "Amout of zombie HP");
	g_cZEMotherZombieHP = CreateConVar("sm_ze_motherzombiehp", "20000", "Amout of mother zombie HP");
	g_cZEHumanHP = CreateConVar("sm_ze_humanhp", "100", "Amout of human HP");
	g_cZEZombieSpeed = CreateConVar("sm_ze_zombiespeed", "1.2", "Amout of zombie speed");
	g_cZEHealthShot = CreateConVar("sm_ze_healthshot", "2000", "Price of healthshot");
	g_cZEHeNade = CreateConVar("sm_ze_henade", "1000", "Price of he nade");
	g_cZEFlashNade = CreateConVar("sm_ze_flashnade", "1000", "Price of flash nade");
	g_cZEMolotov = CreateConVar("sm_ze_molotov", "1000", "Price of molotov");
	g_cZEMaximumUsage = CreateConVar("sm_ze_maximum_usage", "2", "Maximum usage of weapon menu");
	
	AutoExecConfig(true, "ze_premium");
}

// Natives
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Natives
	CreateNative("ZR_IsInfection", Native_StartingInfection);
	CreateNative("ZR_IsClientZombie", Native_IsInfected);
	CreateNative("ZR_IsClientHuman", Native_IsHuman);
	CreateNative("ZR_IsNemesis", Native_IsNemesis);
	
	RegPluginLibrary("zepremium");
	
	return APLRes_Success;
}

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			Maximum_Choose[i] = 0;
			g_bSamegun[i] = false;
			Format(Primary_Gun[i], sizeof(Primary_Gun), "1");
			Format(Secondary_Gun[i], sizeof(Secondary_Gun), "1");
		}
	}
	
	//MODELS
	g_cZEHumanModel.GetString(HUMANMODEL, sizeof(HUMANMODEL));
	g_cZEZombieModel.GetString(ZOMBIEMODEL, sizeof(ZOMBIEMODEL));
	g_cZENemesisModel.GetString(NEMESISMODEL, sizeof(NEMESISMODEL));
	g_cZEDefendModelVmt.GetString(DEFEND, sizeof(DEFEND));
	g_cZEDefendModelVtf.GetString(DEFENDVTF, sizeof(DEFENDVTF));
	g_cZEFollowmeModelVmt.GetString(FOLLOWME, sizeof(FOLLOWME));
	g_cZEFollowmeModelVtf.GetString(FOLLOWMEVTF, sizeof(FOLLOWMEVTF));
	
	PrecacheModel(HUMANMODEL);
	PrecacheModel(NEMESISMODEL);
	PrecacheModel(ZOMBIEMODEL);
	
	//DECALS
	AddFileToDownloadsTable(DEFENDVTF);
	AddFileToDownloadsTable(DEFEND);
	AddFileToDownloadsTable(FOLLOWMEVTF);
	AddFileToDownloadsTable(FOLLOWME);
	
	PrecacheDecal(DEFEND, true);
	PrecacheDecal(DEFENDVTF, true);
	PrecacheDecal(FOLLOWME, true);
	PrecacheDecal(FOLLOWMEVTF, true);
	
	//SOUNDS
	AddFileToDownloadsTable("sound/ze_premium/ze-defend.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-fire.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-fire2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-folowme.mp3");
	AddFileToDownloadsTable("sound/ze_premium/freeze.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-hit.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-die.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-die2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-die3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-ctdie.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-ctdie2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-ctdie3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-pain.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-pain2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-pain3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-pain4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-pain5.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-pain6.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-respawn.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-nemesis.mp3");
	
	AddFileToDownloadsTable("sound/ze_premium/10.mp3");
	AddFileToDownloadsTable("sound/ze_premium/9.mp3");
	AddFileToDownloadsTable("sound/ze_premium/8.mp3");
	AddFileToDownloadsTable("sound/ze_premium/7.mp3");
	AddFileToDownloadsTable("sound/ze_premium/6.mp3");
	AddFileToDownloadsTable("sound/ze_premium/5.mp3");
	AddFileToDownloadsTable("sound/ze_premium/4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/1.mp3");
	
	PrecacheSound("ze_premium/ze-hit.mp3");
	PrecacheSound("ze_premium/ze-defend.mp3");
	PrecacheSound("ze_premium/ze-folowme.mp3");
	PrecacheSound("ze_premium/freeze.mp3");
	PrecacheSound("ze_premium/ze-fire.mp3");
	PrecacheSound("ze_premium/ze-fire2.mp3");
	PrecacheSound("ze_premium/ze-die.mp3");
	PrecacheSound("ze_premium/ze-die2.mp3");
	PrecacheSound("ze_premium/ze-die3.mp3");
	PrecacheSound("ze_premium/ze-ctdie.mp3");
	PrecacheSound("ze_premium/ze-ctdie2.mp3");
	PrecacheSound("ze_premium/ze-ctdie3.mp3");
	PrecacheSound("ze_premium/ze-pain.mp3");
	PrecacheSound("ze_premium/ze-pain2.mp3");
	PrecacheSound("ze_premium/ze-pain3.mp3");
	PrecacheSound("ze_premium/ze-pain4.mp3");
	PrecacheSound("ze_premium/ze-pain5.mp3");
	PrecacheSound("ze_premium/ze-pain6.mp3");
	PrecacheSound("ze_premium/ze-respawn.mp3");
	PrecacheSound("ze_premium/ze-nemesis.mp3");
	
	PrecacheSound("ze_premium/10.mp3");
	PrecacheSound("ze_premium/9.mp3");
	PrecacheSound("ze_premium/8.mp3");
	PrecacheSound("ze_premium/7.mp3");
	PrecacheSound("ze_premium/6.mp3");
	PrecacheSound("ze_premium/5.mp3");
	PrecacheSound("ze_premium/4.mp3");
	PrecacheSound("ze_premium/3.mp3");
	PrecacheSound("ze_premium/2.mp3");
	PrecacheSound("ze_premium/1.mp3");
	
	//BEACON
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow06.vmt");
	
	g_bRoundStarted = false;
	g_bPause = false;
}

public void Event_RoundStart(Event event, const char[] name, bool bDontBroadcast)
{
	if (H_FirstInfection != null)
	{
		KillTimer(H_FirstInfection);
		H_FirstInfection = null;
	}
	i_Infection = g_cZEFirstInfection.IntValue;
	H_FirstInfection = CreateTimer(1.0, FirstInfection, _, TIMER_REPEAT);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if (IsPlayerAlive(i))
			{	
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
				SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
				if (i_hclass[i] == 1)
				{
					SetEntityHealth(i, g_cZEHumanHP.IntValue);
					GivePlayerItem(i, "weapon_hegrenade");
					SetEntityModel(i, HUMANMODEL);
				}
				else if (i_hclass[i] == 2)
				{
					SetEntityHealth(i, g_cZEHumanHP.IntValue);
					GivePlayerItem(i, "weapon_healthshot");
					SetEntityModel(i, HUMANMODEL);
				}
				else if (i_hclass[i] == 3)
				{
					int newhp = g_cZEHumanHP.IntValue + 50;
					SetEntityHealth(i, newhp);
					SetEntityModel(i, HUMANMODEL);
				}
				else if (i_hclass[i] == 4)
				{
					i_protection[i] = 1;
					SetEntityHealth(i, g_cZEHumanHP.IntValue);
					SetEntityModel(i, HUMANMODEL);
				}
				else
				{
					SetEntityHealth(i, g_cZEHumanHP.IntValue);
					SetEntityModel(i, HUMANMODEL);
				}
				
				if (g_bSamegun[i] == true)
				{
					if (Primary_Gun[i][0] == 'w')
					{
						int primweapon = GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY);
						if (IsValidEdict(primweapon) && primweapon != -1)
						{
							RemoveEdict(primweapon);
						}
						GivePlayerItem(i, Primary_Gun[i]);
					}
					if (Secondary_Gun[i][0] == 'w')
					{
						int secweapon = GetPlayerWeaponSlot(i, CS_SLOT_SECONDARY);
						if (IsValidEdict(secweapon) && secweapon != -1)
						{
							RemoveEdict(secweapon);
						}
						GivePlayerItem(i, Secondary_Gun[i]);
					}
				}
			}
		}
	}
}

public void OnRoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	g_bRoundStarted = false;
	g_bMarker = false;
	g_bPause = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			CheckTeam(i);
			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
			if (H_Beacon[i] != null)
			{
				KillTimer(H_Beacon[i]);
				H_Beacon[i] = null;
			}
			g_bInfected[i] = false;
			typeofsprite[i] = 0;
			g_bBeacon[i] = false;
			g_bIsLeader[i] = false;
			spended[i] = 0;
			if (H_Beacon[i] != null)
			{
				KillTimer(H_Beacon[i]);
				H_Beacon[i] = null;	
			}
			g_bFireHE[i] = false;
			g_bHadHe[i] = false;
			g_bOnFire[i] = false;
			g_bFreezeFlash[i] = false;
		}
	}
}

public Action CMD_Weapon(int client, int args)
{
	if (IsValidClient(client))
	{
		if (GetClientTeam(client) == CS_TEAM_CT || i_Infection > 0)
		{
			openWeapons(client);
		}
		else
		{
			ReplyToCommand(client, " \x04[Zombie-Escape]\x01 You have to be a human");
		}
	}
}

public Action CMD_Admin(int client, int args)
{
	if (IsValidClient(client) && IsClientAdmin(client))
	{
		openAdmin(client);
	}
}

public Action CMD_Class(int client, int args)
{
	if (IsValidClient(client))
	{
		openClasses(client);
	}
}

public Action CMD_MainMenu(int client, int args)
{
	if (IsValidClient(client))
	{
		openMenu(client);
	}
}

public Action CMD_Respawn(int client, int args)
{
	if (IsValidClient(client))
	{
		if (i_Infection > 0)
		{
			CS_RespawnPlayer(client);
			PrintToChat(client, " \x04[ZE-Weapons]\x01 You was respawned!");
		}
	}
}

public Action CMD_Leader(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_bIsLeader[client] == true || IsClientAdmin(client) || IsClientLeader(client))
		{
			openLeader(client);
		}
		else
		{
			ReplyToCommand(client, " \x04[ZE-Leader]\x01 You are not leader!");
		}
	}
}

public Action CMD_GetGun(int client, int args)
{
	if (IsValidClient(client) && GetClientTeam(client) == CS_TEAM_CT || i_Infection > 0)
	{
		if (Primary_Gun[client][0] == 'w' || Secondary_Gun[client][0] == 'w')
		{
			if (Maximum_Choose[client] < g_cZEMaximumUsage.IntValue)
			{
				Maximum_Choose[client]++;
				int usages = g_cZEMaximumUsage.IntValue - Maximum_Choose[client];
				PrintToChat(client, " \x04[ZE-Weapons]\x01 You got your \x04chosen guns\x01, you have \x06%i\x01 uses left", usages);
				if (Primary_Gun[client][0] == 'w')
				{
					int primweapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
					if (IsValidEdict(primweapon) && primweapon != -1)
					{
						RemoveEdict(primweapon);
					}
					GivePlayerItem(client, Primary_Gun[client]);
				}
				if (Secondary_Gun[client][0] == 'w')
				{
					int secweapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
					if (IsValidEdict(secweapon) && secweapon != -1)
					{
						RemoveEdict(secweapon);
					}
					GivePlayerItem(client, Secondary_Gun[client]);
				}
			}
			else
			{
				PrintToChat(client, " \x04[ZE-Weapons]\x01 You have maxium usage of weapon menu !");
			}
		}
		else
		{
			PrintToChat(client, " \x04[ZE-Weapons]\x01 Choose some guns first !");
		}
	}
	else
	{
		PrintToChat(client, " \x04[ZE-Weapons]\x01 You have to be a human !");
	}
}

