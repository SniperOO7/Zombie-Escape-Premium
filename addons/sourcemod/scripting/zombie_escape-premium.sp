#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Sniper007"
#define PLUGIN_VERSION "6.0"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <colors>
#include <clientprefs>
#include <smlib>
#include <sdkhooks>
#include <zepremium>
#include <emitsoundany>

#include "ze-premium/ze-globals.sp"
#include "ze-premium/ze-stocks.sp"
#include "ze-premium/ze-client.sp"
#include "ze-premium/ze-timers.sp"
#include "ze-premium/ze-database.sp"
#include "ze-premium/ze-playerevents.sp"
#include "ze-premium/ze-menus.sp"
#include "ze-premium/ze-natives.sp"
#include "ze-premium/ze-keyvalues.sp"

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
	LoadTranslations("ZE-Premium");
	
	RegConsoleCmd("sm_menu", CMD_MainMenu);
	RegConsoleCmd("sm_zombieescape", CMD_MainMenu);
	RegConsoleCmd("sm_ze", CMD_MainMenu);
	RegConsoleCmd("sm_zr", CMD_MainMenu);
	RegConsoleCmd("sm_zm", CMD_MainMenu);
	
	RegConsoleCmd("sm_respawn", CMD_Respawn);
	RegConsoleCmd("sm_r", CMD_Respawn);
	
	RegConsoleCmd("sm_rifle", CMD_WeaponsRifle);
	RegConsoleCmd("sm_heavygun", CMD_WeaponsHeavy);
	RegConsoleCmd("sm_smg", CMD_WeaponsSmg);
	RegConsoleCmd("sm_pistols", CMD_WeaponsPistols);
	
	RegConsoleCmd("sm_get", CMD_GetGun);
	RegConsoleCmd("sm_weapon", CMD_Weapon);
	RegConsoleCmd("sm_weapons", CMD_Weapon);
	RegConsoleCmd("sm_gun", CMD_Weapon);
	RegConsoleCmd("sm_guns", CMD_Weapon);
	
	RegConsoleCmd("sm_class", CMD_Class);
	
	RegConsoleCmd("sm_leader", CMD_Leader);
	
	RegConsoleCmd("sm_shop", CMD_Shop);
	
	RegConsoleCmd("sm_humanclass", CMD_HumanClass);
	RegConsoleCmd("sm_zombieclass", CMD_ZMClass);
	
	RegConsoleCmd("sm_za", CMD_Admin);
	RegConsoleCmd("sm_zea", CMD_Admin);
	RegConsoleCmd("sm_zadmin", CMD_Admin);
	RegConsoleCmd("sm_zeadmin", CMD_Admin);
	
	RegConsoleCmd("sm_p90", CMD_P90);
	RegConsoleCmd("sm_bizon", CMD_Bizon);
	RegConsoleCmd("sm_negev", CMD_Negev);
	
	RegConsoleCmd("sm_topplayer", CMD_Topplayer);
	RegConsoleCmd("sm_toplayer", CMD_Topplayer);
	RegConsoleCmd("sm_nejhrac", CMD_Topplayer);
	RegConsoleCmd("sm_top10", CMD_Topplayer);
	
	RegConsoleCmd("sm_stats", CMD_Statistic);
	
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", OnPlayerDeath);
	HookEvent("round_end", OnRoundEnd);
	HookEvent("player_spawn", Event_Spawn, EventHookMode_Post);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
	HookEvent("hegrenade_detonate", OnHeGrenadeDetonate);
	
	g_cZEZombieModel = CreateConVar("sm_ze_zombie_model", "models/player/custom_player/kodua/frozen_nazi/frozen_nazi.mdl", "Model for zombies");
	g_cZEHumanModel = CreateConVar("sm_ze_human_model", "models/player/custom_player/pikajew/hlvr/hazmat_worker/hazmat_worker.mdl", "Model for humans");
	g_cZEDefendModelVmt = CreateConVar("sm_ze_defend_leader_material_vmt", "materials/ze_premium/defendhere.vmt", "Model for defend material sprite/marker (VMT)");
	g_cZEDefendModelVtf = CreateConVar("sm_ze_defend_leader_material_vtf", "materials/ze_premium/defendhere.vtf", "Model for defend material sprite/marker (VTF)");
	g_cZEFollowmeModelVmt = CreateConVar("sm_ze_followme_leader_material_vmt", "materials/ze_premium/followme.vmt", "Model for followme material sprite (VMT)");
	g_cZEFollowmeModelVtf = CreateConVar("sm_ze_followme_leader_material_vtf", "materials/ze_premium/followme.vtf", "Model for followme material sprite (VTF)");
	g_cZEZMwinmodelVmt = CreateConVar("sm_ze_zombie_win_material_vmt", "materials/ze_premium/zombiewin.vmt", "Model for zombie win material sprite (VMT)");
	g_cZEZMwinmodelVtf = CreateConVar("sm_ze_zombie_win_material_vtf", "materials/ze_premium/zombiewin.vtf", "Model for zombie win material sprite (VTF)");
	g_cZEHUMANwinmodelVmt = CreateConVar("sm_ze_human_win_material_vmt", "materials/ze_premium/humanwin.vmt", "Model for human win material sprite (VMT)");
	g_cZEHUMANwinmodelVtf = CreateConVar("sm_ze_human_win_material_vtf", "materials/ze_premium/humanwin.vtf", "Model for human win material sprite (VTF)");
	
	g_cZENemesis = CreateConVar("sm_ze_nemesis", "10", "How much chance in percent to first zombie will be nemesis, 0 = disabled");
	g_cZENemesisModel = CreateConVar("sm_ze_nemesis_model", "models/player/custom_player/ventoz/marauder/marauder.mdl", "Model of Nemesis");
	g_cZENemesisHP = CreateConVar("sm_ze_nemesis_hp", "30000", "Amout of nemesis HP");
	g_cZENemesisSpeed = CreateConVar("sm_ze_nemesis_speed", "1.7", "Amout of nemesis speed");
	g_cZENemesisGravity = CreateConVar("sm_ze_nemesis_gravity", "0.7", "Amout of nemesis gravity");
	
	g_cZEZombieRiots = CreateConVar("sm_ze_zombie_riot", "10", "How much chance in percent to will be zombie riot round, 0 = disabled");
	g_cZEZombieShieldType = CreateConVar("sm_ze_zombie_riot_shield", "1", "When will player get shield (1 = after infected, respawn, 0 = only after respawn)");
	
	g_cZEFirstInfection = CreateConVar("sm_ze_infection", "30", "Time to first infection");
	g_cZEZombieHP = CreateConVar("sm_ze_zombiehp", "10000", "Amout of zombie HP");
	g_cZEMotherZombieHP = CreateConVar("sm_ze_motherzombiehp", "20000", "Amout of mother zombie HP");
	g_cZEHumanHP = CreateConVar("sm_ze_humanhp", "100", "Amout of human HP");
	g_cZEZombieSpeed = CreateConVar("sm_ze_zombiespeed", "1.2", "Amout of zombie speed");
	g_cZEHealthShot = CreateConVar("sm_ze_healthshot", "2000", "Price of healthshot");
	g_cZEHeNade = CreateConVar("sm_ze_henade", "1000", "Price of he nade");
	g_cZEFlashNade = CreateConVar("sm_ze_flashnade", "1000", "Price of flash nade");
	g_cZEMolotov = CreateConVar("sm_ze_molotov", "1000", "Price of molotov");
	g_cZEInfnade = CreateConVar("sm_ze_infnade", "2000", "Price of infection nade");
	g_cZEInfnadeusages = CreateConVar("sm_ze_infnade_usages", "1", "How many times can zombies buy this nade in 1 round (for whole team)");
	g_cZEMaximumUsage = CreateConVar("sm_ze_maximum_usage", "2", "Maximum usage of weapon menu");
	g_cZEInfnadedistance = CreateConVar("sm_ze_infnade_distance", "400", "Distance of infection grenade");
	g_cZEFreezenadedistance = CreateConVar("sm_ze_freezenade_distance", "400", "Distance of freeze grenade");
	
	g_cZEHeGrenadeEffect = CreateConVar("sm_ze_hegrenade_effect", "1", "1 = enable he fire grenade, 0 = disable");
	g_cZEFlashbangEffect = CreateConVar("sm_ze_decoy_effect", "1", "1 = enable decoy freeze grenade, 0 = disable");
	g_cZESmokeEffect = CreateConVar("sm_ze_smoke_effect", "1", "1 = enable smoke infect grenade, 0 = disable");
	
	g_cZEInfectionBans = CreateConVar("sm_ze_infection_bans", "2", "How many rounds ban player will get after he disconnected, when he is first zombie");
	g_cZEInfectionTime = CreateConVar("sm_ze_infection_time", "10", "How long (sec) player have to be first zombie to don't get infection ban, after he disconnected");
	g_cZEInfectionBanPlayers = CreateConVar("sm_ze_infection_ban_players", "3", "How many player have to be on server for removing infection bans on round end");
	
	g_cZEHUDInfo = CreateConVar("sm_ze_hud_information", "1", "1 = enable hud information panel, 0 = disable");
	
	g_cZEZombieSounds = CreateConVar("sm_ze_zombie_attack_sounds", "1", "1 = enable zombie attack sound, 0 = disable");
	
	BuildPath(Path_SM, g_sZEConfig, sizeof(g_sZEConfig), "configs/ze_premium/zombies_classes.cfg");
	BuildPath(Path_SM, g_sZEConfig2, sizeof(g_sZEConfig2), "configs/ze_premium/humans_classes.cfg");
	BuildPath(Path_SM, g_sZEConfig3, sizeof(g_sZEConfig3), "configs/ze_premium/weapons.cfg");
	
	CreateTimer(1.0, HUD, _, TIMER_REPEAT);
	CreateTimer(5.0, PointsCheck, _, TIMER_REPEAT);
	
	AddNormalSoundHook(SoundHook);
	
	AutoExecConfig(true, "ze_premium");
}

