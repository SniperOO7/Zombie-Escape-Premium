#if defined _zepremium_included_
  #endinput
#endif
#define _zepremium_included_

/**
 * Check if is infection started or not
 *
 * @param client
 * @return        True if infection not yet started 
 */
native bool ZR_IsInfection();

/**
 * Check if is special round (Nemesis or Zombie riot round)
 *
 * @param client
 * @return        True if is special round
 */
native bool ZR_IsSpecialround();

/**
 * Check if is player infected or not
 *
 * @param client
 * @return        True if is player infected
 */
native bool ZR_IsClientZombie(int client);

/**
 * Check if is player human
 *
 * @param client
 * @return        True if is player human
 */
native bool ZR_IsClientHuman(int client);

/**
 * Check if is player nemesis or not
 *
 * @param client
 * @return        True if is player nemesis
 */
native bool ZR_IsNemesis(int client);

/**
 * Check player ultimate power
 *
 * @param client
 * @return        Type of player ultimate
 */
native int ZR_Power(int client);

/**
 * Called after a player is infected by other player
 * 
 * @param client			The client that was infected.
 * @param attacker		  The the infecter. (-1 if there is no infecter)
 */
forward void ZR_OnClientInfected(int client, int attacker);

/**
 * Called after a player has become a human. (Through an admin command.)
 * 
 * @param client			The client index.
 */
forward void ZR_OnClientHumanPost(int client);

/**
 * Called after player is respawned.
 * 
 * @param client			The client index.
 *	
 */
forward void ZR_OnClientRespawned(int client);

/**
 * Set if client will be next time respawned or not
 *
 * @param client		The client index.
 * @param respawnaction		1 = disable respawn on whole round, 0 = enable respawn on whole round
 * @NoReturn
 */
native void ZR_RespawnAction(int client, int respawnaction);
