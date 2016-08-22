local Shine = Shine

local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end

Shine.VoteMenu:AddPage ("SpendStructures", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
   -- self:AddSideButton( "Mac(5)", function() Shared.ConsoleCommand ("sh_buy Mac")  end)
    self:AddSideButton( "Observatory(10)", function() Shared.ConsoleCommand ("sh_buy Observatory")  end)
    self:AddSideButton( "Sentry(8)", function() Shared.ConsoleCommand ("sh_buy SentryAvoca")  end)
    self:AddSideButton( "Armory(12)", function() Shared.ConsoleCommand ("sh_buy Armory")  end)
    self:AddSideButton( "PhaseGate(15)", function() Shared.ConsoleCommand ("sh_buy PhaseGate")  end)
    self:AddSideButton( "InfantryPortal(20)", function() Shared.ConsoleCommand ("sh_buy InfantryPortal")  end)
    self:AddSideButton( "RoboticsFactory(10)", function() Shared.ConsoleCommand ("sh_buy RoboticsFactory")  end)
   // self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
    elseif player:GetTeamNumber() == 2 then
    self:AddSideButton( "Hydra(1)", function() Shared.ConsoleCommand ("sh_buy Hydra")  end)
    --self:AddSideButton( "Drifter(5)", function() Shared.ConsoleCommand ("sh_buy Drifter")  end)
    self:AddSideButton( "Shade(10)", function() Shared.ConsoleCommand ("sh_buy Shade")  end)
    self:AddSideButton( "Crag(10)", function() Shared.ConsoleCommand ("sh_buy Crag")  end)
    self:AddSideButton( "Whip(10)", function() Shared.ConsoleCommand ("sh_buy Whip")  end)
    self:AddSideButton( "Shift(10)", function() Shared.ConsoleCommand ("sh_buy Shift")  end)
    //self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
   end

        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)

Shine.VoteMenu:AddPage ("SpendWeapons", function( self )
        self:AddSideButton( "Welder(1)", function() Shared.ConsoleCommand ("sh_buy Welder")  end)
        self:AddSideButton( "Mines(1.5)", function() Shared.ConsoleCommand ("sh_buy Mines")  end)
        self:AddSideButton( "HeavyMachineGun(5)", function() Shared.ConsoleCommand ("sh_buy HeavyMachineGun")  end)
        self:AddSideButton( "ShotGun(2)", function() Shared.ConsoleCommand ("sh_buy ShotGun")  end)
        self:AddSideButton( "FlameThrower(3)", function() Shared.ConsoleCommand ("sh_buy FlameThrower")  end)
        self:AddSideButton( "GrenadeLauncher(3)", function() Shared.ConsoleCommand ("sh_buy GrenadeLauncher")  end)
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)

Shine.VoteMenu:AddPage ("SpendCommAbilities", function( self )
       local player = Client.GetLocalPlayer()
       self:AddSideButton ("NutrientMist(4)", function()Shared.ConsoleCommand ("sh_buy NutrientMist")end)
       self:AddSideButton( "EnzymeCloud(1.5)", function() Shared.ConsoleCommand ("sh_buy EnzymeCloud")  end)
       self:AddSideButton( "Ink(4)", function() Shared.ConsoleCommand ("sh_buy Ink")  end)
       self:AddSideButton( "Hallucination(1.75)", function() Shared.ConsoleCommand ("sh_buy Hallucination")  end)
       self:AddSideButton( "Contamination(2)", function() Shared.ConsoleCommand ("sh_buy Contamination")  end)
     self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)


Shine.VoteMenu:AddPage ("SpendCredits", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 


elseif player:GetTeamNumber() == 2 then
     self:AddSideButton( "CommAbilities", function() self:SetPage( "SpendCommAbilities" ) end)
end    


     self:AddSideButton( "Structures", function() self:SetPage( "SpendStructures" ) end)
     self:AddBottomButton( "Back", function()self:SetPage("Main")end)
end)

Shine.VoteMenu:EditPage( "Main", function( self ) 
self:AddSideButton( "Credits", function() self:SetPage( "SpendCredits" ) end)
end)


