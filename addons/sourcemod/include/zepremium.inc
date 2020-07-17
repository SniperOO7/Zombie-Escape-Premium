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
 * Called after a player is infected by other player
 * 
 * @param client			The client that was infected.
 * @param attacker		  The the infecter. (-1 if there is no infecter)
 */
forward void ZR_OnClientInfected(int client, int attacker);
