function Fade:GetCanMetabolizeHealth()
    return GetHasTech(self, kTechId.MetabolizeHealth)
end
if Server then
function Fade:GetTierOneTechId()
    return kTechId.MetabolizeEnergy
end

function Fade:GetTierTwoTechId()
    return kTechId.MetabolizeHealth
end

function Fade:GetTierThreeTechId()
    return kTechId.Stab
end

function Fade:GetTierFourTechId()
    return  kTechId.FadeWall
end

end
