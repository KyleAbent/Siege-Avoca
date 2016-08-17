--Kyle 'Avoca' Abent
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"


function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
return true
end

function Plugin:MapPostLoad()
      Server.CreateEntity(SandCastle.kMapName)

end


function Plugin:SetGameState( Gamerules, State, OldState )
           if State == kGameState.Countdown then
       self:SimpleTimer( 8, function() 
          for _, sandcastle in ientitylist(Shared.GetEntitiesWithClassname("SandCastle")) do
             sandcastle:OnRoundStart()
             break
          end
       end)   
          end
end

function Plugin:CreateCommands()


end