public void OnConfigsExecuted()
{
	Database.Connect(SQL_Connection, "ze_premium_sql");
	
	kvZombies = new KeyValues("zombies_classes");
	kvHumans = new KeyValues("humans_classes");
	kvWeapons = new KeyValues("Weapons");
	kvZombies.ImportFromFile(g_sZEConfig);
	kvHumans.ImportFromFile(g_sZEConfig2);
	kvWeapons.ImportFromFile(g_sZEConfig3);
}

public void SQL_Error(Database hDatabase, DBResultSet hResults, const char[] szError, int iData)
{
	if (hResults == null)
	{
		ThrowError(szError);
	}
}

public void SQL_Connection(Database hDatabase, const char[] szError, int iData)
{
	if (hDatabase == null)
	{
		ThrowError(szError);
	}
	else
	{
		g_hDatabase = hDatabase;
		//Tady si většinou vytváříš tabulku, pokud ji ještě nemáš, toto doporučuji vždy dělat - taková kontrola, jestli ti to funguje, když se tabulka vytvoří, tak si cajk
		g_hDatabase.Query(SQL_Error, "CREATE TABLE IF NOT EXISTS ze_premium_sql ( `id` INT NOT NULL AUTO_INCREMENT , `lastname` VARCHAR(128) NOT NULL DEFAULT 'N/A' , `steamid` VARCHAR(64) NOT NULL , `humanwins` INT(128) NOT NULL , `infected` INT(128) NOT NULL , `killedzm` INT(128) NOT NULL , `infectionban` INT(128) NOT NULL , PRIMARY KEY (`id`)) ENGINE = InnoDB;");
		g_hDatabase.SetCharset("utf8mb4");
		PrintToServer("[MySQL] Ze Premium-SQL connected.");
	}
}

