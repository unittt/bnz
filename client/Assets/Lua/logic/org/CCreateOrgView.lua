local CCreateOrgView = class("CCreateOrgView", CViewBase)

CCreateOrgView.ORG_NAME_MIN_CHAR = 3 * 2    -- 最少 3 个汉字
CCreateOrgView.ORG_AIM_MIN_CHAR  = 1 * 2    -- 最少 1 个汉字

function CCreateOrgView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/CreateOrgView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"
end

function CCreateOrgView.OnCreateView(self)
    self.m_CloseBtn             = self:NewUI(1, CButton)
    self.m_CreateOrgBtn         = self:NewUI(2, CButton)
    self.m_OrgNameInput         = self:NewUI(3, CInput)
    self.m_OrgAimInput          = self:NewUI(4, CInput)
    self.m_CreateConditionLabel = self:NewUI(5, CLabel)
    self.m_FeeLabel             = self:NewUI(6, CLabel)
    self.m_CoverOrgNameLabel    = self:NewUI(7, CLabel)
    self.m_CoverOrgAimLabel     = self:NewUI(8, CLabel)
    self:InitContent()
end

function CCreateOrgView.InitContent(self)
    local hours = g_OrgCtrl:ConvertSecondsStrV2(data.orgdata.OTHERS[1].create_respond_time)
    local numRespond = data.orgdata.OTHERS[1].create_respond_people
    local sText = string.format("[63432C]%s内，有[-][A64E00]%d[-][63432C]名玩家响应才能创建成功[-]", hours, numRespond)
    self.m_CreateConditionLabel:SetText(sText)--hours .. "内，有" .. numRespond .. "名玩家响应才能创建成功")
    local yuanbao = data.orgdata.OTHERS[1].create_yuanbao
    self.m_FeeLabel:SetText(tostring(yuanbao))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
    self.m_CreateOrgBtn:AddUIEvent("click", callback(self, "OnCreateOrg"))
    self.m_OrgNameInput:AddUIEvent("change", callback(self, "OnNameTextChange"))
    self.m_OrgAimInput:AddUIEvent("change", callback(self, "OnAimTextChange"))
    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
    self:RecoverLastEditInfo()
end

function CCreateOrgView.OnNameTextChange(self)
    self.m_CoverOrgNameLabel:SetColor(Color.clear)
    self.m_OrgNameInput.activeTextColor = Color.brown
end

function CCreateOrgView.OnAimTextChange(self)
    self.m_CoverOrgAimLabel:SetColor(Color.clear)
    self.m_OrgAimInput.activeTextColor = Color.brown
end

