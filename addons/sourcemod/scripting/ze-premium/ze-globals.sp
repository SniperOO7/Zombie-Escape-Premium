#define FREEZE_SOUND "ze_premium/freeze.mp3"

//GRENADES
#define FragColor 	{255,75,75,255}
#define FlashColor	{0,255,255,255}
#define SmokeColor	{0,255,0,255}
#define SMOKE 1
char g_iaGrenadeOffsets[] = {15, 17, 16, 14, 18, 17};

//FORWARDS
Handle gF_ClientInfected;
Handle gF_ClientRespawned;
Handle gF_ClientHumanPost;

//TIMERS
Handle H_FirstInfection;

int g_iBeamSprite;
int g_iHaloSprite;

ConVar g_cZEFirstInfection;
ConVar g_cZEZombieHP;
ConVar g_cZEZombieSpeed;
ConVar g_cZEHumanHP;
ConVar g_cZEHealthShot;
ConVar g_cZEHeNade;
ConVar g_cZEFlashNade;
ConVar g_cZEMolotov;
ConVar g_cZEMaximumUsage;
ConVar g_cZEMotherZombieHP;
ConVar g_cZEZombieModel;
ConVar g_cZEHumanModel;
ConVar g_cZEDefendModelVmt;
ConVar g_cZEDefendModelVtf;
ConVar g_cZEFollowmeModelVmt;
ConVar g_cZEFollowmeModelVtf;
ConVar g_cZENemesis;
ConVar g_cZENemesisModel;
ConVar g_cZENemesisHP;
ConVar g_cZENemesisSpeed;
ConVar g_cZENemesisGravity;
ConVar g_cZEZombieRiots;
ConVar g_cZEZombieShieldType;
ConVar g_cZEHeGrenadeEffect;
ConVar g_cZEFlashbangEffect;
ConVar g_cZESmokeEffect;
ConVar g_cZEInfnade;
ConVar g_cZEInfnadeusages;
ConVar g_cZEInfnadedistance;
ConVar g_cZEFreezenadedistance;
ConVar g_cZEInfectionBans;
ConVar g_cZEInfectionTime;
ConVar g_cZEInfectionBanPlayers;
ConVar g_cZEHUDInfo;
ConVar g_cZEZombieSounds;
ConVar g_cZEZMwinmodelVmt;
ConVar g_cZEZMwinmodelVtf;
ConVar g_cZEHUMANwinmodelVmt;
ConVar g_cZEHUMANwinmodelVtf;

char g_sZEConfig[PLATFORM_MAX_PATH];
char g_sZEConfig2[PLATFORM_MAX_PATH];

KeyValues kvZombies, kvHumans;

Database g_hDatabase;

Handle g_hDataPackUser;

//MODELS
char HUMANMODEL[128];
char ZOMBIEMODEL[128];
char NEMESISMODEL[128];
char DEFEND[128], DEFENDVTF[128];
char FOLLOWME[128], FOLLOWMEVTF[128];
char ZMWINS[128], HUMANWINS[128];
char ZMWINSVTF[128], HUMANWINSVTF[128];

//GUNS
char Primary_Gun[MAXPLAYERS + 1][64];
char Secondary_Gun[MAXPLAYERS + 1][64];
int i_Maximum_Choose[MAXPLAYERS + 1];
bool g_bSamegun[MAXPLAYERS + 1] = false;

//LEADER
int i_spriteEntities[MAXPLAYERS + 1];
int i_markerEntities[MAXPLAYERS + 1];
int i_typeofsprite[MAXPLAYERS + 1];
bool g_bMarker = false;
bool g_bIsLeader[MAXPLAYERS + 1] = false;
bool g_bBeacon[MAXPLAYERS + 1] = false;
Handle H_Beacon[MAXPLAYERS + 1];

//ZOMBIES
bool g_bInfected[MAXPLAYERS + 1] = false;
bool g_bIsNemesis[MAXPLAYERS + 1] = false;
int i_pause[MAXPLAYERS + 1];
bool g_bNotDied[MAXPLAYERS + 1];
bool g_bFirstInfected[MAXPLAYERS + 1] = false;
bool g_bWasFirstInfected[MAXPLAYERS + 1];
bool g_bNoRespawn[MAXPLAYERS + 1] = false;
bool g_bAntiDisconnect[MAXPLAYERS + 1] = false;
int i_Riotround;
int i_SpecialRound;

//CLASSES
int i_zclass[MAXPLAYERS + 1];
int i_hclass[MAXPLAYERS + 1];
int i_protection[MAXPLAYERS + 1];
char Selected_Class_Human[MAXPLAYERS + 1][100];
char Selected_Class_Zombie[MAXPLAYERS + 1][100];
Handle H_Respawntimer[MAXPLAYERS + 1];

//GAME
int i_Infection;
bool g_bRoundStarted = false;
bool g_bPause = false;
int i_respawn[MAXPLAYERS + 1];
int i_infectionban[MAXPLAYERS + 1];
bool g_hCooldown[MAXPLAYERS + 1];

int g_iSoundEnts[2048];
int g_iNumSounds;

//SHOP
bool g_bFireHE[MAXPLAYERS + 1] = false;
bool g_bOnFire[MAXPLAYERS + 1] = false;
bool g_bFreezeFlash[MAXPLAYERS + 1] = false;
bool g_bInfectNade[MAXPLAYERS + 1] = false;
int spended[MAXPLAYERS + 1];
int i_binfnade;

//DATABASE
int i_wins[MAXPLAYERS + 1];
int i_infected[MAXPLAYERS + 1];
int i_killedzm[MAXPLAYERS + 1];
int i_hwins[MAXPLAYERS + 1];
int i_infectedh[MAXPLAYERS + 1];