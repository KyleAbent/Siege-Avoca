if Server then
function Onos:GetTierFourTechId()
    return kTechId.OnoGrow
end
end


--local orig_Onos_OnAdjustModelCoords = Onos.OnAdjustModelCoords
function Onos:OnAdjustModelCoords(modelCoords) 
--orig_Onos_OnAdjustModelCoords(self)
        local onoGrow = self:GetWeapon(OnoGrow.kMapName)
        local scale = 1
        if onoGrow then
          scale = onoGrow.modelsize
        end
    local coords = modelCoords
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    return coords
end
/*
function Onos:GetMaxViewOffsetHeight()
    local onoGrow = self:GetWeapon(OnoGrow.kMapName)
    local scale = 1
    
        if onoGrow then
          scale = onoGrow.modelsize
        end
        Print("GetMaxViewOffsetHeight scale is %s", scale)
    return  2.5 * scale
end

function Onos:GetExtentsOverride()
local kXZExtents = 0.35
local kYExtents = 0.95
local crouchshrink = 0
if self.crouching then crouchshrink = 0.5 end
if self.modelsize < 1 then
crouchshrink = 0.5 * self.modelsize
    return Vector(kXZExtents * self.modelsize, (kYExtents * self.modelsize) - crouchshrink, kXZExtents * self.modelsize)
 else
     return Vector(kXZExtents, kYExtents - crouchshrink, kXZExtents)
   end
end
*/