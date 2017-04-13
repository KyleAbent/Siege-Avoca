function Cyst:GetCystParentRange()
return 999
end
function Cyst:GetCystParentRange()
return 999
end

function Cyst:GetMinRangeAC()
return  kCystRedeployRange * .7      
end

if Server then


   function Cyst:GetIsActuallyConnected()
   return true
   end
   
  function Cyst:GetCanAutoBuild()
    return true
   end
    
end