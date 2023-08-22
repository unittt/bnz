CWelfareEightLoginPart = class("CWelfareEightLoginPart", CPageBase)

function CWelfareEightLoginPart.ctor(self, cb)
    CPageBase.ctor(self,cb)

    self.m_TipSpr = self:NewUI(1, CSprite)
    self.m_DesSpr = self:NewUI(2, CSprite)
    self.m_PowSpr = self:NewUI(3, CSprite)
    self.m_EightScrollView = self:NewUI(4, CScrollView)
    self.m_EightGrid = self:NewUI(5, CGrid)
    self.m_EightBoxClone = self:NewUI(6, CBox)
    self.m_PrizeBox = self:NewUI(7, CBox)
    self.m_PrizeDescSp1 = self.m_PrizeBox:NewUI(1, CSprite)
    self.m_PrizeDescSp2 = self.m_PrizeBox:NewUI(2, CSprite)
    self.m_PrizeDescSp3 = self.m_PrizeBox:NewUI(3, CSprite)
    self.m_PrizeScrollView = self.m_PrizeBox:NewUI(4, CScrollView)
    self.m_PrizeGrid = self.m_PrizeBox:NewUI(5, CGrid)
    self.m_PrizeBoxClone = self.m_PrizeBox:NewUI(6, CBox)
    self.m_PrizeDescLbl = self.m_PrizeBox:NewUI(7, CLabel)
    self.m_PrizeHasGetSp = self.m_PrizeBox:NewUI(8, CSprite)
    self.m_PrizeGetBtn = self.m_PrizeBox:NewUI(9, CButton)
    self.m_ModelBox = self:NewUI(8, CBox)
    self.m_ActorTexture = self:NewUI(9, CActorTexture)
    self.m_DayLbl = self:NewUI(10, CLabel)

    local function init(obj, idx)
        local oBox = CBox.New(obj)
        return oBox
    end
    self.m_EightGrid:InitChild(init)

    self.m_EightList = {1, 2, 3, 4, 5, 6, 7, 8}
    self.m_SelectBottomIdx = self:GetFirstSelectIndex()

    g_GuideCtrl:AddGuideUI("eightlogin_get_btn", self.m_PrizeGetBtn)

   self:InitContent()
end

function CWelfareEightLoginPart.InitContent(self)
    self.m_EightBoxClone:SetActive(false)
    self.m_PrizeBoxClone:SetActive(false)

    self.m_PrizeGetBtn:AddUIEvent("click", callback(self, "OnClickPrizeGetBtn"))
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

    self:RefreshUI()
end

function CWelfareEightLoginPart.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID ==  define.WelFare.Event.UpdataColorLamp then
        self:RefreshUI()
    end
end

function CWelfareEightLoginPart.RefreshUI(self)
    self:RefreshTitleMark()
    self:SetEightList()
    self:OnClickEightBox(self.m_SelectBottomIdx)
end

function CWelfareEightLoginPart.GetFirstSelectIndex(self)
    for i = 1, 8 do
        if g_WelfareCtrl.m_ColorfulData then
            for _,v in ipairs(g_WelfareCtrl.m_ColorfulData) do
                if "login_gift_"..i ==v.key and v.val == 1 then --可以领取
                    return i
                end                
            end
        end
    end
    return 1
end

