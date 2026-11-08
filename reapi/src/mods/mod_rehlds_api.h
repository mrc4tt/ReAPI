#pragma once

extern IRehldsApi* g_RehldsApi;
extern const RehldsFuncs_t* g_RehldsFuncs;
extern IRehldsServerData* g_RehldsData;
extern IRehldsHookchains* g_RehldsHookchains;
extern IRehldsServerStatic* g_RehldsSvs;
extern IMessageManager* g_RehldsMessageManager;
extern IRehldsForkApi* g_RehldsForkApi; // NULL unless the engine is the mrc4tt/ReHLDS fork

extern bool RehldsApi_Init();