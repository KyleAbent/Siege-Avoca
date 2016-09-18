
if Server then

local originit = Harvester.OnInitialized

function Harvester:OnInitialized() --Seeing as harvs require infest to be placed for normal commanders, this only applies with autocomm
                                   --Becauuse for some reason, spawning clogs/cysts via map editor is too much of a bitch.
originit(self)

 if not self:GetGameEffectMask(kGameEffect.OnInfestation) then 
        local clog = CreateEntity(Clog.kMapName, FindFreeSpace(self:GetOrigin()), 2)
  end

end


end