local orig_Alien_OnCreate = Alien.OnCreate
function Alien:OnCreate()
    orig_Alien_OnCreate(self)
    if Server then
        self:AddTimedCallback(function() UpdateAvocaAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId(), self:GetTierFourTechId()) end, .8) 
    end
    
     if Client then
       GetGUIManager():CreateGUIScriptSingle("GUIInsight_TopBar")  
    end
    
end

local orig_Alien_OnUpdateAnimationInput = Alien.OnUpdateAnimationInput 

function Alien:OnUpdateAnimationInput(modelMixin)
  orig_Alien_OnUpdateAnimationInput(self, modelMixin)
   
    local attackSpeed = self:GetIsEnzymed() and kEnzymeAttackSpeed or 1
    attackSpeed = attackSpeed * ( self.electrified and kElectrifiedAttackSpeed or 1 )
    attackSpeed = attackSpeed + ( self:GetHasPrimalScream() and kPrimalScreamROFIncrease or 0)
    if self.ModifyAttackSpeed then
    
        local attackSpeedTable = { attackSpeed = attackSpeed }
        self:ModifyAttackSpeed(attackSpeedTable)
        attackSpeed = attackSpeed * attackSpeedTable.attackSpeed
        
    end
    modelMixin:SetAnimationInput("attack_speed", attackSpeed)
end
function Alien:GetHasPrimalScream()
    return self.oneHive
end

if Server then


function Alien:LoopCheck()
self.oneHive = false
--Print("self.oneHive = %s", self.oneHive)
return false
end

function Alien:GetTierFourTechId()
return kTechId.None
end


function Alien:GetTierOneMapName()
return LookupTechData(self:GetTierOneTechId(), kTechDataMapName)
end
function Alien:GetTierTwoMapName()
return LookupTechData(self:GetTierTwoTechId(), kTechDataMapName)
end
function Alien:GetTierThreeMapName()
return LookupTechData(self:GetTierThreeTechId(), kTechDataMapName)
end
function Alien:GetTierFourMapName()
return LookupTechData(self:GetTierFourTechId(), kTechDataMapName)
end

    function Alien:PrimalScream(duration)

    end
    
function Alien:HiveCompleteSoRefreshTechsManually()
UpdateAvocaAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId(), self:GetTierFourTechId() )
end


function Alien:CreditBuy(Class)

        local upgradetable = {}
        local upgrades = Player.lastUpgradeList
        if upgrades and #upgrades > 0 then
            table.insert(upgradetable, upgrades)
        end
        local class = nil
        
        if Class == Gorge then
        class = kTechId.Gorge
        elseif Class == Lerk then
        class = kTechId.Lerk
        elseif Class == Fade then
        class = kTechId.Fade
        elseif Class == Onos then
        class = kTechId.Onos
        end
        
        table.insert(upgradetable, class)
        self:ProcessBuyAction(upgradetable, true)
        
end


end


