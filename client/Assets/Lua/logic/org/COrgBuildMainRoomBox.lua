local COrgBuildMainRoomBox = class("COrgBuildMainRoomBox", CBox)

function COrgBuildMainRoomBox.ctor(self, obj)
	CBox.ctor(self, obj)
    self.m_BuildLevel = self:NewUI(2, CLabel)
    self.m_BuildingHint = self:NewUI(3, CSprite)
    self.m_BuildSlider = self:NewUI(4, CSlider)
    self.m_BuildStatusL = self:NewUI(5, CLabel)
    self.m_BuildTexture = self:NewUI(6, CTexture)
    self.m_BuildAccelerate = self:NewUI(7, CButton)
    self.m_TimeLabel = self:NewUI(8, CLabel)
	self:InitContent()
end

function COrgBuildMainRoomBox.InitContent(self)
    self.m_BuildTexture:AddUIEvent("click", callback(self, "OnShowInfo"))
    self.m_BuildAccelerate:AddUIEvent("click", callback(self, "OnAccelerate"))
end

function COrgBuildMainRoomBox.OnShowInfo(self)
    
    COrgBuildingUpgradeView:ShowView(function(upgradeView)
        upgradeView:ShowMainPalace(self.m_BuildInfo)
    end)
end

-- |  bid = 101
-- |  build_time = 0
-- |  level = 1
-- |  quick_num = 0
-- |  quick_sec = 0
function COrgBuildMainRoomBox.ShowBuildInfo(self, buildInfo)
    self.m_BuildInfo = buildInfo
    if buildInfo.level > 0 then
        self:ShowBuilded(buildInfo)    
    end
    if buildInfo.build_time > 0 then
        self:ShowBuilding(buildInfo)
    end
end

function COrgBuildMainRoomBox.ShowBuilded(self, buildInfo)
    --self.m_BuildLevel:SetText(buildInfo.level)
    self.m_BuildLevel:SetActive(false)
    self.m_BuildingHint:SetActive(false)
    self.m_BuildSlider:SetActive(false)
end

function COrgBuildMainRoomBox.ShowBuilding(self, buildInfo)
    self.m_BuildSlider:SetActive(true)
    self.m_BuildingHint:SetActive(true)
    local needTime = data.orgdata.BUILDLEVEL[buildInfo.bid][buildInfo.level+1].upgrade_time   
    local function Time()
        local time, slider = g_OrgCtrl:CalculateTime(needTime, buildInfo.build_time - buildInfo.quick_sec)
        if time == false then 
        	Utils.DelTimer(self.m_DoneTimer)
            if not self.m_BuildSlider:IsDestroy() and not self.m_BuildLevel:IsDestroy() then
                self.m_BuildSlider:SetActive(false)
                self.m_BuildingHint:SetActive(false)
                g_OrgCtrl:PlayEffect(self, self.m_BuildSlider:GetPos(), self.m_BuildLevel:GetPos()) 
            end
            return false
        end
        if not self.m_TimeLabel:IsDestroy() then
            self.m_TimeLabel:SetText(time)
        end
        if not self.m_BuildSlider:IsDestroy() then
            self.m_BuildSlider:SetValue(slider)
        end
        return true
    end
    if buildInfo.build_time > 0 and self.m_DoneTimer == nil then
        self.m_DoneTimer = Utils.AddTimer(Time, 1, 0)
    end
    if buildInfo.level <= 0 then
        self.m_BuildStatusL:SetText("建造中")
    else
        self.m_BuildStatusL:SetText("升级中")
    end
end

function COrgBuildMainRoomBox.OnAccelerate(self)
    COAccelerateBuildView:ShowView(function (oView)
        oView:InitContent(self.m_BuildInfo)
    end)
end

return COrgBuildMainRoomBox