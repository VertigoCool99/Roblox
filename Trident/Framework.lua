
print("Framework Version: v1.03\nLoading")

--Locals
local oldtick = tick()
local Camera = game:GetService("Workspace").CurrentCamera
local CharcaterMiddle = game:GetService("Workspace").Ignore.LocalCharacter.Middle
local Mouse = game.Players.LocalPlayer:GetMouse()
local RunService = Game:GetService("RunService")

--Tables
local Framework = {}
local Esp = {Settings={Boxes=false,Distances=false,Armor=false,ItemDistances=false,ItemNames=false,OreDistances=false,OreNames=false,PlayerRenderDistance=1000,ItemRenderDistance=1000,OreRenderDistance=1000,PlayerBoxColor=Color3.fromRGB(120,81,169),PlayerDistanceColor=Color3.fromRGB(120,81,169),PlayerArmorColor=Color3.fromRGB(120,81,169),Sleeping=false,PlayerSleepingColor=Color3.fromRGB(120,81,169),LocalChamsColor=Color3.fromRGB(120,81,169),LocalChamsMaterial=Enum.Material.ForceField},Drawings={},Connections={}}
local Crosshair = {Enabled=false,CrosshairThickness=2,CrosshairSize=8,CrosshairColor=Color3.fromRGB(255,0,255),X,Y}
local Aimbot = {Settings={FovEnabled=false,FovTransparency=1,FovSize=90,FovFilled=false,FovColor=Color3.fromRGB(120,81,169)},Fov={},FovCircleDrawing=nil,AimbotHitpart="Head",AimbotSmoothing=3}
local AllowedOres = {"StoneOre","NitrateOre","IronOre"}
local AllowedItems = {"PartsBox","MilitaryCrate","SnallBox","SnallBox","Backpack","VendingMachine"}

--Functions
function Framework:IsSleeping(Model)
    if Model and Model:FindFirstChild("AnimationController") and Model.AnimationController:FindFirstChild("Animator") then
        for i,v in pairs(Model.AnimationController.Animator:GetPlayingAnimationTracks()) do
            if v.Animation.AnimationId == "rbxassetid://12501841745" then
                return true
            else
                return false
            end
        end
    end
end
function Framework:IsVisible(PlayerModel)
    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = {game:GetService("Workspace").Ignore}
    Params.FilterType = Enum.RaycastFilterType.Blacklist

    ray = game:GetService("Workspace"):Raycast(Camera.CFrame.p, PlayerModel:GetPivot().p, Params)
    if ray.Instance:IsDescendantOf(PlayerModel) then
        return true
    else
        return
    end
end
function Framework:GetCenterScreen()
    return Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
end
function Framework:ReplaceSound(SoundName,NewId)
    game:GetService("SoundService")[SoundName].SoundId = NewId
end
function Framework:CreateConnection(Object,Callback)
    local Connection = Object:Connect(Callback)
    table.insert(Esp.Connections, Connection)
    return Connection
end
function Framework:GetArmor(Model)
    if Model.Armor:FindFirstChildOfClass("Folder") then
        return true
    else
        return false
    end
end
function Framework:GetHoldingTool()
    if getrenv()._G.modules.FPS.GetEquippedItem().id == nil then return "None" end
    return getrenv()._G.modules.FPS.GetEquippedItem().id
end
function Framework:GetEntitys()
    return getrenv()._G.modules.Entity.List
end
function Framework:GetPlayers()
    return getupvalues(getrenv()._G.modules.Player.GetPlayerModel)[1]
end
function Framework:DistanceFromCharacter(Vector3)
    return (CharcaterMiddle:GetPivot().p - Vector3).Magnitude
end
function Framework:IsOnScreen(Model)
    local RandomVar, OnScreen = Camera:WorldToViewportPoint(Model:GetPivot().p)
    return OnScreen
end
function Framework:PositionToVector2(Vector3)
    local ViewportPosition, onscreen = Camera:WorldToViewportPoint(Vector3)
    return Vector2.new(ViewportPosition.X,ViewportPosition.Y), onscreen
end
function Framework:MoveMouse(PositionX,PositionY,Smoothing) --Provide Characters X And Y As It Takes Off Mouse
    NewPos = Vector2.new(Mouse.X-PositionX, Mouse.Y-PositionY)
    mousemoverel((-NewPos.X*0.5)/Smoothing,(-NewPos.Y*0.5)/Smoothing)
