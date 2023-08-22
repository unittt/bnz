local CSummonListBox = class("CSummonListBox", CBox)

function CSummonListBox.ctor(self, obj)
    CBox.ctor(self, obj)

    self.m_MaxOwn = g_SummonCtrl.m_CurSummonBoxCnt + g_SummonCtrl.m_ExtSize or 0
    self.m_MaxTotal = g_SummonCtrl.m_SummonMax
    self.m_FightId = nil
    self.m_SummonBoxDict = {}
    self.m_CurSummonId = nil
    self.m_IsJumpShop = false
    self:InitContent()
end

function CSummonListBox.InitContent(self)
    self.m_Grid = self:NewUI(1, CGrid)
    self.m_SummonItemBox = self:NewUI(2, CSummonItemBox)
    self.m_ScrollView = self:NewUI(3, CScrollView)
    self.m_SummonItemBox:SetActive(false)
end

function CSummonListBox.SetSelSummonId(self, id)
    if not id then return end
    self:UnSelectCurSummon()
    self:SelectSummon(id)
    self.m_ScrollView:ResetPosition()
end

function CSummonListBox.SelectSummon(self, id)
    self.m_CurSummonId = id
    local oBox = self.m_SummonBoxDict[id]
    if oBox then
        oBox.m_SelSpr:SetActive(true)
        oBox:ShowRed(false)
    end
end

function CSummonListBox.UnSelectCurSummon(self)
    local iCur = self.m_CurSummonId
    if iCur then
        local oBox = self.m_SummonBoxDict[iCur]
        if oBox then
            oBox.m_SelSpr:SetActive(false)
        end
    end
end

-- 所有宠物
function CSummonListBox.RefreshSummons(self)
    local summonList = g_SummonCtrl.m_SummonsSort
    self:UnSelectCurSummon()
    self:SetSummonListInfo(summonList)
    local iSummonCnt = #summonList
    if iSummonCnt < self.m_MaxTotal then
        local iExtSize = g_SummonCtrl.m_ExtSize or 0
        self:RefreshExtSize(iExtSize)
    end
    self.m_IsJumpShop = true
    self.m_Grid:Reposition()
end

-- 根据指定宠物信息刷新
function CSummonListBox.RefreshSummonInfos(self, summonList)
    local iSummonCnt = summonList and #summonList or 0
    if iSummonCnt <= 0 then return end
    self:UnSelectCurSummon()
    self:SetSummonListInfo(summonList)
    local iExtSize = g_SummonCtrl.m_ExtSize or 0
    self.m_MaxTotal = iExtSize + g_SummonCtrl.m_CurSummonBoxCnt
    if iSummonCnt < self.m_MaxTotal then
        self:RefreshExtSize(iExtSize, iSummonCnt)
    end
    self.m_IsJumpShop = false
    self.m_Grid:Reposition()
end

function CSummonListBox.SetSummonListInfo(self, summonList)
    self.m_FightId = g_SummonCtrl.m_FightId
    for i, v in ipairs(summonList) do
        local info = self:GetBoxInfo(v)
        local oBox = self.m_Grid:GetChild(i)
        if not oBox then
            oBox = self:CreateSummonBox()
        end
        oBox:SetInfo(info)
        oBox:SetActive(true)
        self.m_SummonBoxDict[info.id] = oBox
    end
    self:SelectSummon(g_SummonCtrl:GetCurSelSummon())
end

function CSummonListBox.RefreshExtSize(self, iExtSize, iSummonCnt)
    iSummonCnt = iSummonCnt or #g_SummonCtrl.m_SummonsSort
    local iDefaultMax = g_SummonCtrl.m_CurSummonBoxCnt
    self.m_MaxOwn = iDefaultMax + iExtSize
    for i = iSummonCnt +1, self.m_MaxTotal do
        local oBox = self.m_Grid:GetChild(i)
        if not oBox then
            oBox = self:CreateSummonBox()
        end
        if i > self.m_MaxOwn then
            oBox:SetLock(i - iDefaultMax)
        else
            oBox:SetInfo(nil)
        end
    end