// Natives
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Natives
	CreateNative("ZR_IsInfection", Native_StartingInfection);
	CreateNative("ZR_IsSpecialround", Native_SpecialRound);
	CreateNative("ZR_RespawnAction", Native_SetRespawnAction);
	CreateNative("ZR_IsClientZombie", Native_IsInfected);
	CreateNative("ZR_IsClientHuman", Native_IsHuman);
	CreateNative("ZR_IsNemesis", Native_IsNemesis);
	
	gF_ClientInfected = CreateGlobalForward("ZR_OnClientInfected", ET_Ignore, Param_Cell, Param_Cell);
	gF_ClientHumanPost = CreateGlobalForward("ZR_OnClientHumanPost", ET_Ignore, Param_Cell);
	gF_ClientRespawned = CreateGlobalForward("ZR_OnClientRespawned", ET_Ignore, Param_Cell);
	
	RegPluginLibrary("zepremium");
	
	return APLRes_Success;
}

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			i_Maximum_Choose[i] = 0;
			g_bSamegun[i] = false;
			Format(Primary_Gun[i], sizeof(Primary_Gun), "1");
			Format(Secondary_Gun[i], sizeof(Secondary_Gun), "1");
		}
	}
	
	//AUTOMATIC DOWNLOAD
	DownloadFiles();
	
	//MODELS
	g_cZEHumanModel.GetString(HUMANMODEL, sizeof(HUMANMODEL));
	g_cZEZombieModel.GetString(ZOMBIEMODEL, sizeof(ZOMBIEMODEL));
	g_cZENemesisModel.GetString(NEMESISMODEL, sizeof(NEMESISMODEL));
	g_cZEDefendModelVmt.GetString(DEFEND, sizeof(DEFEND));
	g_cZEDefendModelVtf.GetString(DEFENDVTF, sizeof(DEFENDVTF));
	g_cZEFollowmeModelVmt.GetString(FOLLOWME, sizeof(FOLLOWME));
	g_cZEFollowmeModelVtf.GetString(FOLLOWMEVTF, sizeof(FOLLOWMEVTF));
	g_cZEZMwinmodelVmt.GetString(ZMWINS, sizeof(ZMWINS));
	g_cZEZMwinmodelVtf.GetString(ZMWINSVTF, sizeof(ZMWINSVTF));
	g_cZEHUMANwinmodelVmt.GetString(HUMANWINS, sizeof(HUMANWINS));
	g_cZEHUMANwinmodelVtf.GetString(HUMANWINSVTF, sizeof(HUMANWINSVTF));
	
	PrecacheModel(HUMANMODEL);
	PrecacheModel(NEMESISMODEL);
	PrecacheModel(ZOMBIEMODEL);
	
	//DECALS
	AddFileToDownloadsTable(DEFENDVTF);
	AddFileToDownloadsTable(DEFEND);
	AddFileToDownloadsTable(FOLLOWMEVTF);
	AddFileToDownloadsTable(FOLLOWME);
	AddFileToDownloadsTable(ZMWINSVTF);
	AddFileToDownloadsTable(ZMWINS);
	AddFileToDownloadsTable(HUMANWINSVTF);
	AddFileToDownloadsTable(HUMANWINS);
	
	PrecacheDecal(ZMWINS, true);
	PrecacheDecal(ZMWINSVTF, true);
	PrecacheDecal(HUMANWINS, true);
	PrecacheDecal(HUMANWINSVTF, true);
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
	AddFileToDownloadsTable("sound/ze_premium/ze-nemesispain.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-nemesispain2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-nemesispain3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-riotround.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-humanpain.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-humanpain2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-humanpain3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-humanpain4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-infected1.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-infected2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-infected3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-infected4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-infected5.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-infectionnade.mp3");
	
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
	
	//OTHER GAME SOUNDS
	AddFileToDownloadsTable("sound/ze_premium/ze-stab.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-wallhit.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-slash2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-slash1.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-slash3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-slash4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-slash5.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-slash6.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-zombiehit1.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-zombiehit2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-zombiehit3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-zombiehit4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-reloading1.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-reloading2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-reloading3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-reloading4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-humanwin1.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-humanwin2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-zombiewin.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-firstzm1.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-firstzm2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-firstzm3.mp3");
	
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
	PrecacheSound("ze_premium/ze-nemesispain.mp3");
	PrecacheSound("ze_premium/ze-nemesispain2.mp3");
	PrecacheSound("ze_premium/ze-nemesispain3.mp3");
	PrecacheSound("ze_premium/ze-riotround.mp3");
	PrecacheSound("ze_premium/ze-humanpain.mp3");
	PrecacheSound("ze_premium/ze-humanpain2.mp3");
	PrecacheSound("ze_premium/ze-humanpain3.mp3");
	PrecacheSound("ze_premium/ze-humanpain4.mp3");
	
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
	
	//OTHERS SOUND
	PrecacheSound("ze_premium/ze-stab.mp3");
	PrecacheSound("ze_premium/ze-wallhit.mp3");
	PrecacheSound("ze_premium/ze-slash2.mp3");
	PrecacheSound("ze_premium/ze-slash1.mp3");
	PrecacheSound("ze_premium/ze-slash3.mp3");
	PrecacheSound("ze_premium/ze-slash4.mp3");
	PrecacheSound("ze_premium/ze-slash5.mp3");
	PrecacheSound("ze_premium/ze-slash6.mp3");
	PrecacheSound("ze_premium/ze-zombiehit1.mp3");
	PrecacheSound("ze_premium/ze-zombiehit2.mp3");
	PrecacheSound("ze_premium/ze-zombiehit3.mp3");
	PrecacheSound("ze_premium/ze-zombiehit4.mp3");
	PrecacheSound("ze_premium/ze-reloading1.mp3");
	PrecacheSound("ze_premium/ze-reloading2.mp3");
	PrecacheSound("ze_premium/ze-reloading3.mp3");
	PrecacheSound("ze_premium/ze-reloading4.mp3");
	PrecacheSound("ze_premium/ze-humanwin1.mp3");
	PrecacheSound("ze_premium/ze-humanwin2.mp3");
	PrecacheSound("ze_premium/ze-zombiewin.mp3");
	PrecacheSound("ze_premium/ze-firstzm1.mp3");
	PrecacheSound("ze_premium/ze-firstzm2.mp3");
	PrecacheSound("ze_premium/ze-firstzm3.mp3");
	PrecacheSound("ze_premium/ze-infected1.mp3");
	PrecacheSound("ze_premium/ze-infected2.mp3");
	PrecacheSound("ze_premium/ze-infected3.mp3");
	PrecacheSound("ze_premium/ze-infected4.mp3");
	PrecacheSound("ze_premium/ze-infected5.mp3");
	PrecacheSound("ze_premium/ze-infectionnade.mp3");
	
	//BEACON
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow06.vmt");
	
	g_bRoundStarted = false;
	g_bPause = false;
	g_bWaitingForPlayer = false;
	i_waitingforplayers = 0;
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
				SetPlayerAsHuman(i);
				
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
	int soucet = GetTeamClientCount(2) + GetTeamClientCount(3);
	g_bRoundStarted = false;
	g_bMarker = false;
	g_bPause = false;
	i_Riotround = 0;
	i_SpecialRound = 0;
	i_binfnade = 0;
	i_waitingforplayers = 0;
	int winner_team = GetEventInt(event, "winner");
	/*
	if(winner_team == 2)
	{
		ShowOverlayAll(ZMWINSVTF, 4.0);
	}
	else if(winner_team == 3)
	{
		ShowOverlayAll(HUMANWINSVTF, 4.0);
	}*/
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if(g_bWasFirstInfected[i] == true)
			{
				g_bWasFirstInfected[i] = false;
			}
			
			if(g_bFirstInfected[i] == true)
			{
				g_bFirstInfected[i] = false;
				g_bWasFirstInfected[i] = true;
			}
			
			if(winner_team == 3)
			{ 
				if(g_bInfected[i] == false)
				{
					i_wins[i]++;
				}
			}

			if(i_infectionban[i] > 0 && soucet >= g_cZEInfectionBanPlayers.IntValue)
			{
				char szSteamId[32], szQuery[512];
				GetClientAuthId(i, AuthId_Engine, szSteamId, sizeof(szSteamId));
				int newiban = i_infectionban[i] - 1;
				g_hDatabase.Format(szQuery, sizeof(szQuery), "UPDATE ze_premium_sql SET infectionban = '%i' WHERE steamid='%s'", newiban, szSteamId);
				g_hDatabase.Query(SQL_Error, szQuery);
			}
			CheckTeam(i);
			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
			g_bInfected[i] = false;
			i_typeofsprite[i] = 0;
			g_bBeacon[i] = false;
			g_bIsLeader[i] = false;
			g_hCooldown[i] = false;
			spended[i] = 0;
			i_respawn[i] = 0;
			if (H_Beacon[i] != null)
			{
				KillTimer(H_Beacon[i]);
				H_Beacon[i] = null;	
			}
			if(H_Respawntimer[i] != null)
			{
				KillTimer(H_Respawntimer[i]);
				H_Respawntimer[i] = null;	
			}
			g_bFireHE[i] = false;
			g_bOnFire[i] = false;
			g_bFreezeFlash[i] = false;
			g_bNoRespawn[i] = false;
		}
	}
}

