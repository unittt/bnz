local CExpRecyclePage = class("CExpRecyclePage", CPageBase)

function CExpRecyclePage.ctor(self, obj)
    CPageBase.ctor(self, obj)
    self.m_TotalExp = 0
end

function CExpRecyclePage.OnInitPage(self)
    self.m_ScrollView = self:NewUI(1, CScrollView)
    self.m_ExpGrid = self:NewUI(2, CGrid)
    self.m_ExpBox = self:NewUI(3, CBox)
    self.m_AllSelSpr = self:NewUI(4, CSprite)
    self.m_ExpL = self:NewUI(5, CLabel)
    self.m_Btn30Box = self:NewUI(6, CBox)
    self.m_Btn50Box = self:NewUI(7, CBox)
    self.m_Btn100Box = self:NewUI(8, CBox)
    self.m_EmptyObj = self:NewUI(9, CObject)
    self.m_InfoObj = self:NewUI(10, CObject)
    self.m_ExpBox:SetActive(false)
    self.m_AllSelSpr:AddUIEvent("click", callback(self, "OnClickSelAll"))

    self.m_SelIdList = nil
    self.m_CostInfo = nil
    self.m_IsFirst = true
    self.m_ItemCnt = 0

    self:RefreshAll()
    self.m_IsFirst = false
end

function CExpRecyclePage.RefreshAll(self)
    self.m_SelIdList = {}
    self:RefreshGrid()
    self:RefreshExp()
end

function CExpRecyclePage.RefreshExp(self)
    self:RefreshTotalExp()
    self:RefreshBtns()
    self:RefreshSelAll()
end

function CExpRecyclePage.RefreshGrid(self)
    local recycleInfos = g_ExpRecycleCtrl:GetAllInfo()
    self.m_ScrollView:ResetPosition()
    local bHasInfo = #recycleInfos > 0
    self.m_EmptyObj:SetActive(not bHasInfo)
    self.m_InfoObj:SetActive(bHasInfo)
    self.m_ItemCnt = 0
    if bHasInfo then
        self.m_ExpGrid:HideAllChilds()
        for i, v in ipairs(recycleInfos) do
            local oBox = self:GetExpBox(i)
            oBox:SetActive(true)
            self:RefreshExpBox(oBox, v)
            self.m_ItemCnt = self.m_ItemCnt + 1
        end
    end
end

function CExpRecyclePage.GetExpBox(self, idx)
    local oBox = self.m_ExpGrid:GetChild(idx)
    if not oBox then
        oBox = self.m_ExpBox:Clone()
        oBox.nameL = oBox:NewUI(1, CLabel)
        oBox.rewardL = oBox:NewUI(2, CLabel)
        oBox.iconSpr = oBox:NewUI(3, CSprite)
        self.m_ExpGrid:AddChild(oBox)
        oBox:AddUIEvent("click", callback(self, "OnClickExpBox"))
        self.m_ExpGrid:AddChild(oBox)
    end
    return oBox
end

function CExpRecyclePage.RefreshExpBox(self, oBox, dInfo)
    oBox.nameL:SetText(dInfo.schedule.name)
    oBox.rewardL:SetText(string.format("%d次经验奖励", dInfo.cnt))
    oBox.iconSpr:SpriteItemShape(dInfo.schedule.icon)
    local bSel = self.m_IsFirst and true or false
    oBox:SetSelected(bSel)
    if bSel then
        table.insert(self.m_SelIdList, dInfo.id)
    end
    oBox.info = dInfo
end

function CExpRecyclePage.RefreshTotalExp(self)
    self.m_TotalExp = g_ExpRecycleCtrl:GetTotalExp(self.m_SelIdList)
    self.m_ExpL:SetText(string.format("[63432c]您昨天错过了这些活动，共有#G%d#n点经验待您找回", self.m_TotalExp))
end

function CExpRecyclePage.RefreshBtns(self)
    self.m_CostInfo = g_ExpRecycleCtrl:GetTotalCost(self.m_SelIdList)
    self:InitBtnBox(self.m_Btn30Box, "free_ratio", 0)
    self:InitBtnBox(self.m_Btn50Box, "gold_ratio", 1)
    self:InitBtnBox(self.m_Btn100Box, "goldcoin_ratio", 2)