end

function CSummonListBox.GetBoxInfo(self, dSummon)
    local info = {}
    info.fight = dSummon.id == self.m_FightId
    info.bind = dSummon.key == 1
    info.shape = dSummon.model_info.shape
    info.grade = dSummon.grade
    info.type = dSummon.type
    info.id = dSummon.id
    info.rare = SummonDataTool.IsRare(dSummon)
    info.traceno = tostring(dSummon.traceno)
    return info
end

function CSummonListBox.CreateSummonBox(self)
    local oBox = self.m_SummonItemBox:Clone()
    oBox:AddUIEvent("click", callback(self, "OnClickSummon", oBox))
    oBox:SetGroup(self.m_Grid:GetInstanceID())
    oBox:SetActive(true)
    self.m_Grid:AddChild(oBox)
    return oBox
end

function CSummonListBox.SetSummonBoxInfo(self, info)
    if info then
        local dNewInfo = self:GetBoxInfo(info)
        local oBox = self.m_SummonBoxDict[info.id]
        if oBox then
            oBox:SetInfo(dNewInfo)
        end
    end
end

function CSummonListBox.RefreshFight(self)
    if self.m_FightId and self.m_FightId ~= 0 then
        local oCurFight = self.m_SummonBoxDict[self.m_FightId]
        if oCurFight then
            oCurFight:SetFight(false)
        end
    end
    local summonId = g_SummonCtrl.m_FightId
    if summonId ~= 0 then
        local oBox = self.m_SummonBoxDict[summonId]
        if oBox then
            oBox:SetFight(true)
        end
    end
    self.m_FightId = summonId
end

function CSummonListBox.HandleJumpShop(self)
    if not self.m_IsJumpShop then return end
    local iGrade = SummonDataTool.GetCurStoreGrade()
    CSummonStoreView:ShowView(function(oView)
        oView:SetSelectSummon(nil, iGrade)
    end)
end

function CSummonListBox.ChangeSummonShow(self, summonId)
    self:SelectSummon(summonId)
    g_SummonCtrl:ChangeSummonShow(summonId)
end

function CSummonListBox.OnClickSummon(self, oBox)
    if oBox:GetLockIdx() then
        self:OnClickLockBox(oBox)
        return
    end
    local summonId = oBox.m_Id
    if not summonId then
        self:HandleJumpShop()
        return
    elseif summonId == self.m_CurSummonId then
        return
    end
    self:UnSelectCurSummon()
    self:ChangeSummonShow(summonId)
end

function CSummonListBox.OnClickLockBox(self, oBox)
    local iLock = oBox:GetLockIdx()
    if iLock then
        local dCost = data.globaldata.SUMMONCK[1].extend_cost
        if not dCost[iLock] then
            return
        end
        local itemId = 11186
        local iCnt = g_ItemCtrl:GetBagItemAmountBySid(itemId)
        local iNeed = dCost[iLock]
        if iCnt >= iNeed then
            local dItem = DataTools.GetItemData(itemId, "OTHER")
            local args = {
                title = "宠物格子开启",
                msg = string.format("您要消耗%d个%s来扩充宠物栏吗？", iNeed, dItem.name),
                okCallback = function()
                    netsummon.C2GSExtendSummonSize()
                end,
                items = {
                    {sid = itemId, count = iCnt, amount = iNeed},
                }
            }
            g_WindowTipCtrl:ShowCosItemConfirmWindow(args)
        else
            local t = {
                sid = itemId,
                count = iCnt,
                amount = iNeed,
            }
            g_QuickGetCtrl:CurrLackItemInfo({t},{},nil,function()
                netsummon.C2GSExtendSummonSize(1)
            end)
        end
    end
end

return CSummonListBox