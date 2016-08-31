function Whip:OnTeleportEnd()
                    self:InfestationNeedsUpdate()
                    self:AddTimedCallback(function()  self:InfestationNeedsUpdate() end, 1)
end