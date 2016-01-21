----------------------------------------------------------------------
-- Project: top_damage                                              --
-- Author: x[N]ir                                                   --
-- Date: 18.01.2016                                                 --
-- File: top_damage.lua                                             --
-- Description: displays the MVP + damage of the previous round     --
----------------------------------------------------------------------

-----------------------
--     CONSTANTS     -- 
-----------------------
if top_damage == nil then top_damage = {}; end
top_damage.MESSAGE_COLOR = string.char(169).."255255255";

-----------------------
--     VARIABLES     -- 
-----------------------
top_damage.playerDamages = {};

----------------------------------------------------------------------
-- Resets the player damages                                        --
--                                                                  --
-- @param id player's id                                            --
----------------------------------------------------------------------
function top_damage.resetPlayerDamages(id)
	--[[
		Resets the round and total damage value of a player
	]]--

	top_damage.playerDamages[id] = {};
	top_damage.playerDamages[id]["round"] = 0;
	top_damage.playerDamages[id]["total"] = 0;
end

----------------------------------------------------------------------
-- StartRound hook implementation                                   --
--                                                                  --
-- @param mode id of the mode                                       --
----------------------------------------------------------------------
addhook("startround", "top_damage.onStartRound");
function top_damage.onStartRound(mode)
	--[[
		If the start mode is game commencing or round restart,
		every array of each player is reset. Otherwise, mvp + players
		damages + player total damages are displayed
	]]--

	if(mode == 4 or mode == 5) then
		for _, id in pairs(player(0, "tableliving")) do
			top_damage.resetPlayerDamages(id);
		end
 	else
 		local mvp = player(0, "tableliving")[1];

 		for _, id in pairs(player(0, "tableliving")) do
 			if(top_damage.playerDamages[id]["round"] > 
 				top_damage.playerDamages[mvp]["round"]) then
 				mvp = id;
 			end
 		end

 		msg(top_damage.MESSAGE_COLOR.."[DAMAGE] MVP: "..player(mvp, "name")..
 			" "..top_damage.playerDamages[mvp]["round"].." HP");

 		for _, id in pairs(player(0, "tableliving")) do
 			msg2(id, top_damage.MESSAGE_COLOR.."[DAMAGE] Last Round: "..
 				top_damage.playerDamages[id]["round"].." HP");


 			top_damage.playerDamages[id]["total"] = 
				top_damage.playerDamages[id]["total"] + 
					top_damage.playerDamages[id]["round"];

 			msg2(id, top_damage.MESSAGE_COLOR.."[DAMAGE] Total: "..
 				top_damage.playerDamages[id]["total"].." HP");
 			top_damage.playerDamages[id]["round"] = 0;
 		end
	end
end

----------------------------------------------------------------------
-- Hit hook implementation                                          --
--                                                                  --
-- @param id player id (the victim)                                 --
-- @param source source player id or 0 (the attacker)               --
-- @param weapon weapon type / source type id                       --
-- @param hpdmg caused damage (health)                              --
-- @param apdmg caused damage (armor)                               --
-- @param rawdmg original damage without armor calculations         --
----------------------------------------------------------------------
addhook("hit", "top_damage.onHit");
function top_damage.onHit(id, source, weapon, hpdmg, apdmd, rawdmg)
	--[[
		Updates player stats
	]]--
	top_damage.playerDamages[source]["round"] = 
		top_damage.playerDamages[source]["round"] + hpdmg;
end

----------------------------------------------------------------------
-- Spawn hook implementation                                        --
--                                                                  --
-- @param id player id                                              --
----------------------------------------------------------------------
addhook("spawn", "top_damage.onSpawn");
function top_damage.onSpawn(id)
	--[[
		Creates the array for the player if necessary
	]]--

	if(not top_damage.playerDamages[id]) then
		top_damage.resetPlayerDamages(id);
	end

	return "";
end

----------------------------------------------------------------------
-- Leave hook implementation                                        --
--                                                                  --
-- @param id player id                                              --
----------------------------------------------------------------------
addhook("leave", "top_damage.onLeave");
function top_damage.onLeave(id)
	--[[
		Free some memory
	]]--

	top_damage.playerDamages[id] = nil;
end