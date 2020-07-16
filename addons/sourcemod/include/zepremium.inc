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
native bool ZEPremium_IsInfection();

/**
 * Check if is player infected or not
 *
 * @param client
 * @return        True if is player infected
 */
native bool ZEPremium_IsInfected(int client);
