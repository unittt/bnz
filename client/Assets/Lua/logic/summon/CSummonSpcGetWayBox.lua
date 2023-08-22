local CSummonSpcGetWayBox = class("CSummonSpcGetWayBox", CBox)

function CSummonSpcGetWayBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_InitCompose = false
    self:InitContent()
end

function CSummonSpcGetWayBox.InitContent(self)
    self.m_EqualWg = self:NewUI(1, CWidget)
    self.m_FormulaTb = self:NewUI(2, CTable)
    self.m_SummBox = self:NewUI(3, CBox)
    self.m_AddWg = self:NewUI(4, CWidget)
    self.m_CostBox = self:NewUI(5, CBox)
    self.m_OrWg = self:NewUI(6, CWidget)
    self.m_GotoBtn = self:NewUI(7, CButton)
    self:InitFormulaWgs()
    self.m_GotoBtn:AddUIEvent("click", callback(self, "OnClickGoto"))
end

function CSummonSpcGetWayBox.InitFormulaWgs(self)
    self.m_FormulaDict = {
        add = self.m_AddWg,
        item = self.m_CostBox,
        summ = self.m_SummBox,
        equal = self.m_EqualWg,
        other = self.m_OrWg,
    }
    for k, v in pairs(self.m_FormulaDict) do
        v:SetActive(false)
        self.m_FormulaTb[k] = {}
    end
    self.m_FormulaTb.m_UITable.padding = Vector2.New(6, 0)
    self.m_FormulaTb:SetActive(true)
end

function CSummonSpcGetWayBox.SetData(self, iSummonId)
    self.m_SummonId = iSummonId
    local excList = SummonDataTool.GetSpcExchanges(iSummonId)
    local bCompose = false
    self.m_IsLen = false
    local dConfig = excList[1]
    if 0 ~= dConfig.sid1 and 0 ~= dConfig.sid2 then
        self:RefreshCompose(dConfig)
        self.m_IsLen = true
    else
        self:RefreshExchange(excList)
        if #excList > 1 then
            self.m_IsLen = true
        end
    end
    self:RefreshBtn(bCompose)
end

function CSummonSpcGetWayBox.InitComposeTb(self)
    local list = {"sum", "add", "sum","equal","sum"}--, "add", "item"
    for i, v in ipairs(list) do
        local obj = objDict[v]:Clone()
        if v == "sum" then
            self:InitSummBox(obj)
        elseif v == "item" then
            self:InitItemBox(obj)
        end
        obj:SetActive(true)
        self.m_FormulaTb:AddChild(obj)
    end
end

function CSummonSpcGetWayBox.RefreshCompose(self, dConfig)
    local dSumm1 = SummonDataTool.GetSummonInfo(dConfig.sid1)
    local dSumm2 = SummonDataTool.GetSummonInfo(dConfig.sid2)
    local dSumm = SummonDataTool.GetSummonInfo(dConfig.sid)
    local formulaData = {
        {wg = "summ", data = dSumm1},
        {wg = "add"},
        {wg = "summ", data = dSumm2},
        {wg = "equal"},
        {wg = "summ", data = dSumm},
    }
    self:RefreshFormula(formulaData)
end

function CSummonSpcGetWayBox.RefreshExchange(self, excList)
    local formulaData = {}
    local iCnt = #excList
    for i, dConfig in ipairs(excList) do
        local dCost = dConfig.cost[1]
        table.insert(formulaData, {wg = "item", data = dCost})
        if i < iCnt then
            table.insert(formulaData, {wg = "other"})
        else
            local dSumm = SummonDataTool.GetSummonInfo(dConfig.sid)
            table.insert(formulaData, {wg = "equal"})
            table.insert(formulaData, {wg = "summ", data = dSumm})
        end
    end
    self:RefreshFormula(formulaData)
end

function CSummonSpcGetWayBox.RefreshFormula(self, formulaData)
    local oTb = self.m_FormulaTb
    local wgIdxDict = {}
    local idx = 0
    local iCnt = 0
    for k in pairs(self.m_FormulaDict) do
        local list = self.m_FormulaTb[k]
        for i, o in ipairs(list) do
            o:SetActive(false)
        end
    end
    for i, v in ipairs(formulaData) do
        local sWg = v.wg
        idx = (wgIdxDict[sWg] or 0) + 1
        local oWg = self:GetTableWidget(sWg, idx)
        oWg:SetSiblingIndex(i)
        if sWg == "summ" then
            self:SetSummBoxData(oWg, v.data)
        elseif sWg == "item" then
            self:SetItemBoxData(oWg, v.data)
        end
        oWg:SetActive(true)
        wgIdxDict[sWg] = idx
    end
    oTb:Reposition()
    if #formulaData >= 5 then
        self.m_FormulaTb:SetLocalPos(Vector3.New(-150, 0,0))
    else
        self.m_FormulaTb:SetLocalPos(Vector3.New(-13, 0,0))
    end