end
function Framework:Draw(Type,Propities)
    Object = Drawing.new(Type)
    for i,v in next,Propities do
        Object[i] = v
    end
    if Object then
        table.insert(Esp.Drawings, Object)
        return Object
    end
end
function Framework:ItemToColor(Item)
    table = {}
    table["PartsBox"] = Color3.new(0.929,0.973,0.796)
    table["MilitaryCrate"] = Color3.new(0.075,0.353,0.086)
    table["SnallBox"] = Color3.new(0.263,0.200,0.075)
    table["MediumBox"] = Color3.new(0.404,0.302,0.094)
    table["Backpack"] = Color3.new(0.404,0.302,0.094)
    table["VendingMachine"] = Color3.new(0.192,0.478,0.988)
    table["StoneOre"] = Color3.new(0.612,0.612,0.612)
    table["IronOre"] = Color3.new(0.773,0.686,0.365)
    table["NitrateOre"] = Color3.new(1,1,1)
    return table[Item]
end

function Esp:LocalChams()
    for i,v in pairs(game:GetService("Workspace").Ignore.FPSArms:GetChildren()) do
        if v:IsA("MeshPart") then
            v.Color = Esp.Settings.LocalChamsColor
            v.Material = Esp.Settings.LocalChamsMaterial
            Esp.Connections.UpdateLocalChams = Framework:CreateConnection(RunService.RenderStepped,function()
                v.Color = Esp.Settings.LocalChamsColor
                v.Material = Esp.Settings.LocalChamsMaterial
            end)
        end
    end
end

function Esp:CreateCrosshair()
    do
        Crosshair.X = Framework:Draw("Line",{Thickness=Crosshair.CrosshairThickness,Color=Crosshair.CrosshairColor,ZIndex = -9})
        Crosshair.Y = Framework:Draw("Line",{Thickness=Crosshair.CrosshairThickness,Color=Crosshair.CrosshairColor,ZIndex = -9})
        Crosshair.X.From = Framework:GetCenterScreen() - Vector2.new(0,Crosshair.CrosshairSize)
        Crosshair.X.To = Framework:GetCenterScreen() + Vector2.new(0,Crosshair.CrosshairSize)
        Crosshair.Y.From = Framework:GetCenterScreen() - Vector2.new(Crosshair.CrosshairSize,0)
        Crosshair.Y.To = Framework:GetCenterScreen() + Vector2.new(Crosshair.CrosshairSize,0)
        Crosshair.X.Visible = Crosshair.Enabled
        Crosshair.Y.Visible = Crosshair.Enabled
        Esp.Connections.UpdateCrosshair = Framework:CreateConnection(RunService.RenderStepped,function()
            Crosshair.X.Color=Crosshair.CrosshairColor
            Crosshair.X.Thickness=Crosshair.CrosshairThickness
            Crosshair.Y.Color=Crosshair.CrosshairColor
            Crosshair.Y.Thickness=Crosshair.CrosshairThickness
            Crosshair.X.From = Framework:GetCenterScreen() - Vector2.new(0,Crosshair.CrosshairSize)
            Crosshair.X.To = Framework:GetCenterScreen() + Vector2.new(0,Crosshair.CrosshairSize)
            Crosshair.Y.From = Framework:GetCenterScreen() - Vector2.new(Crosshair.CrosshairSize,0)
            Crosshair.Y.To = Framework:GetCenterScreen() + Vector2.new(Crosshair.CrosshairSize,0)
            Crosshair.X.Visible = Crosshair.Enabled
            Crosshair.Y.Visible = Crosshair.Enabled
        end)
    end
end
function Esp:GetBoxPosAndSize(Object)
    cf,size = Object:GetBoundingBox()
    corners = {cf * CFrame.new(size.x/2,size.y/2,size.z/2),cf * CFrame.new(size.x/2,size.y/2,-size.z/2),cf * CFrame.new(-size.x/2,size.y/2,size.z/2),cf * CFrame.new(-size.x/2,size.y/2,-size.z/2),cf * CFrame.new(size.x/2,-size.y/2,size.z/2),cf * CFrame.new(size.x/2,-size.y/2,-size.z/2),cf * CFrame.new(-size.x/2,-size.y/2,size.z/2),cf * CFrame.new(-size.x/2,-size.y/2,-size.z/2),}
    local left,top = Vector2.new(math.huge,0),Vector2.new(0,math.huge)
    local right,bottom = Vector2.new(-math.huge,0),Vector2.new(0,-math.huge)
    for i, v in pairs(corners) do
        local point = Camera:WorldToViewportPoint(v.Position)
        if point.Y < top.Y then top = point end
        if point.Y > bottom.Y then bottom = point end
        if point.X > right.X then right = point end
        if point.X < left.X then left = point end
    end
    if left and right and top and bottom then
       return math.floor(left.X),math.floor(right.X),math.floor(top.Y),math.floor(bottom.Y)
    end
