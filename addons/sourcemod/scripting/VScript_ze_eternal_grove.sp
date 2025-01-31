#pragma semicolon 1
#pragma newdecls required

#define MAP_NAME "ze_eternal_grove_v3_css"
#define NADE_DAMAGE 300
#define NADE_DAMGE_CRIT 800
#define CLAMP_UP 500.0
#define CLAMP_SIDE 350.0

#include <sourcemod>
#include <sdktools>
#include <vscripts>
#include <multicolors>

bool bValidMap = false;
int g_iNadeBonusDamage = 0;
int g_iWindsPushes[] = {
	54298, 54619, 54512, 216147, 215572, 222212, 220705, 220609, 220045, 218972, 53965, 59316, 58555, 58448, 58341, 58127, 55822, 55608, 54833, 62828, 62721, 62614, 62507
};

public Plugin myinfo =
{
	name = "VScript - Eternal grove",
	author = ".Rushaway",
	description = "Clamp player velocity and display boss game_text",
	version = "1.0",
	url = "https://github.com/srcdslab/sm-plugin-VScript_ze_eternal_grove"
};

public void OnMapStart()
{
	char sCurMap[256];
	GetCurrentMap(sCurMap, sizeof(sCurMap));
	bValidMap = (strcmp(sCurMap, MAP_NAME, false) == 0);
	if (bValidMap)
	{
		HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	}
	else
	{
		char sFilename[256];
		GetPluginFilename(INVALID_HANDLE, sFilename, sizeof(sFilename));
		ServerCommand("sm plugins unload %s", sFilename);
	}
}

