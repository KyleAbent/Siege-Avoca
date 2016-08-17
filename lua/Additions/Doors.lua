Script.Load("lua/ScriptActor.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/MarineOutlineMixin.lua")

class 'SiegeDoor' (ScriptActor)

SiegeDoor.kMapName = "siegedoor"

local kOpeningEffect = PrecacheAsset("cinematics/environment/steamjet_ceiling.cinematic")

local networkVars =
{
    scale = "vector",
    model = "string (128)",
    moveSpeed = "float",
    isvisible = "boolean",
    savedOrigin = "vector",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)


function SiegeDoor:OnCreate()
    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    self.isvisible = true
end
function SiegeDoor:OnInitialized()

    ScriptActor.OnInitialized(self)  
    Shared.PrecacheModel(self.model) 
    self:SetModel(self.model)
    self.savedOrigin = self:GetOrigin()
	
    if Server then
    elseif Client then

    InitMixin(self, MarineOutlineMixin)
     InitMixin(self, HiveVisionMixin)
     
     /*
        	local model = self:GetRenderModel()
            HiveVision_AddModel( model )
            EquipmentOutline_AddModel( model ) 
     */
            /*
            self.OpeningEffect = Client.CreateCinematic(RenderScene.Zone_Default)
            self.OpeningEffect:SetCinematic(kOpeningEffect)
            self.OpeningEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.OpeningEffect:SetParent(self)
            self.OpeningEffect:SetCoords(self:GetCoords())
           // self.OpeningEffectSetAttachPoint(self:GetAttachPointIndex(attachPoint))
            self.OpeningEffect:SetIsActive(false)
            */
    end
    
    self:SetPhysicsType(PhysicsType.Kinematic)
    --self:SetPhysicsGroup(PhysicsGroup.FuncMoveable)
end

function SiegeDoor:Reset()
    ScriptActor.Reset(self)
    self:MakeSurePlayersCanGoThroughWhenMoving() 
end
function SiegeDoor:Open()       
        self:AddTimedCallback(SiegeDoor.UpdatePosition, 0.5)
end
function SiegeDoor:MakeSurePlayersCanGoThroughWhenMoving()
                self:UpdateModelCoords()
                self:UpdatePhysicsModel()
               if (self._modelCoords and self.boneCoords and self.physicsModel) then
              self.physicsModel:SetBoneCoords(self._modelCoords, self.boneCoords)
               end  
               self:MarkPhysicsDirty()    
end
function SiegeDoor:UpdatePosition() 
     local waypoint = self.savedOrigin + Vector(0, kDoorMoveUpVect, 0)
     local originsmatch = self:GetOrigin() == waypoint
       Print("Waypoint difference is %s", waypoint - self:GetOrigin())
   if waypoint then
       if not originsmatch then               
               self:SetOrigin(self:GetOrigin() + Vector(0,0.025,0) )        
                self:MakeSurePlayersCanGoThroughWhenMoving()                      
       else
                self:MakeSurePlayersCanGoThroughWhenMoving() 
                return false
            end
  end  
     
    return not originsmatch
            
end 
local function TrickedYou(self)
self:AddTimedCallback(SiegeDoor.NoReallyIDid, 4)
end
function SiegeDoor:NoReallyIDid()
 self:SetOrigin(self.savedOrigin )
 return self:GetOrigin() ~= self.savedOrigin
end
function SiegeDoor:OnAdjustModelCoords(modelCoords)

    local coords = modelCoords
    if self.scale and self.scale:GetLength() ~= 0 then
        coords.xAxis = coords.xAxis * self.scale.x
        coords.yAxis = coords.yAxis * self.scale.y
        coords.zAxis = coords.zAxis * self.scale.z
    end
    return coords
    
end
function SiegeDoor:OnReset()
 self:SetOrigin(self.savedOrigin + kDoorMoveUpVect)
 TrickedYou(self)
    
end
Shared.LinkClassToMap("SiegeDoor", SiegeDoor.kMapName, networkVars)

class 'FrontDoor' (SiegeDoor)

FrontDoor.kMapName = "frontdoor"

Shared.LinkClassToMap("FrontDoor", FrontDoor.kMapName, networkVars)