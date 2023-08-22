local COrgBuildGodRoomBox = class("COrgBuildGodRoomBox", CBox)

function COrgBuildGodRoomBox.ctor(self, obj)
	CBox.ctor(self, obj)
    self.m_BuildLevel = self:NewUI(2, CLabel)
    self.m_BuildingHint = self:NewUI(3, CSprite)
    self.m_BuildSlider = self:NewUI(4, CSlider)
    self.m_BuildTime = self:NewUI(5, CLabel)
    self.m_BuildTexture = self:NewUI(6, CTexture)
    self.m_BuildAccelerate = self:NewUI(7, CButton)
    self.m_TimeLabel = self:NewUI(8, CLabel)
    self.m_BuildStatusL = self:NewUI(9, CLabel)
	self:InitContent()
end

function COrgBuildGodRoomBox.InitContent(self)
    self.m_BuildTexture:AddUIEvent("click", callback(self, "OnShowInfo"))
    self.m_BuildAccelerate:AddUIEvent("click", callback(self, "OnAccelerate"))
end

function COrgBuildGodRoomBox.OnShowInfo(self)
    if self.m_BuildInfo.level <= 0 then
        if self.m_BuildInfo.build_time > 0 then
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1086].content)
        else
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1088].content)
        end
        return
    end
    -- COrgPalaceView:ShowView(function(oView)
    --     oView:InitContent(self.m_BuildInfo)
    -- end)
    COrgActivityView:ShowView()
end

function COrgBuildGodRoomBox.ShowBuildInfo(self, buildInfo)
    self.m_BuildInfo = buildInfo
    if buildInfo.level > 0 then
        self:ShowBuilded(buildInfo)
    else
        self:ShowNotBuild(buildInfo)
    end
    if buildInfo.build_time > 0 then 
        self:ShowBuiding(buildInfo)
    end 
end

function COrgBuildGodRoomBox.ShowBuilded(self, buildInfo)
    self:SetActive(true)
    --self.m_BuildLevel:SetText(buildInfo.level)
    self.m_BuildLevel:SetActive(false)
    self.m_BuildingHint:SetActive(false)
    self.m_BuildSlider:SetActive(false)
end

function COrgBuildGodRoomBox.ShowBuiding(self, buildInfo)
    self.m_BuildSlider:SetActive(true)
    self.m_BuildingHint:SetActive(true)
    if data.orgdata.BUILDLEVEL[buildInfo.bid][buildInfo.level+1] == nil then
        return
    end
    local needTime = data.orgdata.BUILDLEVEL[buildInfo.bid][buildInfo.level+1].upgrade_time
    local function Time()
        local time, slider = g_OrgCtrl:CalculateTime(needTime, buildInfo.build_time - buildInfo.quick_sec)
        if time == false then
            Utils.DelTimer(self.m_DoneTimer)
            if not self.m_BuildSlider:IsDestroy() then
                self.m_BuildSlider:SetActive(false)
            end
            if not self.m_BuildingHint:IsDestroy() then
                self.m_BuildingHint:SetActive(false)
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

function COrgBuildGodRoomBox.ShowNotBuild(self, buildInfo)
    self.m_BuildSlider:SetActive(false)
    self.m_BuildLevel:SetActive(false)
    self.m_BuildingHint:SetActive(false) 
end


function COrgBuildGodRoomBox.OnAccelerate(self)
    COAccelerateBuildView:ShowView(function (oView)
        oView:InitContent(self.m_BuildInfo)
    end)
end

return COrgBuildGodRoomBox