public Action CMD_Weapon(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_bInfected[client] == false)
		{
			openWeapons(client);
		}
		else
		{
			CReplyToCommand(client, " \x04[Zombie-Escape]\x01 %t", "no_human");
		}
	}
	return Plugin_Handled;
}

public Action CMD_Admin(int client, int args)
{
	if (IsValidClient(client) && IsClientAdmin(client))
	{
		openAdmin(client);
	}
	return Plugin_Handled;
}

public Action CMD_Class(int client, int args)
{
	if (IsValidClient(client))
	{
		openClasses(client);
	}
	return Plugin_Handled;
}

public Action CMD_Shop(int client, int args)
{
	if (IsValidClient(client))
	{
		openShop(client);
	}
	return Plugin_Handled;
}

public Action CMD_MainMenu(int client, int args)
{
	if (IsValidClient(client))
	{
		openMenu(client);
	}
	return Plugin_Handled;
}

public Action CMD_Respawn(int client, int args)
{
	if (IsValidClient(client))
	{
		if (i_Infection > 0 && g_bInfected[client] == false)
		{
			CS_RespawnPlayer(client);
			CPrintToChat(client, " \x04[ZE-Respawn]\x01 %t", "player_respawned");
		}
		else
		{
			if(g_bInfected[client] == true && i_Infection == 0)
			{
				if(i_respawn[client] < 3)
				{
					CS_RespawnPlayer(client);
					i_respawn[client]++;
					int uses = 3 - i_respawn[client];
					CPrintToChat(client, " \x04[ZE-Respawn]\x01 %t", "zombie_respawned", uses);
				}
			}
		}
	}
	return Plugin_Handled;
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
			CReplyToCommand(client, " \x04[ZE-Leader]\x01 %t", "no_leader");
		}
	}
	return Plugin_Handled;
}