function CWelfareEightLoginPart.RefreshTitleMark(self)
    if not next (g_WelfareCtrl.m_ColorfulData) then
        return
    end
    local index = 0
    local len = table.count(g_WelfareCtrl.m_ColorfulData)
    for k,v in pairs(g_WelfareCtrl.m_ColorfulData) do
        if v.val == 1 or v.val == 2 then
            if tonumber(string.sub(v.key,string.len(v.key),string.len(v.key)))> index then
                local temp  = tonumber(string.sub(v.key,string.len(v.key),string.len(v.key)))
                if temp>index then
                    index = temp
                end
            end
        end
    end
    local YoukaReward = table.copy(data.welfaredata.LOGIN)
    local RewardListDic = table.copy(data.rewarddata.WELFARE)
    local offsetX = 90
    local offsetY = 240
    if index == 1 then
        self.m_TipSpr:SetLocalPos(Vector3.New(-355+offsetX, 18+offsetY, 0))
        self.m_DesSpr:SetLocalPos(Vector3.New(-22.7+offsetX, -24+offsetY, 0))
        self.m_PowSpr:SetLocalPos(Vector3.New(181.7+offsetX, -26+offsetY, 0))
    elseif index == 2 then
        self.m_TipSpr:SetLocalPos(Vector3.New(-355+offsetX, 11.4+offsetY, 0))
        self.m_DesSpr:SetLocalPos(Vector3.New(-90.1+offsetX, -24+offsetY, 0))
        self.m_PowSpr:SetLocalPos(Vector3.New(182+offsetX, -26+offsetY, 0))
    else 
        self.m_TipSpr:SetLocalPos(Vector3.New(-355+offsetX, 11+offsetY, 0))
        self.m_DesSpr:SetLocalPos(Vector3.New(-47.1+offsetX, -24+offsetY, 0))
        self.m_PowSpr:SetLocalPos(Vector3.New(153.2+offsetX, -26+offsetY, 0))
    end

    self.m_TipSpr:SetSpriteName(YoukaReward["login_gift_"..index].daydes)
    self.m_DesSpr:SetSpriteName(YoukaReward["login_gift_"..index].rewarddes)
    self.m_PowSpr:SetSpriteName(YoukaReward["login_gift_"..index].rewardname)
    
    self.m_DesSpr:MakePixelPerfect()
    local w,h = self.m_DesSpr:GetSize()
    self.m_DesSpr:SetSize(w,40)

    self.m_PowSpr:MakePixelPerfect()
    w,h = self.m_PowSpr:GetSize()
    self.m_PowSpr:SetSize(w,40)

    self.m_TipSpr:MakePixelPerfect()
    w,h = self.m_TipSpr:GetSize()
    self.m_TipSpr:SetSize(w,40)
end

function CWelfareEightLoginPart.RefreshBottomContent(self, oData)
    self.m_SelectBottomIdx = oData
    self.m_DayLbl:SetText("第"..oData.."天")
    self.m_PrizeDescLbl:SetText("每日0点可领取当天奖励")
    local oConfig = data.welfaredata.LOGIN
    local oPrizeList = g_GuideHelpCtrl:GetRewardList("WELFARE", oConfig["login_gift_"..oData].gift)
    if oPrizeList[1].type == 1 then
        self.m_ModelBox:SetActive(false)
        self.m_PrizeDescSp1:SetActive(true)
        self.m_PrizeBox:SetLocalPos(Vector3.New(72, -142, 0))
        self.m_PrizeDescSp3:SetLocalPos(Vector3.New(1, 80.2, 0))
    elseif oPrizeList[1].type == 2 then
        self.m_ModelBox:SetActive(true)
        self.m_PrizeDescSp1:SetActive(false)
        self.m_PrizeBox:SetLocalPos(Vector3.New(192, -116, 0))
        self.m_PrizeDescSp3:SetLocalPos(Vector3.New(32, 80.2, 0))
        local oShape = oPrizeList[1].partner.shape
        local model_info = {}
        model_info.shape = data.modeldata.CONFIG[oShape].model
        model_info.rendertexSize = 1
        self.m_ActorTexture:ChangeShape(model_info, function () end)
    elseif oPrizeList[1].type == 3 then
        self.m_ModelBox:SetActive(true)
        self.m_PrizeDescSp1:SetActive(false)
        self.m_PrizeBox:SetLocalPos(Vector3.New(192, -116, 0))
        self.m_PrizeDescSp3:SetLocalPos(Vector3.New(32, 80.2, 0))
        local oShape = oPrizeList[1].ride.shape
        local model_info = {}
        model_info.shape = data.modeldata.CONFIG[oShape].model
        model_info.rendertexSize = 1
        self.m_ActorTexture:ChangeShape(model_info, function () end)
    elseif oPrizeList[1].type == 4 then
        self.m_ModelBox:SetActive(true)
        self.m_PrizeDescSp1:SetActive(false)
        self.m_PrizeBox:SetLocalPos(Vector3.New(192, -116, 0))
        self.m_PrizeDescSp3:SetLocalPos(Vector3.New(32, 80.2, 0))
        local oShape = oPrizeList[1].summon.shape
        local model_info = {}
        model_info.shape = data.modeldata.CONFIG[oShape].model
        model_info.rendertexSize = 1
        self.m_ActorTexture:ChangeShape(model_info, function () end)
    end

    if g_WelfareCtrl.m_ColorfulData then
        for _,v in ipairs(g_WelfareCtrl.m_ColorfulData) do
            if "login_gift_"..oData ==v.key and v.val == 1 then --可以领取
                self.m_PrizeHasGetSp:SetActive(false)
                self.m_PrizeGetBtn:SetActive(true)
                self.m_PrizeGetBtn:SetBtnGrey(false)
                self.m_PrizeGetBtn:EnableTouch(true)
                self.m_PrizeGetBtn:AddEffect("Rect")
                break
            end
            if "login_gift_"..oData == v.key and v.val == 2 then --已领取
                self.m_PrizeHasGetSp:SetActive(true)
                self.m_PrizeGetBtn:SetActive(false)
                self.m_PrizeGetBtn:DelEffect("Rect")
                break
            end
            if "login_gift_"..oData == v.key and v.val == 0  then --不可领取
                self.m_PrizeHasGetSp:SetActive(false)
                self.m_PrizeGetBtn:SetActive(true)
                self.m_PrizeGetBtn:SetBtnGrey(true)
                self.m_PrizeGetBtn:EnableTouch(false)
                self.m_PrizeGetBtn:DelEffect("Rect")
                break
            end
        end
    end

    self:SetPrizeList(oPrizeList)
