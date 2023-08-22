local CSummonStudyPart = class("CSummonStudyPart", CBox)

function CSummonStudyPart.ctor(self, obj, cb)
    CBox.ctor(self, obj)

    self.m_CurItem = nil
    self:InitContent()
end

function CSummonStudyPart.InitContent(self)
    self.m_SelItem = self:NewUI(1, CBox)
    self.m_SkillBox = self:NewUI(2, CSummonSkillBox)
    self.m_TipBtn = self:NewUI(3, CButton)
    self.m_StudyBtn = self:NewUI(4, CButton)
    self.m_DescL = self:NewUI(5, CLabel)
    self.m_QuickBuyBox = self:NewUI(6, CQuickBuyBox)
    self:InitItemBox()
    self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)
    self.m_QuickBuyBox:SetInfo({
        id = define.QuickBuy.ForgeWash,
        name = "便捷购买",
        offset = Vector3(-45,0,0),
    })

    self.m_StudyBtn:AddUIEvent("click", callback(self, "OnClickStudy"))
    self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTip"))
end

function CSummonStudyPart.InitItemBox(self)
    local oBox = self.m_SelItem
    oBox.iconSpr = oBox:NewUI(1, CSprite)
    oBox.addSpr = oBox:NewUI(2, CSprite)
    oBox.nameL = oBox:NewUI(3, CLabel)
    oBox.qualitySpr = oBox:NewUI(4, CSprite)
    oBox:AddUIEvent("click", callback(self, "OnClickItem"))
end

function CSummonStudyPart.SetInfo(self, info)
    self:SetSkillInfo(info)
    self:SetStudyItem(nil)
    self.m_Info = info
end

function CSummonStudyPart.SetStudyItem(self, skInfo)
    self.m_SkInfo = skInfo
    local oBox = self.m_SelItem
    local bHasInfo = skInfo and true or false
    oBox.iconSpr:SetActive(bHasInfo)
    oBox.addSpr:SetActive(not bHasInfo)
    oBox.qualitySpr:SetActive(bHasInfo)
    if skInfo then
        if skInfo.id == 30000 then
            local dItem = DataTools.GetItemData(skInfo.id, "SUMMSKILL")
            if dItem then
                oBox.iconSpr:SpriteItemShape(dItem.icon)
                oBox.nameL:SetText(dItem.name)
                oBox.qualitySpr:SetItemQuality(dItem.quality)
                self.m_DescL:SetText(dItem.description)
            end
        elseif skInfo.skid then
            local dSkill = SummonDataTool.GetSummonSkillInfo(skInfo.skid)
            local icon = dSkill.iconlv[1].icon
            oBox.iconSpr:SpriteSkill(icon)
            oBox.nameL:SetText(dSkill.name)
            local iQuality = dSkill.quality
            if iQuality == 0 then
                iQuality = 2
            end
            oBox.qualitySpr:SetItemQuality(iQuality)
            self.m_DescL:SetText(dSkill.short_des)
        end
        table.print(skInfo)
        self.m_QuickBuyBox:SetItemsInfo({{id = skInfo.id, cnt = 1, costdirect = true},})
    else
        oBox.nameL:SetText("请选择技能书")
        self.m_DescL:SetText("点击+号放出技能书")
        self.m_QuickBuyBox:SetItemsInfo(nil)
    end
    self:SetStudyBtnState(skInfo and true or false)
end

function CSummonStudyPart.SetSkillInfo(self, info)
    local skills = SummonDataTool.GetSkillInfo(info)
    self.m_SkillBox:SetInfo(skills, true)
end

function CSummonStudyPart.SetStudyBtnState(self, bState)
    if bState then
        self.m_StudyBtn:SetSpriteName("h7_an_1")
        self.m_StudyBtn:SetText("[eefffb]学习[-]")
    else
        self.m_StudyBtn:SetSpriteName("h7_an_5")
        self.m_StudyBtn:SetText("[50585B]学习[-]")
    end
end

function CSummonStudyPart.OnClickStudy(self)
    if self.m_SkInfo then
        local bQuick = self.m_QuickBuyBox:IsSelected()
        if bQuick then
            netsummon.C2GSFastStickSkill(self.m_Info.id, self.m_SkInfo.id)
        else
            if self.m_SkInfo.price then
                self:OnBuyStudyItem()
            else
                local iSummon = self.m_Info.id
                g_SummonCtrl:StudySkill(iSummon, self.m_SkInfo.objId)
            end
        end
    else
        g_NotifyCtrl:FloatMsg("请选择技能！") 
    end
end

function CSummonStudyPart.OnClickItem(self)
    -- if self.m_SkInfo then
    --     local config = {
    --         widget = self.m_SelItem,
    --     }
    --     g_WindowTipCtrl:SetWindowItemTip(self.m_SkInfo.id, config)
    -- else
        CSummonStudyItemView:ShowView()
    -- end
end

function CSummonStudyPart.OnClickTip(self)
    local dConfig = data.instructiondata.DESC[10048]
    if not dConfig then return end
    local dContent = {
        title = dConfig.title,
        desc = dConfig.desc,
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(dContent)
end

function CSummonStudyPart.OnBuyStudyItem(self)
    local dBuyInfo = self.m_SkInfo
    local iGold = g_AttrCtrl.gold
    if iGold > dBuyInfo.price then
        local dItem = DataTools.GetItemData(dBuyInfo.id, "SUMMSKILL")
        local sType = dBuyInfo.isAdv and "高级" or "低级"
        local sDesc = string.format("是否花费%d金币，购买一本%s兽决：%s，进行学习？", dBuyInfo.price, sType, dItem.name)
        local itemId, iGoodId = dBuyInfo.id, dBuyInfo.goodId
        local windowConfirmInfo = {
            msg = sDesc,
            title = "购买技能",
            okCallback = function()
                g_SummonCtrl:SetStudyGuildItem(itemId)
                netguild.C2GSBuyGuildItem(iGoodId, 1)
            end
        }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
    else
        g_NotifyCtrl:FloatMsg("金币不足")
    end
end

return CSummonStudyPart