end

--Esp Loops
do
    function Esp:AddPlayer(Model)
        local Box,BoxOutline,ArmorText,DistanceText,SleepingText = Framework:Draw("Square",{Thickness=1,Filled=false,Color = Esp.Settings.PlayerBoxColor,ZIndex = -9}),Framework:Draw("Square",{Thickness=2,Filled=false,Color = Color3.fromRGB(0,0,0),ZIndex = -10}),Framework:Draw("Text",{Text = "Nil",Font=2,Size=13,Center=true,Outline=true,Color = Esp.Settings.PlayerArmorColor,ZIndex = -9}),Framework:Draw("Text",{Text ="",Font=2,Size=13,Center=true,Outline=true,Color = Esp.Settings.PlayerDistanceColor,ZIndex = -9}),Framework:Draw("Text",{Text ="",Font=2,Size=13,Center=true,Outline=true,Color = Esp.Settings.PlayerSleepingColor,ZIndex = -9})
        local Render = game:GetService("RunService").RenderStepped:Connect(function()
            if Model and Model:FindFirstChild("HumanoidRootPart") then
                local Pos,Visible = workspace.CurrentCamera:WorldToViewportPoint(Model:GetPivot().p)
                left,right,top,bottom = Esp:GetBoxPosAndSize(Model)
                if Visible == true and Esp.Settings.Boxes == true and Framework:DistanceFromCharacter(Model:GetPivot().p) <= Esp.Settings.PlayerRenderDistance then
                    Box.Color = Esp.Settings.PlayerBoxColor
                    BoxOutline.Visible = true
                    Box.Visible = true
                    BoxOutline.Position = Vector2.new(left,top)
                    BoxOutline.Size = Vector2.new(right-left,bottom-top)
                    Box.Position = Vector2.new(left,top)
                    Box.Size = Vector2.new(right-left,bottom-top)
                else
                    BoxOutline.Visible = false
                    Box.Visible = false
                end
                if Visible == true and Esp.Settings.Distances == true and Framework:DistanceFromCharacter(Model:GetPivot().p) <= Esp.Settings.PlayerRenderDistance then
                    DistanceText.Visible = true
                    DistanceText.Position = Vector2.new((left+right)/2,bottom)
                    DistanceText.Color = Esp.Settings.PlayerDistanceColor
                    DistanceText.Text = tostring(math.floor(Framework:DistanceFromCharacter(Model:GetPivot().p))).." Studs"
                else
                    DistanceText.Visible = false
                end
                if Visible == true and Esp.Settings.Sleeping == true and Framework:DistanceFromCharacter(Model:GetPivot().p) <= Esp.Settings.PlayerRenderDistance then
                    if Framework:IsSleeping(Model) == true then SleepingText.Text = "Sleeping" else SleepingText.Text = "Awake" end
                    SleepingText.Visible = true
                    SleepingText.Color = Esp.Settings.PlayerSleepingColor
                    SleepingText.Position = Vector2.new((left+right)/2,top-SleepingText.TextBounds.Y)
                else
                    SleepingText.Visible = false
                end
                if Visible == true and Esp.Settings.Armor == true and Framework:DistanceFromCharacter(Model:GetPivot().p) <= Esp.Settings.PlayerRenderDistance then
                    if Framework:GetArmor(Model) == true then ArmorText.Text = "Armored" else ArmorText.Text = "No Armor" end
                    ArmorText.Visible = true
                    ArmorText.Color = Esp.Settings.PlayerArmorColor
                    ArmorText.Position = Vector2.new(left-(ArmorText.TextBounds.X/2),top)
                else
                    ArmorText.Visible = false
                end
            else
                Box.Visible = false
                BoxOutline.Visible = false
                ArmorText.Visible = false
                DistanceText.Visible = false
                SleepingText.Visible = false
                if not Model then
                    SleepingText:Remove()
                    Box:Remove()
                    DistanceText:Remove()
                    BoxOutline:Remove()
                    ArmorText:Remove()
                    Render:Disconnect()
                end
            end
        end)
    end