end

function CWelfareEightLoginPart.SetEightList(self)
    local optionCount = #self.m_EightList
    local GridList = self.m_EightGrid:GetChildList() or {}
    local oEightBox
    if optionCount > 0 then
        for i=1,optionCount do
            if i > #GridList then
                oEightBox = self.m_EightBoxClone:Clone(false)
                -- self.m_EightGrid:AddChild(oOptionBtn)
            else
                oEightBox = GridList[i]
            end
            self:SetEightBox(oEightBox, self.m_EightList[i])
        end

        if #GridList > optionCount then
            for i=optionCount+1,#GridList do
                GridList[i]:SetActive(false)
            end
        end
    else
        if GridList and #GridList > 0 then
            for _,v in ipairs(GridList) do
                v:SetActive(false)
            end
        end
    end

    self.m_EightGrid:Reposition()
    -- self.m_EightScrollView:ResetPosition()

    --八日登录引导相关
    local oSecondChild = self:GetEightLoginChild(2)
    if oSecondChild then
        g_GuideCtrl:AddGuideUI("eightlogin_second_btn", oSecondChild.m_ClickWidget)
    end
end

function CWelfareEightLoginPart.GetEightLoginChild(self, oIndex)
    local GridList = self.m_EightGrid:GetChildList() or {}
    for k,v in pairs(GridList) do
        if v.m_Data and tonumber(v.m_Data) == oIndex then
            return v
        end
    end
end

function CWelfareEightLoginPart.SetEightBox(self, oEightBox, oData)
    oEightBox:SetActive(true)
    oEightBox.m_IconSp = oEightBox:NewUI(1, CSprite)
    oEightBox.m_HasGetSp = oEightBox:NewUI(2, CSprite)
    oEightBox.m_MaskSp = oEightBox:NewUI(3, CSprite)
    oEightBox.m_DayLbl = oEightBox:NewUI(4, CLabel)
    oEightBox.m_ClickWidget = oEightBox:NewUI(5, CWidget)

    oEightBox.m_ClickWidget:SetGroup(self:GetInstanceID())
    oEightBox.m_Data = oData
    oEightBox.m_DayLbl:SetText("第"..oData.."天")
    local oConfig = data.welfaredata.LOGIN
    local oPrizeList = g_GuideHelpCtrl:GetRewardList("WELFARE", oConfig["login_gift_"..oData].gift)
    if oPrizeList[1].type == 1 then
        oEightBox.m_IconSp:SpriteItemShape(oPrizeList[1].item.icon)
    elseif oPrizeList[1].type == 2 then
        oEightBox.m_IconSp:SpriteAvatar(oPrizeList[1].partner.shape)
    elseif oPrizeList[1].type == 3 then
        oEightBox.m_IconSp:SpriteAvatar(oPrizeList[1].ride.shape)
    elseif oPrizeList[1].type == 4 then
        oEightBox.m_IconSp:SpriteAvatar(oPrizeList[1].summon.shape)
    end

    if g_WelfareCtrl.m_ColorfulData then
        for _,v in ipairs(g_WelfareCtrl.m_ColorfulData) do
            if "login_gift_"..oData ==v.key and v.val == 1 then --可以领取
                oEightBox.m_MaskSp:SetActive(false)
                oEightBox.m_HasGetSp:SetActive(false)
                break
            end
            if "login_gift_"..oData == v.key and v.val == 2 then --已领取
                oEightBox.m_MaskSp:SetActive(false)
                oEightBox.m_HasGetSp:SetActive(true)
                break
            end
            if "login_gift_"..oData == v.key and v.val == 0  then --不可领取
                oEightBox.m_MaskSp:SetActive(true)
                oEightBox.m_HasGetSp:SetActive(false)
                break
            end
        end
    end

    oEightBox.m_ClickWidget:AddUIEvent("click", callback(self, "OnClickEightBox", oData))

    self.m_EightGrid:AddChild(oEightBox)
    self.m_EightGrid:Reposition()
