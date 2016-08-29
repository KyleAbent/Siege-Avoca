function MAC:GetCanBeUsed(player, useSuccessTable)
  useSuccessTable.useSuccess = true 
end
function MAC:OnUse(player, elapsedTime, useSuccessTable)

    if Server then
       self:PlayerUse(player) 
    end
    
end
function MAC:PlayerUse(player)
   self:GiveOrder(kTechId.FollowAndWeld, player:GetId(), player:GetOrigin(), nil, true, true) 
end