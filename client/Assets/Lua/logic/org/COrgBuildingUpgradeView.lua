local COrgBuildingUpgradeView = class("COrgBuildingUpgradeView", CViewBase)

function COrgBuildingUpgradeView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/OrgBuildingUpgradeView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "main2"
    self.m_ExtendClose = "Black"
    self.m_ItemList = {}
end

function COrgBuildingUpgradeView.OnCreateView(self)
    self.m_CloseBtn       = self:NewUI(1, CButton)
    self.m_Grid           = self:NewUI(2, CGrid)
    self.m_ItemClone      = self:NewUI(3, CBuildingUpgradeItem)
    self.m_RightInfo      = self:NewUI(4, CBox)
    self.m_TipBtn         = self:NewUI(5, CButton)
    self:InitContent()
end

function COrgBuildingUpgradeView.InitContent(self)
    self:InitRightInfo()
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnClickUpgradeBtn"))
    self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickIBtn"))
    self.m_AccelerateBtn:AddUIEvent("click", callback(self,"OnAccelerate"))
    
    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
    self:RebuildBuildingItems()
end

function COrgBuildingUpgradeView.InitRightInfo(self)
    self.m_BuildNameSprite = self.m_RightInfo:NewUI(1, CSprite)
    self.m_BuildTexture = self.m_RightInfo:NewUI(2, CTexture)
    self.m_BuildLevel = self.m_RightInfo:NewUI(3, CLabel)
    self.m_BuildSlider = self.m_RightInfo:NewUI(4, CSlider)
    self.m_EffectLabel1 = self.m_RightInfo:NewUI(5, CLabel)
    self.m_EffectLabel2 = self.m_RightInfo:NewUI(6, CLabel)
    self.m_UpgradeBox = self.m_RightInfo:NewUI(7, CBox)
    self.m_UpgradingBox = self.m_RightInfo:NewUI(8, CBox)
    self.m_DesBtn = self.m_RightInfo:NewUI(9, CButton)
    self.m_CashInfoBox = self.m_RightInfo:NewUI(10, CBox)
    self.m_UpgradeTitleL = self.m_RightInfo:NewUI(11, CLabel)
    self.m_MaxL = self.m_RightInfo:NewUI(12, CLabel)
    self.m_CurrEffL = self.m_RightInfo:NewUI(13, CLabel)

    self.m_BuildTexture:SetActive(false)
    self:InitUpgradeBox()
    self:InitUpgradingBox()
end

function COrgBuildingUpgradeView.InitUpgradeBox(self)
    self.m_OrgMoney = self.m_UpgradeBox:NewUI(1, CLabel)
    self.m_HouseGoods = self.m_UpgradeBox:NewUI(2, CLabel)
    self.m_UpgradeBtn = self.m_UpgradeBox:NewUI(3, CButton)
    self.m_ConditionL = self.m_UpgradeBox:NewUI(4, CLabel)
    self.m_ConditionTitleL = self.m_UpgradeBox:NewUI(5, CLabel)
    self.m_CostTitleL = self.m_UpgradeBox:NewUI(6, CLabel)
end

function COrgBuildingUpgradeView.InitUpgradingBox(self)
    self.m_UpgradeSlider = self.m_UpgradingBox:NewUI(1, CSlider)
    self.m_TimeLabel = self.m_UpgradingBox:NewUI(2, CLabel)
    self.m_UpgradeHint = self.m_UpgradingBox:NewUI(3, CLabel)
    self.m_AccelerateBtn = self.m_UpgradingBox:NewUI(4, CButton)
end

function COrgBuildingUpgradeView.OnOrgEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Org.Event.UpdateOrgBuildingInfos then
        local iBuildId = 101
        local dInfo = self.m_CurBuildInfo
        if dInfo then
            iBuildId = dInfo.bid
        else
            self.m_ItemList[iBuildId]:SetSelected(true)
        end 
        self:UpdateShowInfo(oCtrl.m_EventData[iBuildId])
    end
    if oCtrl.m_EventID == define.Org.Event.GetOrgMainInfo then
        self.m_BuildSlider:SetValue(g_OrgCtrl.m_Org.cash/self.m_CurUpgrade_con1)
        self.m_BuildSlider:SetSliderText(g_OrgCtrl.m_Org.cash.."/"..self.m_CurUpgrade_con1)
    end
end

