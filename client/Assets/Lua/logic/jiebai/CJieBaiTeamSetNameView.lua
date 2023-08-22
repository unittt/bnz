local CJieBaiTeamSetNameView = class("CJieBaiTeamSetNameView", CViewBase)

function CJieBaiTeamSetNameView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiTeamSetNameView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"

end

function CJieBaiTeamSetNameView.OnCreateView(self)

   self.m_CloseBtn = self:NewUI(1, CButton)
   self.m_Input = self:NewUI(2, CInput)
   self.m_Title = self:NewUI(3, CLabel)
   self.m_NeedCount = self:NewUI(4, CLabel)
   self.m_HadCount = self:NewUI(5, CLabel)
   self.m_ConfirmBtn = self:NewUI(6, CSprite)
   self.m_AddBtn = self:NewUI(7, CSprite)
   self.m_Tip = self:NewUI(8, CLabel)
   self.m_FreeTipL = self:NewUI(9, CLabel)

   self:InitContent()

end

function CJieBaiTeamSetNameView.InitContent(self)
    
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirmBtn"))
    self.m_AddBtn:AddUIEvent("click", callback(self, "OnClickAddBtn"))

    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))

    self:RefreshAll()

end
function CJieBaiTeamSetNameView.RefreshAll(self)
    
    local title = g_JieBaiCtrl:GetTitle()
    self.m_Title:SetText(title)
    self.MingHao = g_JieBaiCtrl:GetMingHao(g_AttrCtrl.pid)
    self.m_Input:SetText(self.MingHao)

    self.m_NeedCnt = 0
    local bFree = g_JieBaiCtrl:IsSetNameFree()
    if not bFree then
        self.m_NeedCnt = data.huodongdata.JIEBAI_CONFIG[1].minghao_silver
    end
    self.m_NeedCount:SetCommaNum(self.m_NeedCnt)
    self.m_FreeTipL:SetActive(bFree)

    self.m_CurCnt = g_AttrCtrl.silver
    self.m_HadCount:SetCommaNum(self.m_CurCnt)

    local tip = g_JieBaiCtrl:GetTextTip(1086)
    self.m_Tip:SetText(tip)

end

function CJieBaiTeamSetNameView.OnClickConfirmBtn(self)
    
    if self.m_CurCnt < self.m_NeedCnt then 
        g_NotifyCtrl:FloatMsg(g_JieBaiCtrl:GetTextTip(1012))
        -- CCurrencyView:ShowView(function(oView)
        -- 	oView:SetCurrencyView(define.Currency.Type.Silver)
        -- end)
        g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)
        return
    end 

    local minghao = self.m_Input:GetText()
    if minghao == "" then 
        g_NotifyCtrl:FloatMsg("名号不能为空")
        return
    end 

    local len = string.utfStrlen(minghao)
    if len > 2 then 
        local tip = g_JieBaiCtrl:GetTextTip(1032)
        g_NotifyCtrl:FloatMsg(tip)
        return
    end 

    if minghao == self.MingHao then 
        --local tip = g_JieBaiCtrl:GetTextTip(1032)
        g_NotifyCtrl:FloatMsg("请修改名号")
        return
    end 

    if g_MaskWordCtrl:IsContainMaskWord(minghao) or string.isIllegal(minghao) == false then 
        g_NotifyCtrl:FloatMsg("含有非法字符请重新输入!")
        return
    end 

    g_JieBaiCtrl:C2GSJBSetMingHao(minghao)
    self:OnClose()

end

function CJieBaiTeamSetNameView.OnClickAddBtn(self)
	
	-- CCurrencyView:ShowView(function(oView)
	-- 	oView:SetCurrencyView(define.Currency.Type.Silver)
	-- end)
    g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)

end

function CJieBaiTeamSetNameView.OnAttrEvent(self, oCtrl)

    if oCtrl.m_EventID == define.Attr.Event.Change then
        self:RefreshAll()
    end

end

return CJieBaiTeamSetNameView