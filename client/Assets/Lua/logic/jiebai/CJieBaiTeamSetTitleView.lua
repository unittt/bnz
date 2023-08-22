local CJieBaiTeamSetTitleView = class("CJieBaiTeamSetTitleView", CViewBase)

function CJieBaiTeamSetTitleView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiTeamSetTitleView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"

end

function CJieBaiTeamSetTitleView.OnCreateView(self)

   self.m_CloseBtn = self:NewUI(1, CButton)
   self.m_Input = self:NewUI(2, CInput)
   self.m_MingHao = self:NewUI(3, CLabel)
   self.m_NeedCount = self:NewUI(4, CLabel)
   self.m_HadCount = self:NewUI(5, CLabel)
   self.m_ConfirmBtn = self:NewUI(7, CSprite)
   self.m_Tip = self:NewUI(8, CLabel)

   self:InitContent()

end

function CJieBaiTeamSetTitleView.InitContent(self)
    
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirmBtn"))

    self:RefreshAll()

end

function CJieBaiTeamSetTitleView.RefreshAll(self)
    
    self.m_Title = g_JieBaiCtrl:GetTitle()
    self.m_Input:SetText(self.m_Title)
    local minghao = g_JieBaiCtrl:GetMingHao(g_AttrCtrl.pid)
    self.m_MingHao:SetText(minghao)

    self.m_NeedJieYi = data.huodongdata.JIEBAI_CONFIG[1].title_jieyi
    self.m_CurJieYi = g_JieBaiCtrl:GetJieYiValue()
    local cnt = g_ItemCtrl:GetBagItemAmountBySid(10198)
    if cnt > 0 then 
        self.m_NeedCount:SetText(0)
    else
        self.m_NeedCount:SetText(self.m_NeedJieYi)
    end 
    self.m_HadCount:SetText(self.m_CurJieYi)

    local tip = g_JieBaiCtrl:GetTextTip(1085)
    self.m_Tip:SetText(tip)

end


function CJieBaiTeamSetTitleView.OnClickConfirmBtn(self)

    local cnt = g_ItemCtrl:GetBagItemAmountBySid(10198)

    if (self.m_CurJieYi < self.m_NeedJieYi) and cnt <= 0 then 
        local tip = g_JieBaiCtrl:GetTextTip(1041)
        g_NotifyCtrl:FloatMsg(tip)
        return
    end 
    
    local title = self.m_Input:GetText()
    if title == "" then 
        g_NotifyCtrl:FloatMsg("称号不能为空")
        return
    end 

    local len = string.utfStrlen(title)
    if len > 4 then 
        local tip = g_JieBaiCtrl:GetTextTip(1032)
        g_NotifyCtrl:FloatMsg(tip)
        return
    end 

    if title == self.m_Title then 
        --local tip = g_JieBaiCtrl:GetTextTip(1032)
        g_NotifyCtrl:FloatMsg("请修改称号")
        return
    end 

    if g_MaskWordCtrl:IsContainMaskWord(title) or string.isIllegal(title) == false then 
        g_NotifyCtrl:FloatMsg("含有非法字符请重新输入!")
        return
    end 

    g_JieBaiCtrl:C2GSJBSetTitle(title)
    self:OnClose()

end

return CJieBaiTeamSetTitleView