function COrgBuildingUpgradeView.OnClickUpgradeBtn(self)
    if not self:AllowToBuild() then      
        return
    end
    local levelInfo = data.orgdata.BUILDLEVEL[self.m_CurBuildInfo.bid][self.m_CurBuildInfo.level+1]
    if levelInfo == nil then 
        g_NotifyCtrl:FloatMsg("满级啦！")
        return
    end 
    if levelInfo.cost_cash > g_OrgCtrl.m_Org.cash then
        g_NotifyCtrl:FloatMsg("帮派资金不足！")
        return
    end
    if levelInfo.upgrade_con1 > g_OrgCtrl.m_Org.cash then
        g_NotifyCtrl:FloatMsg("帮派资金没有达到升级条件！")
        return
    end
    if levelInfo.cost_item.id and levelInfo.cost_item.cnt > g_ItemCtrl:GetBagItemAmountBySid(levelInfo.cost_item.id) then
        local item = DataTools.GetItemData(levelInfo.cost_item.id)
        g_NotifyCtrl:FloatMsg(item.name.."不足！")
        return
    end
    if self.m_CurBuildInfo.bid ~= 101 and self.m_CurBuildInfo.level >= g_OrgCtrl.m_Buildings[101].level then
        g_NotifyCtrl:FloatMsg(string.gsub(data.orgdata.TEXT[1090].content,"#level", self.m_CurBuildInfo.level+1))
        return
    end
    g_OrgCtrl:C2GSUpGradeBuild(self.m_CurBuildInfo.bid)
end

function COrgBuildingUpgradeView.OnClickIBtn(self)
    local id = define.Instruction.Config.OrgBuildingUpgrade
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function COrgBuildingUpgradeView.AllowToBuild(self)
    if g_OrgCtrl:IamLeader() or g_OrgCtrl:IamViceLeader() then
        return true
    else
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1080].content)
        return false
    end
end

function COrgBuildingUpgradeView.RebuildBuildingItems(self)
    self.m_Grid:Clear()
    local listSort = {}
    for k,v in pairs(g_OrgCtrl.m_Buildings) do
        table.insert(listSort, v)
    end
    table.sort(listSort, function (v1, v2)
        if v2 == nil or v1 == nil then
            return false
        end
        return v1.bid < v2.bid
    end )
    for i,v in ipairs(listSort) do
        self:AddSingleBuildingItem(v)
    end
    self.m_Grid:Reposition()
end

function COrgBuildingUpgradeView.AddSingleBuildingItem(self, building)
    local oItem = self.m_ItemClone:Clone()
    oItem:SetActive(true)
    local function callback()
        self:UpdateShowInfo(building)
    end
    oItem:SetBoxInfo(building, callback)
    self.m_Grid:AddChild(oItem)
    oItem:SetGroup(self.m_Grid:GetInstanceID())
    self.m_ItemList[building.bid] = oItem
end