public void OnRoundStart(Event hEvent, const char[] sEvent, bool bDontBroadcast)
{
	InitHooks();
	CreateTimer(12.0, Timer_Credits, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_Credits(Handle timer)
{
	CPrintToChatAll("{pink}[VScripts] {white}Original VScripts by Luffaren ported by .Rushaway");
	return Plugin_Stop;
}

public void BossElevator_OnFullyOpen(const char[] output, int caller, int activator, float delay)
{
	CreateTimer(15.5, Timer_HookMinotaurodgod, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
}

public void AdminRoom_OnPressed(const char[] output, int caller, int activator, float delay)
{
	CreateTimer(21.5, Timer_HookMinotaurodgod, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_HookMinotaurodgod(Handle timer)
{
	Hooks_Minotaurgod();
	return Plugin_Continue;
}

stock void InitHooks()
{
	// Boss Eleavtor - boss_elevator
	int iEntity = Vscripts_GetEntityIndexByHammerID(68255, "func_movelinear", INVALID_ENT_REFERENCE);
	if (iEntity != INVALID_ENT_REFERENCE)
		HookSingleEntityOutput(iEntity, "OnFullyOpen", BossElevator_OnFullyOpen, false);

	// Adminroom - admin_buttons_GoToBoss
	iEntity = Vscripts_GetEntityIndexByHammerID(393420, "func_button", INVALID_ENT_REFERENCE);
	if (iEntity != INVALID_ENT_REFERENCE)
		HookSingleEntityOutput(iEntity, "OnPressed", AdminRoom_OnPressed, false);

	for (int i = 0; i < sizeof(g_iWindsPushes); i++)
	{
		iEntity = Vscripts_GetEntityIndexByHammerID(g_iWindsPushes[i], "trigger_push", INVALID_ENT_REFERENCE);

		if (iEntity != INVALID_ENT_REFERENCE)
			HookSingleEntityOutput(iEntity, "OnEndTouch", WindsPushes_OnEndTouch, false);
	}
}

stock void Hooks_Minotaurgod()
{
	// i_minotaurgod_hp
	int iEntity = Vscripts_GetEntityIndexByHammerID(918186, "func_physbox", INVALID_ENT_REFERENCE);
	if (iEntity != INVALID_ENT_REFERENCE)
		HookSingleEntityOutput(iEntity, "OnHealthChanged", Minotaurgod_OnHealthChanged, false);

	// i_minotaurgod_nadehp
	iEntity = Vscripts_GetEntityIndexByHammerID(918241, "func_breakable", INVALID_ENT_REFERENCE);
	if (iEntity != INVALID_ENT_REFERENCE)
	{
		g_iNadeBonusDamage = 0;

		HookSingleEntityOutput(iEntity, "OnUser1", MinotaurgodNadeHP_OnUser1, false);
		HookSingleEntityOutput(iEntity, "OnUser2", MinotaurgodNadeHP_OnUser2, false);
	}
}

stock void Minotaurgod_OnHealthChanged(const char[] output, int caller, int activator, float delay)
{
	if (!IsValidClient(activator))
		return;

	// text_boss_hp
	int iGameText = Vscripts_GetEntityIndexByHammerID(918088, "game_text", INVALID_ENT_REFERENCE);
	if (!IsValidEntity(iGameText))
		return;

	int iHP = GetEntProp(caller, Prop_Data, "m_iHealth");
	char sBuffer[252];
	Format(sBuffer, sizeof(sBuffer), "message MINOTAUR GOD = %d", iHP);
	SetVariantString(sBuffer);
	AcceptEntityInput(iGameText, "AddOutput");
	AcceptEntityInput(iGameText, "Display");
}

stock void MinotaurgodNadeHP_OnUser1(const char[] output, int caller, int activator, float delay)
{
	if (!IsValidClient(activator))
		return;

	g_iNadeBonusDamage = (g_iNadeBonusDamage + NADE_DAMAGE);

	// text_boss_crit
	int iGameText = Vscripts_GetEntityIndexByHammerID(918047, "game_text", INVALID_ENT_REFERENCE);
	if (!IsValidEntity(iGameText))
		return;

	char sBuffer[252];
	Format(sBuffer, sizeof(sBuffer), "message BONUS DAMAGE = %d", g_iNadeBonusDamage);
	SetVariantString(sBuffer);
	AcceptEntityInput(iGameText, "AddOutput");
	AcceptEntityInput(iGameText, "Display");
}

stock void MinotaurgodNadeHP_OnUser2(const char[] output, int caller, int activator, float delay)
{
	if (!IsValidClient(activator))
		return;

	g_iNadeBonusDamage = (g_iNadeBonusDamage + NADE_DAMGE_CRIT);

	// text_boss_crit
	int iGameText = Vscripts_GetEntityIndexByHammerID(918047, "game_text", INVALID_ENT_REFERENCE);
	if (!IsValidEntity(iGameText))
		return;

	char sBuffer[252];
	Format(sBuffer, sizeof(sBuffer), "message BONUS DAMAGE = %d", g_iNadeBonusDamage);
	SetVariantString(sBuffer);
	AcceptEntityInput(iGameText, "AddOutput");
	AcceptEntityInput(iGameText, "Display");
}

stock void WindsPushes_OnEndTouch(const char[] output, int caller, int activator, float delay)
{
	if (!IsValidClient(activator))
		return;

	float fVelocity[3];
	GetVelocity(activator, fVelocity);

	bool setVelocity = false;

	// Laterally clamp the player's velocity
	if (FloatAbs(fVelocity[0] + fVelocity[1]) > CLAMP_SIDE)
	{
		fVelocity[0] *= 0.90; // X axis - Limit sideways velocity
		fVelocity[1] *= 0.90; // Y axis - Limit sideways velocity
		setVelocity = true;
	}

	// Vertically clamp the player's velocity
	if (fVelocity[2] > CLAMP_UP)
	{
		fVelocity[2] = CLAMP_UP; // Z axis - Limit upwards velocity
		setVelocity = true;
	}

	if (setVelocity)
		SetVelocity(activator, fVelocity);
}

stock bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client));
}

stock void GetVelocity(int client, float fVelocity[3])
{
	fVelocity[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	fVelocity[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	fVelocity[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
}

stock void SetVelocity(int client, const float fVelocity[3])
{
	SetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]", fVelocity[0]);
	SetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]", fVelocity[1]);
	SetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]", fVelocity[2]);
}