function CCreateOrgView.OnCreateOrg(self)
    if g_OrgCtrl:HasOrg(true) then
        return
    end

    -- 判断元宝
    local yuanbao = data.orgdata.OTHERS[1].create_yuanbao
    -- table.print(g_AttrCtrl)
    if g_AttrCtrl.goldcoin < yuanbao then
        -- printc("元宝不足，当前只有" .. g_AttrCtrl.goldcoin .. "个，无法创建帮派",data.orgdata.OTHERS[1].create_yuanbao)
        -- g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1013].content)
        -- local windowTipInfo = {
        --     msg             = "你的元宝不够哦,是否充值",
        --     okCallback      = function () 
        --                         local oView = CNpcShopMainView:ShowView(function (oView )
        --                         oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
        --                         end )  
        --                      end,
        --     cancelCallback  = function ()
        --                         self:CloseView()
        --                       end,
        --     okStr           =  "去充值",
        --     cancelStr       =  "以后再说",
        -- }   
        -- g_WindowTipCtrl:SetWindowConfirm(windowTipInfo)
        g_ShopCtrl:ShowChargeComfirm(callback(self, "CloseView"))
    return
    end

    -- 判断帮派名长度
    local name = self.m_OrgNameInput:GetText()
    local lenName = string.len(name)
    -- printc("创建帮派界面：点击创建帮派，帮派名 = \"" .. name .. "\"，长度 = " .. lenName)
    if lenName == 0 then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1014].content)
        return
    end
    if lenName < CCreateOrgView.ORG_NAME_MIN_CHAR then
        local str = string.gsub(data.orgdata.TEXT[1015].content, "#zszifu", CCreateOrgView.ORG_NAME_MIN_CHAR)
        g_NotifyCtrl:FloatMsg(str)
        return
    end

    -- 判断帮派宗旨长度
    local aim = self.m_OrgAimInput:GetText()
    local lenAim = string.len(aim)
    -- printc("创建帮派界面：点击创建帮派，帮派宗旨 = \"" .. aim .. "\"，长度 = " .. lenAim)
    if lenAim == 0 then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1017].content)
        return
    end
    if lenAim < CCreateOrgView.ORG_AIM_MIN_CHAR then
        local str = string.gsub(data.orgdata.TEXT[1071].content, "#zszifu", CCreateOrgView.ORG_AIM_MIN_CHAR)
        g_NotifyCtrl:FloatMsg(str)
        return
    end

    if string.isIllegal(name) == false then
         g_NotifyCtrl:FloatMsg("帮派名含有非法字符！")
         return true
    end
    -- 判断帮派名敏感词
    if g_OrgCtrl:ContainsMaskWordAndHighlight(name, self.m_OrgNameInput , self.m_CoverOrgNameLabel, data.orgdata.TEXT[1016].content) then
        return
    end
    -- 判断帮派宗旨敏感词
    if g_OrgCtrl:ContainsMaskWordAndHighlight(aim, self.m_OrgAimInput , self.m_CoverOrgAimLabel, data.orgdata.TEXT[1018].content) then
        return
    end

    -- 允许创建
    -- printc("发送 C2GSCreateOrg")
    netorg.C2GSCreateOrg(name, aim)
    self:CloseView()
end

function CCreateOrgView.StartReplaceTimer(self)
    local updateFunc = function()
        if Utils.IsNil(self) then
            return false
        end

        -- printc("帮派名/宗旨替换敏感词")
        local orgName = self.m_OrgNameInput:GetText()
        local replacedOrgName = g_MaskWordCtrl:ReplaceMaskWord(orgName)
        self.m_OrgNameInput:SetText(replacedOrgName)

        local aim = self.m_OrgAimInput:GetText()
        local replacedAim = g_MaskWordCtrl:ReplaceMaskWord(aim)
        self.m_OrgAimInput:SetText(replacedAim)
        return true
    end

    local replacedFrequency = data.orgdata.OTHERS[1].mask_word_replace_rate
    -- self.m_Timer = Utils.AddTimer(updateFunc, replacedFrequency, 0)     -- 每若干秒替换敏感词
end

function CCreateOrgView.CloseView(self)
    if self.m_OrgNameInput ~= nil and self.m_OrgAimInput ~= nil then
        local tempName = self.m_OrgNameInput:GetText()
        local tempAim = self.m_OrgAimInput:GetText()
        g_OrgCtrl:SaveCreateOrgTempInfo(tempName, tempAim)
    end
    g_ViewCtrl:CloseView(self)
end

function CCreateOrgView.OnOrgEvent(self, callbackBase)
    local eventID = callbackBase.m_EventID
    if eventID == define.Org.Event.GetOrgJoinStatus then
        g_OrgCtrl:OnOrgJoinStatus(self, callbackBase)
    end
end

function CCreateOrgView.RecoverLastEditInfo(self)
    local tempName, tempAim = g_OrgCtrl:GetCreateOrgTempInfo()
    self.m_OrgNameInput:SetText(tempName)
    self.m_OrgAimInput:SetText(tempAim)
    -- printc("创建帮派界面：恢复临时保存的帮派名称和宗旨，tempName = " .. tempName .. ", 宗旨 = " .. tempAim)
end

return CCreateOrgView