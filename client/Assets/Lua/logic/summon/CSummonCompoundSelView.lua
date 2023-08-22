local CSummonCompoundSelView = class("CSummonCompoundSelView", CViewBase)

function CSummonCompoundSelView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Summon/SummonCompoundSelView.prefab", cb)
    --界面设置
    self.m_DepthType = "Dialog"
    -- self.m_GroupName = "SelSummon"
    -- self.m_ExtendClose = "Black"
end

function CSummonCompoundSelView.OnCreateView(self)
    self.m_NearWidget = self:NewUI(1, CWidget)
    self.m_ScrollView = self:NewUI(2, CScrollView)
    self.m_Grid = self:NewUI(3, CGrid)
    self.m_ItemBox = self:NewUI(4, CSummonCompoundItemBox)
    self.m_CloseBtn = self:NewUI(5, CButton)
    self.m_ComfirmBtn = self:NewUI(6, CButton)
    self.m_TitleL = self:NewUI(7, CLabel)
    self:InitContent()
end

function CSummonCompoundSelView.InitContent(self)
    self.m_ItemBox:SetActive(false)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_ComfirmBtn:AddUIEvent("click", callback(self, "OnComfirm"))
    -- self:RefreshSummons()
    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CSummonCompoundSelView.RefreshSummons(self)
    local summonList = g_SummonCtrl:GetCompoundMatList()
    self:RefreshView(summonList, true)
    self.m_TitleL:SetColor(Color.white)
    self.m_TitleL:SetText("[8FF2E2]请选择用于合成的宠物[-]")--[0FFF32]珍品[-]
end

function CSummonCompoundSelView.RefreshSummonByIds(self, ids)
    if not ids or not next(ids) then return end
    self:SetTitleBySummon(ids[1])
    local summonList = g_SummonCtrl:GetSummonByTypeIds(ids)
    self:RefreshView(summonList)
end

function CSummonCompoundSelView.RefreshView(self, summons, bShowEff)
    local bHasSel = false
    local iSelSumm
    if bShowEff then
        local id = self.isRight and g_SummonCtrl.m_LeftCompoundId or g_SummonCtrl.m_RightCompoundId
        if id then
            local dSel = g_SummonCtrl:GetSummon(id)
            iSelSumm = dSel and dSel.typeid
        end
    end
    for i, dSummon in ipairs(summons) do
        local oBox = self:GetItemBox(i)
        oBox:SetActive(true)
        oBox:SetInfo(dSummon)
        if iSelSumm and SummonDataTool.GetComposeXiyou(iSelSumm, dSummon.typeid) then
            local oEff = oBox:AddEffect("Rect2")
			oBox.m_IgnoreCheckEffect = true
            if oEff then
                oEff:SetLocalScale(Vector3(0.95,0.98,1))
            end
        else
            oBox:DelEffect("Rect2")
        end
        if oBox.m_IsFight or dSummon.bind_ride ~= 0 then
            oBox:SetGroup(0)
            oBox.m_UIToggle.activeSprite = nil
        elseif not bHasSel then
            self:OnClickSummon(oBox)
            oBox:SetSelected(true)
            bHasSel = true
        end
    end
end

function CSummonCompoundSelView.GetItemBox(self, idx)
    local oBox = self.m_Grid:GetChild(idx)
    if not oBox then
        oBox = self.m_ItemBox:Clone()
        oBox:AddUIEvent("click", callback(self, "OnClickSummon", oBox))
        self.m_Grid:AddChild(oBox)
        oBox:SetGroup(self.m_Grid:GetInstanceID())
    end
    return oBox
end

function CSummonCompoundSelView.SetTitleBySummon(self, summonId)
    if not summonId then
        return
    end
    local dSummon = SummonDataTool.GetSummonInfo(summonId)
    local dType = SummonDataTool.GetTypeInfo(dSummon.type)
    self.m_TitleL:SetText(string.format("请选择你要用于合成的%s", dType.name))
end

function CSummonCompoundSelView.CheckSummonState(self, dSummon)
    if not dSummon then return false end
    if dSummon.id == g_SummonCtrl.m_FightId then
        g_NotifyCtrl:FloatMsg(dSummon.name.."处于出战状态，调整为休息才能进行合成")
        return false
    elseif dSummon.bind_ride and dSummon.bind_ride ~= 0 then
        local sName = g_HorseCtrl:GetRideName(dSummon.bind_ride)
        g_NotifyCtrl:FloatMsg(string.format("%s被%s统御中，无法用于宠物合成", dSummon.name, sName))
        return false
    end
    return true
end

function CSummonCompoundSelView.OnClose(self)
    self:CloseView()
end

function CSummonCompoundSelView.OnComfirm(self)
    local dInfo = self.m_SelSummon
    if dInfo then
        g_SummonCtrl:SelCompoundMat(dInfo, self.isRight)
        self:OnClose()
    else
        -- local oBox = self.m_Grid:GetChild(1)
        -- if oBox and oBox.m_IsFight then
        --     g_NotifyCtrl:FloatMsg(oBox.m_Info.name.."处于出战状态，调整为休息才能进行合成")
        --     return
        -- else
        g_NotifyCtrl:FloatMsg("没有可以合成的宠物")
        return
    end
end

function CSummonCompoundSelView.OnClickSummon(self, oBox)
    local dInfo = oBox.m_Info
    if not dInfo then return end
    if self:CheckSummonState(dInfo) then
        self.m_SelSummon = dInfo
    end
end

return CSummonCompoundSelView