local COAccelerateBuildView = class("COAccelerateBuildView", CViewBase)

function COAccelerateBuildView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OAccelerateBuildView.prefab", cb)
	--界面设置
	self.m_ExtendClose = "Black"
    self.m_CoinIcon = {10002,10003,10221}
end

function COAccelerateBuildView.OnCreateView(self)
    self.m_BuildTexture = self:NewUI(1, CTexture)
    self.m_BuildDes = self:NewUI(2, CLabel)
    self.m_BuildUpgradeSlider = self:NewUI(3, CSlider)
    self.m_BuildName = self:NewUI(4, CSprite)
    self.m_ItemGrid = self:NewUI(5, CGrid)
    self.m_ItemClone = self:NewUI(6, CBox)
    self.m_TimeLabel = self:NewUI(7, CLabel)
    self.m_TimesLabel = self:NewUI(8, CLabel)
    self.m_BuildNameLabel = self:NewUI(9, CLabel)
    self.m_CurLvLabel = self:NewUI(10, CLabel)
    self.m_NextLvLabel = self:NewUI(11, CLabel)
    self.m_CloseBtn = self:NewUI(12, CButton)
    self.m_TitleL = self:NewUI(13, CLabel)
    self.m_LevelObj = self:NewUI(14, CObject)
    self.m_BuildDoneL = self:NewUI(15, CLabel)

    self:InitGrid()
end
            
function COAccelerateBuildView.InitContent(self, buildInfo)
    self.m_ItemClone:SetActive(false)
    self.m_CurBuildInfo = buildInfo

    local info = data.orgdata.BUILDLEVEL[buildInfo.bid][1]
    self.m_BuildTexture:SetChangeMainTexture("Org", info.texture, callback(self, "UpdateBuildTexture"))
    self.m_BuildName:SetSpriteName(tostring(info.font))
    self.m_BuildNameLabel:SetText(info.name)
    self.m_CurLvLabel:SetText(buildInfo.level.."级")
    self.m_NextLvLabel:SetText((buildInfo.level+1).."级")
    self.m_BuildDoneL:SetText(info.name.." "..(buildInfo.level+1).."级")
    self.m_BuildDes:SetActive(false)
    self:RefreshAllButton()
    self:RefreshTimes()
    if buildInfo.level <= 0 then
        self.m_TitleL:SetText("建筑建造")
    end
    local needTime = data.orgdata.BUILDLEVEL[buildInfo.bid][buildInfo.level+1].upgrade_time
    local function Time()
        local time , slider = g_OrgCtrl:CalculateTime(needTime, buildInfo.build_time - buildInfo.quick_sec)
        if time == false then 
        	Utils.DelTimer(self.m_DoneTimer)
            -- self.m_BuildUpgradeSlider:SetActive(false)
            self.m_TimeLabel:SetText("已完成")
            self.m_BuildDoneL:SetActive(true)
            self.m_LevelObj:SetActive(false)
            self.m_BuildUpgradeSlider:SetValue(1)
            return false
        end
        
        self.m_TimeLabel:SetText(time)
        self.m_BuildUpgradeSlider:SetValue(slider)
        return true
    end
    if self.m_DoneTimer then
		Utils.DelTimer(self.m_DoneTimer)
	end
    self.m_DoneTimer = Utils.AddTimer(Time, 1, 0)
    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function COAccelerateBuildView.OnOrgEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Org.Event.UpdateOrgBuildingInfos then
        if self.m_CurBuildInfo then
            self.m_CurBuildInfo = oCtrl.m_EventData[self.m_CurBuildInfo.bid]
            self:RefreshTimes()
            self:RefreshAllButton()
        end
    end
end

function COAccelerateBuildView.UpdateBuildTexture(self)
    self.m_BuildTexture:MakePixelPerfect()
    self.m_BuildTexture:SetLocalScale(Vector3.New(0.6, 0.6, 0))
end

function COAccelerateBuildView.RefreshTimes(self)
    local sText = string.format("还可以使用加速[c]#O%d[/c]次",3 - self.m_CurBuildInfo.quick_num)
    self.m_TimesLabel:SetText(sText)
end

function COAccelerateBuildView.InitGrid(self)
    --TODO:临时修改，回头改用BUILDQUICK表初始化UI
    local timespr = {
        [101] = "h7_10min",
        [102] = "h7_20min",
        [103] = "h7_60min"
    }
    local list = {101, 102, 103}
    for i=1, 3 do
        local v = data.orgdata.BUILDQUICK[list[i]]
        if v then
            local item = self.m_ItemClone:Clone()
            item:SetActive(true)
            item.icon = item:NewUI(1, CSprite)
            item.cost = item:NewUI(2, CLabel)
            item.award = item:NewUI(3, CLabel)
            item.btn = item:NewUI(4, CSprite)
            item.coin = item:NewUI(5, CSprite)
            item.time = item:NewUI(6, CLabel)
            item.time:SetText(string.format("%s分钟", v.quick_time/60))
            -- item.time:SetColor(Color.RGBAToColor(v.color))
            -- item.time:SetSpriteName(timespr[list[i]])
            item.icon:SetSpriteName(tostring(v.icon))
            item.coin:SetSpriteName(tostring(self.m_CoinIcon[v.cost.type]))
            item.cost:SetText(v.cost.val)
            item.award:SetText(v.reward_offer)
            item.btn:AddUIEvent("click", callback(self, "OnAccelerate", list[i], item))
            item.id = list[i]
            self.m_ItemGrid:AddChild(item)
        end
    end
end

function COAccelerateBuildView.RefreshAllButton(self)
    if self.m_CurBuildInfo.quick_num >= 3 then
        -- for i,oBox in ipairs(self.m_ItemGrid:GetChildList()) do
            -- oBox.btn:SetGrey(true)
            -- g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.OrgBuildAccelerate, oBox.id)
        -- end
    end
end

function COAccelerateBuildView.OnAccelerate(self, id, oBox)
    -- if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.OrgBuildAccelerate, id) then --冷却时间
    --     g_NotifyCtrl:FloatMsg(string.gsub(data.orgdata.TEXT[1031].content, "#SS", "3"))
    --     return
    -- end
    if self.m_CurBuildInfo.build_time <= 0 then
         g_NotifyCtrl:FloatMsg("已建造完成！")
         return
    end
    if self.m_CurBuildInfo.quick_num >= 3 then
        g_NotifyCtrl:FloatMsg("每人最多加速3次！")
        return
    end
    g_OrgCtrl:C2GSQuickBuild(self.m_CurBuildInfo.bid, id)
    -- g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.OrgBuildAccelerate, id, 3, function()
    --     oBox.btn:SetGrey(false)
    -- end)
    -- oBox.btn:SetGrey(true)
end

function COAccelerateBuildView.OnClose(self)
    if self.m_DoneTimer then
		Utils.DelTimer(self.m_DoneTimer)
	end
    self:CloseView()
end


return COAccelerateBuildView