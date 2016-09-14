if Server then
  local origcexit = Tunnel.UseExit
 function Tunnel:UseExit(entity, exit, exitSide)
    if exit:isa("CommTunnel") then
        local destinationOrigin = FindFreeSpawn(exit)// + kExitOffset
        
        if entity.OnUseGorgeTunnel then
            entity:OnUseGorgeTunnel(destinationOrigin)
        end
        
        entity:SetOrigin(destinationOrigin)

        if entity:isa("Player") then
        
            local newAngles = entity:GetViewAngles()
            newAngles.pitch = 0
            newAngles.roll = 0
            newAngles.yaw = newAngles.yaw + self:GetMinimapYawOffset()
            entity:SetOffsetAngles(newAngles)
            
        end    
    else
    return origcexit(self, entity, exit, exitSide)
    end
 end
  
 
  end