/*
function PlayingTeam:GetSupplyUsed()
    return Clamp(self.supplyUsed, 0, kMaxSupply)
end

function PlayingTeam:AddSupplyUsed(supplyUsed)
    Print("Current supply is %s, adding %s", self.supplyUsed, supplyUsed)
    self.supplyUsed = self.supplyUsed + supplyUsed
    Print("supply is now %s", self.supplyUsed)
end

function PlayingTeam:RemoveSupplyUsed(supplyUsed)
    Print("Current supply is %s, removing %s", self.supplyUsed, supplyUsed)
    self.supplyUsed = self.supplyUsed - supplyUsed
    Print("supply is now %s", self.supplyUsed)
end
*/