end

function CWelfareEightLoginPart.SetPrizeList(self, oList)
    local optionCount = #oList
    local GridList = self.m_PrizeGrid:GetChildList() or {}
    local oPrizeBox
    if optionCount > 0 then
        for i=1,optionCount do
            if i > #GridList then
                oPrizeBox = self.m_PrizeBoxClone:Clone(false)
                -- self.m_PrizeGrid:AddChild(oOptionBtn)
            else
                oPrizeBox = GridList[i]
            end
            self:SetPrizeBox(oPrizeBox, oList[i])
        end

        if #GridList > optionCount then
            for i=optionCount+1,#GridList do
                GridList[i]:SetActive(false)
            end
        end
    else
        if GridList and #GridList > 0 then
            for _,v in ipairs(GridList) do
                v:SetActive(false)
            end
        end
    end

    self.m_PrizeGrid:Reposition()
    self.m_PrizeScrollView:ResetPosition()
end

function CWelfareEightLoginPart.SetPrizeBox(self, oPrizeBox, oData)
    oPrizeBox:SetActive(true)
    oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
    oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
    oPrizeBox.m_BorderSp = oPrizeBox:NewUI(3, CSprite)

    oPrizeBox.m_BorderSp:SetActive(false)

    oPrizeBox.m_CountLbl:SetText("")
    -- oPrizeBox.m_CountLbl:SetText(oData.amount)
    if oData.type == 1 then
        oPrizeBox.m_BorderSp:SetActive(true)
        oPrizeBox.m_BorderSp:SetItemQuality(g_ItemCtrl:GetQualityVal( oData.item.id, oData.item.quality or 0 ))
        oPrizeBox.m_IconSp:SpriteItemShape(oData.item.icon)    
    elseif oData.type == 2 then
        oPrizeBox.m_IconSp:SpriteAvatar(oData.partner.shape)
    elseif oData.type == 3 then
        oPrizeBox.m_IconSp:SpriteAvatar(oData.ride.shape)
    elseif oData.type == 4 then
        oPrizeBox.m_IconSp:SpriteAvatar(oData.summon.shape)
    end
    
    oPrizeBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPrizeBox", oData, oPrizeBox.m_IconSp))

    self.m_PrizeGrid:AddChild(oPrizeBox)
    self.m_PrizeGrid:Reposition()
end

---------------以下是点击事件----------------

function CWelfareEightLoginPart.OnClickEightBox(self, oData)
    local oChild = self.m_EightGrid:GetChild(oData)
    if oChild and oChild.m_ClickWidget then
        oChild.m_ClickWidget:SetSelected(true)
    end
    self:RefreshBottomContent(oData)
end

function CWelfareEightLoginPart.OnClickPrizeGetBtn(self)
    if self.m_SelectBottomIdx == 1 then
        g_GuideHelpCtrl.m_IsEightLoginGetClick = true
    end
    nethuodong.C2GSRewardWelfareGift("login", "login_gift_"..self.m_SelectBottomIdx)
end

function CWelfareEightLoginPart.OnClickPrizeBox(self, oPrize, oPrizeBox)
    if oPrize.type == 1 then
        local args = {
            widget = oPrizeBox,
            side = enum.UIAnchor.Side.Top,
            offset = Vector2.New(0, 0)
        }
        g_WindowTipCtrl:SetWindowItemTip(oPrize.item.id, args)
    elseif oPrize.type == 2 then
        g_PartnerCtrl.m_PartnerNotSelectFirst = true
        CPartnerMainView:ShowView(function (oView)
            oView:ResetCloseBtn()
            oView:SetSpecificPartnerIDNode(oPrize.partner.id)
        end)
    elseif oPrize.type == 3 then
        CHorseMainView:ShowView(function (oView)
            oView:ShowSpecificPart(oView:GetPageIndex("detail"))
            oView:ChooseDetailPartHorse(oPrize.ride.id)
        end)
    elseif oPrize.type == 4 then
        if g_OpenSysCtrl:GetOpenSysState("SUMMON_SYS") then
             g_SummonCtrl:ShowSummonLinkView(oPrize.summon.id, 15)
        else
            local str = data.welfaredata.TEXT[1006].content
            local sysop = data.opendata.OPEN["SUMMON_SYS"].p_level
            local sys = data.opendata.OPEN["SUMMON_SYS"].name
            str = string.gsub(str,"#grade",tostring(sysop))
            str = string.gsub(str,"#name",sys)
            g_NotifyCtrl:FloatMsg(str)
        end
    end
end

return CWelfareEightLoginPart