public Action CMD_P90(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_bInfected[client] == false)
		{
			if (i_Maximum_Choose[client] < g_cZEMaximumUsage.IntValue)
			{
				int primweapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
				if (IsValidEdict(primweapon) && primweapon != -1)
				{
					RemoveEdict(primweapon);
				}
				Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_p90");
				CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
				GivePlayerItem(client, Primary_Gun[client]);
				i_Maximum_Choose[client]++;
				int usages = g_cZEMaximumUsage.IntValue - i_Maximum_Choose[client];
				CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "gun_uses_left", usages);
			}
		}
	}
	return Plugin_Handled;
}

public Action CMD_Bizon(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_bInfected[client] == false)
		{
			if (i_Maximum_Choose[client] < g_cZEMaximumUsage.IntValue)
			{
				int primweapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
				if (IsValidEdict(primweapon) && primweapon != -1)
				{
					RemoveEdict(primweapon);
				}
				Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_bizon");
				CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
				GivePlayerItem(client, Primary_Gun[client]);
				i_Maximum_Choose[client]++;
				int usages = g_cZEMaximumUsage.IntValue - i_Maximum_Choose[client];
				CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "gun_uses_left", usages);
			}
		}
	}
	return Plugin_Handled;
}

public Action CMD_Negev(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_bInfected[client] == false)
		{
			if (i_Maximum_Choose[client] < g_cZEMaximumUsage.IntValue)
			{
				int primweapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
				if (IsValidEdict(primweapon) && primweapon != -1)
				{
					RemoveEdict(primweapon);
				}
				Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_negev");
				CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
				GivePlayerItem(client, Primary_Gun[client]);
				i_Maximum_Choose[client]++;
				int usages = g_cZEMaximumUsage.IntValue - i_Maximum_Choose[client];
				CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "gun_uses_left", usages);
			}
		}
	}
	return Plugin_Handled;
}

