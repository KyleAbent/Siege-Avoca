function Armory:GetShouldResupplyPlayer(player)
    if not player:GetIsAlive() then
        return false
    end
    
    
    local isVortexed = self:GetIsVortexed() or ( HasMixin(player, "VortexAble") and player:GetIsVortexed() )
    if isVortexed then
        return false
    end    
   
    
    local inNeed = false
    
    // Don't resupply when already full
    if (player:GetHealth() < player:GetMaxHealth()) or (player:GetArmor() < player:GetMaxArmor() ) then
        inNeed = true
    else

        // Do any weapons need ammo?
        for i, child in ientitychildren(player, "ClipWeapon") do
        
            if child:GetNeedsAmmo(false) then
                inNeed = true
                break
            end
            
        end
        
    end
    
    if inNeed then
    
        // Check player facing so players can't fight while getting benefits of armory
        local viewVec = player:GetViewAngles():GetCoords().zAxis
        local toArmoryVec = self:GetOrigin() - player:GetOrigin()
        
        if(GetNormalizedVector(viewVec):DotProduct(GetNormalizedVector(toArmoryVec)) > .75) then
        
            if self:GetTimeToResupplyPlayer(player) then
        
                return true
                
            end
            
        end
        
    end
    
    return false
    
end

function Armory:ResupplyPlayer(player)
    
    local resuppliedPlayer = false
    // Heal player first
    if (player:GetHealth() < player:GetMaxHealth()) or ( player:GetArmor() < player:GetMaxArmor() ) then
        // third param true = ignore armor
       // player:AddHealth(Armory.kHealAmount, false, not self.healarmor, nil, nil, true)
                   //Heal Health First, Then Armor, 3 armor per level of armor
                   //then add level bonus
           if ( player:GetHealth() == player:GetMaxHealth() ) then
           local addarmoramount = kArmoryAvoArcAddArmrAmt * player:GetArmorLevel()
           
           player:AddHealth(addarmoramount, false, not true, nil, nil, true)
           else
           player:AddHealth(Armory.kHealAmount * 2, false, false, nil, nil, true)   
           end
           
        self:TriggerEffects("armory_health", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
        resuppliedPlayer = true
        /*
        if HasMixin(player, "ParasiteAble") and player:GetIsParasited() then
        
            player:RemoveParasite()
            
        end
        */
        
        if player:isa("Marine") and player.poisoned then
        
            player.poisoned = false
            
        end
        
    end
    // Give ammo to all their weapons, one clip at a time, starting from primary
    local weapons = player:GetHUDOrderedWeaponList()
    
    for index, weapon in ipairs(weapons) do
    
        if weapon:isa("ClipWeapon") then
        
            if weapon:GiveAmmo(1, false) then
            
                self:TriggerEffects("armory_ammo", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
                
                resuppliedPlayer = true
                
                
                break
                
            end 
                   
        end
        
    end
        
    if resuppliedPlayer then
    
        // Insert/update entry in table
        self.resuppliedPlayers[player:GetId()] = Shared.GetTime()
        
        // Play effect
        //self:PlayArmoryScan(player:GetId())
    end
end
Script.Load("lua/Additions/AvocaMixin.lua")
class 'ArmoryAvoca' (Armory)
ArmoryAvoca.kMapName = "armoryavoca"

local networkVars = {}

AddMixinNetworkVars(AvocaMixin, networkVars)
    

    function ArmoryAvoca:OnCreate()
         Armory.OnCreate(self)
        InitMixin(self, AvocaMixin)
    end
        function ArmoryAvoca:GetTechId()
         return kTechId.Armory
    end

function ArmoryAvoca:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.Armory
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
function ArmoryAvoca:OnCreate()
Armory.OnCreate(self)
self:SetTechId(kTechId.Armory)
end
function ArmoryAvoca:SetIsACreditStructure(boolean)
    
self.isacreditstructure = boolean
      Print("%s isacreditstructure is %s", self:GetClassName(), self.isacreditstructure)
end
Shared.LinkClassToMap("ArmoryAvoca", ArmoryAvoca.kMapName, networkVars)