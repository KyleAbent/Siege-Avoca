--Kyle 'Avoca' Abent -- though basically just a shell --- oblitrators idea i just wrote out ;)
Script.Load("lua/Shell.lua")
class 'EggBeacon' (Shell)

EggBeacon.kMapName = "eggbeacon"


local kLifeSpan = 12

local networkVars = { }

local function TimeUp(self)

    self:Kill()
    return false

end
function Shell:GetMinRangeAC()
return  9999   
end
function EggBeacon:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Shell
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
if Server then
    function EggBeacon:OnKill(attacker, doer, point, direction)

        ScriptActor.OnKill(self, attacker, doer, point, direction)
        self:TriggerEffects("death")
        DestroyEntity(self)
    end
    
    function EggBeacon:OnDestroy()
        ScriptActor.OnDestroy(self)
    end
    local function TeleportNonCombatBots(self)
        for index, bot in ipairs(GetEntitiesForTeam("Player", 2)) do
                local client = bot:GetClient()
                if client and client:GetIsVirtual() then
                if bot:GetIsAlive() and (bot.GetIsInCombat and not bot:GetIsInCombat()) then bot:SetOrigin(FindFreeSpace(self:GetOrigin())) end
               end
        end
    end
function EggBeacon:OnConstructionComplete()
              local commander = self:GetTeam():GetCommander()
       if commander ~= nil then
       commander:AddScore(5) 
       end
        self:AddTimedCallback(TimeUp, kLifeSpan)  
        self:AddTimedCallback(EggBeacon.GenerateRandomNumberofEggsNearbyDerpHead, 1)
        
        TeleportNonCombatBots(self)
  end
function EggBeacon:GenerateRandomNumberofEggsNearbyDerpHead()
    local spawnpoint = FindFreeSpace(self:GetOrigin(), .5, 7)
   -- Print("GenerateRandomNumberofEggsNearbyDerpHead")
    if spawnpoint then
     local egg = CreateEntity(Egg.kMapName, spawnpoint, 2)
            egg:AddTimedCallback(function()  DestroyEntity(egg) end, 30)
            egg:SetHive(self)
    end
   
    return true
end

end //ofserver


function EggBeacon:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function EggBeacon:OverrideHintString(hintString)

    if self:GetIsUpgrading() then
        return "COMM_SEL_UPGRADING"
    end
    
    return hintString
    
end
Shared.LinkClassToMap("EggBeacon", EggBeacon.kMapName, networkVars)