public Action CMD_GetGun(int client, int args)
{
	if (IsValidClient(client) && g_bInfected[client] == false)
	{
		if (Primary_Gun[client][0] == 'w' || Secondary_Gun[client][0] == 'w')
		{
			if (i_Maximum_Choose[client] < g_cZEMaximumUsage.IntValue)
			{
				i_Maximum_Choose[client]++;
				int usages = g_cZEMaximumUsage.IntValue - i_Maximum_Choose[client];
				CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "gun_uses_left", usages);
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
				CReplyToCommand(client, " \x04[ZE-Weapons]\x01 %t", "maxium_usages_gunmenu");
			}
		}
		else
		{
			CReplyToCommand(client, " \x04[ZE-Weapons]\x01 %t", "choose_gun_first");
		}
	}
	else
	{
		CReplyToCommand(client, " \x04[ZE-Weapons]\x01 %t", "no_human");
	}
	return Plugin_Handled;
}

public Action CMD_Topplayer(int client, int args)
{
	if (IsValidClient(client))
	{
		char szQueryList[512];
		
		g_hDataPackUser = CreateDataPack();
		WritePackCell(g_hDataPackUser, client);
	
		g_hDatabase.Format(szQueryList, sizeof(szQueryList), "SELECT * FROM ze_premium_sql ORDER BY humanwins DESC LIMIT 10");
		g_hDatabase.Query(SQL_QueryToplist, szQueryList);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action CMD_Statistic(int client, int args)
{
	if (IsValidClient(client))
	{
		char szSteamId[32], szQuery[512];
		GetClientAuthId(client, AuthId_Engine, szSteamId, sizeof(szSteamId));
		
		g_hDatabase.Format(szQuery, sizeof(szQuery), "SELECT * FROM ze_premium_sql WHERE steamid='%s'", szSteamId);
		
		g_hDatabase.Query(szQueryCallback, szQuery, GetClientUserId(client));
	}
	return Plugin_Handled;
}