end

function CExpRecyclePage.InitBtnBox(self, oBox, sKey, idx)
    local iPercent = g_ExpRecycleCtrl:GetOtherConfig(sKey)
    if not oBox.inited then
        oBox.inited = true
        oBox.expL = oBox:NewUI(1, CLabel)
        oBox.percentL = oBox:NewUI(2, CLabel)
        oBox.costL = oBox:NewUI(3, CLabel)
        oBox:AddUIEvent("click", callback(self, "OnClickBtn", sKey, idx))
        oBox.percentL:SetText(string.format("找回%d%%", iPercent))
    end
    oBox.expL:SetText(self:GetExpText(self.m_TotalExp * iPercent / 100))
    local sKey = string.match(sKey, "^(.+)_")
    local iCost = self.m_CostInfo[sKey]
    if sKey == "free" then
        oBox.costL:SetText("免费")
    else
        oBox.costL:SetText(string.format("%d#cur_%d", iCost or 0, sKey == "gold" and 3 or 2))
    end
end

function CExpRecyclePage.GetExpText(self, iExp)
    local iExp = math.ceil(iExp)
    local sExp = iExp
    if iExp >= 10000 then
        sExp = (iExp/10000) .. "万"
    end
    return string.format("共计%s经验", sExp)
end

function CExpRecyclePage.IsSelectAll(self)
    return self.m_ItemCnt > 0 and #self.m_SelIdList >= self.m_ItemCnt
end

function CExpRecyclePage.RefreshSelAll(self)
    local bAll = self:IsSelectAll()
    self.m_AllSelSpr:SetSelected(bAll)
end

function CExpRecyclePage.OnClickBtn(self, sKey, idx)
    if self.m_TotalExp <= 0 then
        g_NotifyCtrl:FloatMsg("请选择要找回的经验")
        return
    end
    local sText
    local iTotal = g_ExpRecycleCtrl:GetTotalExp(self.m_SelIdList)
    local dCost = self.m_CostInfo
    local iPercent = g_ExpRecycleCtrl:GetOtherConfig(sKey)
    local iGet = math.ceil(0.01*iPercent*iTotal)
    if sKey == "free_ratio" then
        sText = string.format("[63432c]是否免费找回#G%d*%d%%=%d#n点经验？", iTotal, iPercent, iGet)
    elseif sKey == "gold_ratio" then
        sText = string.format("[63432c]是否消耗#G%d#n#cur_3找回#G%d*%d%%=%d#n点经验？", dCost.gold or 0, iTotal, iPercent, iGet)
    elseif sKey == "goldcoin_ratio" then
        sText = string.format("[63432c]是否消耗#G%d#n#cur_2找回#G%d#n点经验？", dCost.goldcoin or 0, iTotal)
    end
    local dConfirm = {
        msg = sText,
        okCallback = function () 
            nethuodong.C2GSRetrieveExp(self.m_SelIdList, g_TimeCtrl:GetTimeS(), idx)
        end,
        color = Color.white,
    }
    g_WindowTipCtrl:SetWindowConfirm(dConfirm)
end

function CExpRecyclePage.OnClickExpBox(self, oBox)
    if oBox.info then
        local bSel = not oBox:GetSelected()
        local id = oBox.info.id
        oBox:SetSelected(bSel)
        if bSel then
            table.insert(self.m_SelIdList, id)
        else
            for i, v in ipairs(self.m_SelIdList) do
                if v == id then
                    table.remove(self.m_SelIdList, i)
                    break
                end
            end
        end
    end
    self:RefreshExp()
end

function CExpRecyclePage.OnClickSelAll(self)
    local bSel = not self:IsSelectAll()
    self.m_SelIdList = {}
    local childList = self.m_ExpGrid:GetChildList()
    for _, v in ipairs(childList) do
        if v.info and bSel then
            table.insert(self.m_SelIdList, v.info.id)
        end
        v:SetSelected(bSel)
    end
    self.m_AllSelSpr:SetSelected(bSel)
    self:RefreshExp()
end

return CExpRecyclePage