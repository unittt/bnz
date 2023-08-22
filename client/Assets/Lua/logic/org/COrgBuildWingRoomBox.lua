local COrgBuildWingRoomBox = class("COrgBuildWingRoomBox", CBox)

function COrgBuildWingRoomBox.ctor(self, obj)
	CBox.ctor(self, obj)
    self.m_BuildLevel = self:NewUI(2, CLabel)
    self.m_BuildingHint = self:NewUI(3, CSprite)
    self.m_BuildSlider = self:NewUI(4, CSlider)
    -- self.m_BuildTime = self:NewUI(5, CLabel)
    self.m_BuildTexture = self:NewUI(6, CTexture)
    self.m_BuildAccelerate = self:NewUI(7, CButton)
    self.m_BuildBtn = self:NewUI(8, CButton)
    self.m_NotBuildHint = self:NewUI(9, CLabel)
    self.m_TimeLabel = self:NewUI(10, CLabel)
    self.m_BuildStatusL = self:NewUI(11, CLabel)
	self:InitContent()
end

function COrgBuildWingRoomBox.InitContent(self)
    self.m_BuildTexture:AddUIEvent("click", callback(self, "OnShowInfo"))
    self.m_BuildBtn:AddUIEvent("click", callback(self, "OnBuild"))
    self.m_BuildAccelerate:AddUIEvent("click", callback(self, "OnAccelerate"))
end

function COrgBuildWingRoomBox.OnShowInfo(self)
    if self.m_BuildInfo.level <= 0 then
        if self.m_BuildInfo.build_time > 0 then
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1086].content)
        else
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1088].content)
        end
        return
    end
    COrgPalaceView:ShowView(function(oView)
        oView:InitContent(self.m_BuildInfo)
    end)
end

function COrgBuildWingRoomBox.OnBuild(self)
    if g_OrgCtrl:IamLeader() or g_OrgCtrl:IamViceLeader() then
        COrgBuildingUpgradeView:ShowView(function(upgradeView)
            upgradeView:ShowRoom(self.m_BuildInfo)
        end)
    else
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1080].content)
    end
end

function COrgBuildWingRoomBox.ShowBuildInfo(self, buildInfo)
    self.m_BuildInfo = buildInfo
    if buildInfo.level > 0 then
        self:ShowBuilded(buildInfo)
        --printc("显示已经建筑")
    else
        self:ShowNotBuild()
    end
    if buildInfo.build_time > 0 then
        self:ShowBuilding(buildInfo)
    end
end

--建造中
function COrgBuildWingRoomBox.ShowBuilding(self, buildInfo)
    self.m_BuildSlider:SetActive(true)
    self.m_BuildingHint:SetActive(true)
    self.m_BuildBtn:SetActive(false)
    self.m_NotBuildHint:SetActive(false)
    local needTime = data.orgdata.BUILDLEVEL[buildInfo.bid][buildInfo.level+1].upgrade_time
    local function Time()
        local time, slider = g_OrgCtrl:CalculateTime(needTime, buildInfo.build_time - buildInfo.quick_sec)
        if time == false then
            Utils.DelTimer(self.m_DoneTimer) 
            if not self.m_BuildSlider:IsDestroy() and not self.m_BuildLevel:IsDestroy() then
                self.m_BuildSlider:SetActive(false)
                self.m_BuildingHint:SetActive(false)
                self.m_BuildTexture:SetGrey(false)
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
    if self.m_DoneTimer then
		Utils.DelTimer(self.m_DoneTimer)
	end
    self.m_DoneTimer = Utils.AddTimer(Time, 1, 0)
    if buildInfo.level <= 0 then
        self.m_BuildStatusL:SetText("建造中")
    else
        self.m_BuildStatusL:SetText("升级中")
    end
end

--已建造
function COrgBuildWingRoomBox.ShowBuilded(self, buildInfo)
    --self.m_BuildLevel:SetText(buildInfo.level)
    self.m_BuildLevel:SetActive(false)
    self.m_BuildingHint:SetActive(false)
    self.m_BuildSlider:SetActive(false)
    self.m_BuildTexture:SetGrey(false)
    self.m_BuildBtn:SetActive(false)
end

--未建造
function COrgBuildWingRoomBox.ShowNotBuild(self)
    self.m_BuildLevel:SetActive(false)
    self.m_BuildingHint:SetActive(false)
    self.m_NotBuildHint:SetActive(true)
    self.m_BuildSlider:SetActive(false)
    self.m_BuildTexture:SetGrey(true)
    self.m_BuildBtn:SetActive(true)
end

function COrgBuildWingRoomBox.OnAccelerate(self)
    COAccelerateBuildView:ShowView(function (oView)
        oView:InitContent(self.m_BuildInfo)
    end)
end

return COrgBuildWingRoomBox