function COrgBuildingUpgradeView.UpdateShowInfo(self, building)
    self.m_CurBuildInfo = building
    local level = building.level + 1
    if level > #data.orgdata.BUILDLEVEL[building.bid] then 
        level = building.level
    end
    if self.m_ItemList[building.bid] then 
        self.m_ItemList[building.bid]:SetBoxInfo(building, callback(self,"UpdateShowInfo", building))
    end
    local info = data.orgdata.BUILDLEVEL[building.bid][level]
    local curInfo = data.orgdata.BUILDLEVEL[building.bid][building.level]

    self.m_BuildNameSprite:SetSpriteName(tostring(info.font))
    self.m_BuildTexture:SetChangeMainTexture("Org", tostring(info.texture), callback(self, "UpdateBuildTexture"))
    self.m_BuildLevel:SetText("等级："..building.level.."/"..#data.orgdata.BUILDLEVEL[building.bid])
    local bIsMaxLv = level == building.level
    self.m_MaxL:SetActive(bIsMaxLv)
    self.m_UpgradeTitleL:SetActive(not bIsMaxLv)
    if bIsMaxLv then 
        -- self.m_CashInfoBox:SetActive(false)
        self.m_UpgradeBox:SetActive(false)
        self.m_EffectLabel1:SetText("")  
        self.m_EffectLabel2:SetActive(false)
        self.m_UpgradingBox:SetActive(false)
        self.m_CurrEffL:SetText(curInfo.updes)
        return
    end
    -- self.m_CashInfoBox:SetActive(true)
    self.m_UpgradeBox:SetActive(true)
    if building.level <= 0 then
        self.m_BuildTexture:SetGrey(true)
        self.m_BuildNameSprite:SetGrey(true)
        self.m_UpgradeBtn:SetText("建 造")
        self.m_CostTitleL:SetText("建造消耗")
        self.m_ConditionTitleL:SetText("建造条件")
        self.m_UpgradeTitleL:SetText("建造效果")
    else
        self.m_BuildTexture:SetGrey(false)
        self.m_BuildNameSprite:SetGrey(false)
        self.m_UpgradeBtn:SetText("升 级")     
        self.m_CostTitleL:SetText("升级消耗")
        self.m_ConditionTitleL:SetText("升级条件")
        self.m_UpgradeTitleL:SetText("升级效果")
    end 
    self.m_CurUpgrade_con1 = info.upgrade_con1
    if g_OrgCtrl.m_Org.cash then
        self.m_BuildSlider:SetValue(g_OrgCtrl.m_Org.cash/info.upgrade_con1)
        self.m_BuildSlider:SetSliderText(g_OrgCtrl.m_Org.cash.."/"..info.upgrade_con1)
    end
    self.m_EffectLabel1:SetText(info.effectdes1)  
    if curInfo then
        self.m_CurrEffL:SetText(curInfo.updes)
    else
        self.m_CurrEffL:SetText("建筑未建造")
    end
    if info.effectdes2 ~= "" then
        self.m_EffectLabel2:SetText(info.effectdes2)
        self.m_EffectLabel2:SetActive(true)
    else
        self.m_EffectLabel2:SetActive(false)
    end
    self.m_OrgMoney:SetText("帮派资金  [1D8E00]"..info.cost_cash.."[-]")
    if next(info.cost_item) ~= nil then
        local item = DataTools.GetItemData(info.cost_item.id)
        self.m_HouseGoods:SetText(string.format("%s  [1D8E00]%s/%s[-]", item.name, 
        g_ItemCtrl:GetBagItemAmountBySid(info.cost_item.id), info.cost_item.cnt))
        self.m_HouseGoods:SetActive(true)
    else
        self.m_HouseGoods:SetActive(false)
    end
    if building.build_time > 0 then
        self:ShowUpgrading(building)
    else
        self.m_UpgradingBox:SetActive(false)
        self.m_UpgradeBox:SetActive(true)
    end  
    local sCondition = ""
    if building.bid == 101 then
        sCondition = string.format("服务器等级≥%d\n帮派资金≥%d", info.upgrade_con2, info.upgrade_con1)
    else
        sCondition = string.format("主殿等级≥%d\n帮派资金≥%d", info.upgrade_con2, info.upgrade_con1)
    end
    for i,dCondition in ipairs(info.upgrade_con3) do
        local dBuilding = data.orgdata.BUILDLEVEL[dCondition.id][1]
        sCondition = string.format("%s\n%s≥%d", sCondition, dBuilding.name, dCondition.lv)
    end
    self.m_ConditionL:SetText(sCondition)
end

function COrgBuildingUpgradeView.ShowUpgrading(self, building)
    self.m_UpgradingBox:SetActive(true)
    self.m_UpgradeBox:SetActive(false)
    local function DoneUpgrade()
        self.m_UpgradingBox:SetActive(false)
        -- if building.level+1 >= #data.orgdata.BUILDLEVEL[building.bid] then
        --     self.m_UpgradeBox:SetActive(false)
        --     self.m_CashInfoBox:SetActive(false)
        -- else
        --     self.m_UpgradeBox:SetActive(true)
        --     self.m_CashInfoBox:SetActive(true)
        -- end
    end
    local needTime = data.orgdata.BUILDLEVEL[building.bid][building.level+1].upgrade_time
    local str = {".", "..", "..."}
    local i = 1
    local function Time()
        local time, slider = g_OrgCtrl:CalculateTime(needTime, building.build_time - building.quick_sec, DoneUpgrade)
        if time == false then
            DoneUpgrade()
            return false
        end
        if not self.m_TimeLabel:IsDestroy() then
            self.m_TimeLabel:SetText(time)
        end
        if not self.m_UpgradeSlider:IsDestroy() then
            self.m_UpgradeSlider:SetValue(slider)
        end
        if i > #str then
            i = 1
        end
        if building.level == 0 then
            self.m_UpgradeHint:SetText("建造中"..str[i])
        else
            self.m_UpgradeHint:SetText("升级中"..str[i])
        end
        i = i+1
        return true
    end
    if self.m_DoneTimer then
		Utils.DelTimer(self.m_DoneTimer)
	end
    self.m_DoneTimer = Utils.AddTimer(Time, 1, 0)
end

function COrgBuildingUpgradeView.ShowMainPalace(self, building)
    self:CheckIsBuild(building)
end

function COrgBuildingUpgradeView.ShowPalace(self, building)
    self:CheckIsBuild(building)
end

function COrgBuildingUpgradeView.ShowRoom(self, building)
    self:CheckIsBuild(building)
end

function COrgBuildingUpgradeView.ShowTreasureRoom(self, building)
    self:CheckIsBuild(building)
end

function COrgBuildingUpgradeView.ShowVault(self, building)
    self:CheckIsBuild(building)
end

function COrgBuildingUpgradeView.UpdateBuildTexture(self)
    if not self.m_BuildTexture:GetActive() then
        self.m_BuildTexture:SetActive(true)
    end
    self.m_BuildTexture:MakePixelPerfect()
    self.m_BuildTexture:SetLocalScale(Vector3.New(0.6, 0.6, 0))
end

function COrgBuildingUpgradeView.OnClickBuild(self)
    
end 

function COrgBuildingUpgradeView.OnAccelerate(self)
    COAccelerateBuildView:ShowView(function (oView)
        oView:InitContent(self.m_CurBuildInfo)
    end)
end

function COrgBuildingUpgradeView.CheckIsBuild(self, building)
    self.m_CurBuildInfo = building
    self:UpdateShowInfo(building)
    self.m_ItemList[building.bid]:SetSelected(true)
end

function COrgBuildingUpgradeView.OnClose(self)
    if self.m_DoneTimer then
		Utils.DelTimer(self.m_DoneTimer)
	end
    self:CloseView()
end

return COrgBuildingUpgradeView