end

function CSummonSpcGetWayBox.GetTableWidget(self, sWidget, idx)
    if not self.m_FormulaTb[sWidget] then
        self.m_FormulaTb[sWidget] = {}
    end
    local oWg = self.m_FormulaTb[sWidget][idx]
    if not oWg then
        oWg = self.m_FormulaDict[sWidget]:Clone()
        if sWidget == "summ" then
            self:InitSummBox(oWg)
        elseif sWidget == "item" then
            self:InitItemBox(oWg)
        end
        self.m_FormulaTb:AddChild(oWg)
        self.m_AddWgCnt = (self.m_AddWgCnt or 0) + 1
        table.insert(self.m_FormulaTb[sWidget], oWg)
    end
    return oWg
end

function CSummonSpcGetWayBox.InitSummBox(self, oBox)
    oBox.iconSpr = oBox:NewUI(3, CSprite)
    oBox:AddUIEvent("click", callback(self, "OnClickSummon", oBox))
end

function CSummonSpcGetWayBox.InitItemBox(self, oBox)
    oBox.qualitySpr = oBox:NewUI(2, CSprite)
    oBox.iconSpr = oBox:NewUI(3, CSprite)
    oBox.cntL = oBox:NewUI(4, CLabel)
    oBox:AddUIEvent("click", callback(self, "OnClickItem", oBox))
end

function CSummonSpcGetWayBox.SetSummBoxData(self, oBox, dInfo)
    oBox.iconSpr:SpriteAvatar(dInfo.shape)
    oBox.id = dInfo.id
end

function CSummonSpcGetWayBox.SetItemBoxData(self, oBox, dInfo)
    local dItem = DataTools.GetItemData(dInfo.sid)
    oBox.iconSpr:SpriteItemShape(dItem.icon)
    oBox.qualitySpr:SetItemQuality(dItem.quality)
    local iOwn = g_ItemCtrl:GetBagItemAmountBySid(dInfo.sid)
    if iOwn >= dInfo.num then
        oBox.cntL:SetText("[b][0fff32]"..dInfo.num)
        oBox.cntL:SetEffectColor(Color.RGBAToColor("003C41"))
    else
        oBox.cntL:SetText("[b][ffb398]"..dInfo.num)
        oBox.cntL:SetEffectColor(Color.RGBAToColor("cd0000"))
    end
    oBox.id = dItem.id
end

function CSummonSpcGetWayBox.RefreshBtn(self, bCompose)
    -- if bCompose then
    --     self.m_GotoBtn:SetLocalPos(Vector3.New(-100, 0, 0))
    -- else
    self.m_GotoBtn:SetLocalPos(Vector3.New(318, 2, 0))
    -- end
end

function CSummonSpcGetWayBox.OnClickSummon(self, oBox)
    if not oBox.id or oBox.id == self.m_SummonId then return end
    local dInfo = SummonDataTool.GetSummonInfo(oBox.id)
    g_SummonCtrl:OnEvent(define.Summon.Event.SelBookSummon, dInfo)
end

function CSummonSpcGetWayBox.OnClickItem(self, oBox)
    if not oBox.id then return end
    g_WindowTipCtrl:SetWindowGainItemTip(oBox.id)
end

function CSummonSpcGetWayBox.OnClickGoto(self)
    if not self.m_SummonId then return end
    g_SummonCtrl:GotoExchangeNpc(self.m_SummonId)
    -- if g_WarCtrl:IsWar() then
    --     g_NotifyCtrl:FloatMsg("请脱离战斗后再进行操作")
    --    return
    -- end
    -- local iNpc = g_SummonCtrl:GetExchangeNpcId(self.m_SummonId)
    -- if iNpc then
    --     g_MapTouchCtrl:WalkToGlobalNpc(iNpc)
    --     CSummonMainView:CloseView()        
    -- end
end

return CSummonSpcGetWayBox