end
do
    function Esp:AddOre(Item)
        local Model = Item.model
        local Distance,Name = Framework:Draw("Text",{Text ="",Font=2,Size=13,Center=true,Outline=true,Color=Color3.fromRGB(255,255,255),ZIndex = -9}),Framework:Draw("Text",{Text="",Font=2,Size=13,Center=true,Outline=true,Color=Color3.fromRGB(255,255,255),ZIndex = -9})
        local Render = game:GetService("RunService").RenderStepped:Connect(function()
            if Model and Model:FindFirstChild("Part") then
                local Pos,Visible = workspace.CurrentCamera:WorldToViewportPoint(Model:GetPivot().p)
                local pos2 = Camera:WorldToViewportPoint(Item.model:GetPivot().p)
                local pos = Vector2.new(pos2.X,pos2.Y)
                if Esp.Settings.OreDistances == true and Visible == true and Framework:DistanceFromCharacter(Item.model:GetPivot().p) <= Esp.Settings.OreRenderDistance then
                    Distance.Visible = true
                    Distance.Position = Vector2.new(pos.X,pos.Y + Distance.TextBounds.Y)
                    Distance.Color = Framework:ItemToColor(Item.typ)
                    Distance.Text = tostring(math.floor(Framework:DistanceFromCharacter(Item.model:GetPivot().p))).." Studs"
                else
                    Distance.Visible = false
                end
                if Esp.Settings.OreNames == true and Visible == true and Framework:DistanceFromCharacter(Item.model:GetPivot().p) <= Esp.Settings.OreRenderDistance then
                    Name.Visible = true
                    Name.Position = pos
                    Name.Color = Framework:ItemToColor(tostring(Item.typ))
                    Name.Text = Item.typ
                else
                    Name.Visible = false
                end
            else
                Distance.Visible = false
                Name.Visible = false
                if not Model and not Model:FindFirstChild("Part") then
                    Distance:Remove()
                    Name:Remove()
                    Render:Disconnect()
                end
            end
        end)
    end
end

function Aimbot:GetProjectileInfo()
    if getrenv()._G.modules.FPS.GetEquippedItem() == nil then return false end
    local mod = require(game:GetService("ReplicatedStorage").ItemConfigs[getrenv()._G.modules.FPS.GetEquippedItem().id])
    if table.find(mod, "ProjectileSpeed") then
        PS,PD = mod.projectileSpeed, mod.projectileDrop        
        return PS,PD
    end
    return nil
end
function Aimbot:CreateFov()
    FovCircle = Framework:Draw("Circle",{Visible=Aimbot.Settings.FovEnabled,Transparency=Aimbot.Settings.FovTransparency})
    FovCircle.Visible = Aimbot.Settings.FovEnabled
    FovCircle.Transparency=Aimbot.Settings.FovTransparency
    FovCircle.Thickness=2
    FovCircle.NumSides=120
    FovCircle.Radius=Aimbot.Settings.FovSize
    FovCircle.Filled=Aimbot.Settings.FovFilled
    FovCircle.Color=Aimbot.Settings.FovColor
    FovCircle.Position=Framework:GetCenterScreen()
    Aimbot.FovCircleDrawing = FovCircle
end
function Aimbot:InFov(Model)
    if not Model then return false end
    local playerpos = Camera:WorldToViewportPoint(Model:GetPivot().p)
    local distance = (Aimbot.FovCircleDrawing.Position - Vector2.new(playerpos.X,playerpos.Y)).magnitude
    if distance <= Aimbot.FovCircleDrawing.Radius then
        return true
    end
    return false
end
function Aimbot:GetClosest()
    local closest, distance = nil,math.huge
    for i, v in pairs(Framework:GetPlayers()) do
        if v and v.model and v.model:FindFirstChild(Aimbot.AimbotHitpart) and Aimbot:InFov(v.model) == true and Framework:IsSleeping(v.model) == false then
            local playerpos = Camera:WorldToViewportPoint(v.model:GetPivot().p)
            local magnitude = (Vector2.new(playerpos.X, playerpos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if magnitude < distance then
                closest = v.model
                distance = magnitude
            end
        end
    end
    return closest
end

print("Loaded In: "..tick()-oldtick)

return Framework, Esp, Aimbot, Crosshair
