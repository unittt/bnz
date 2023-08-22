local CSummonSkillItemTipsView = class("CSummonSkillItemTipsView", CViewBase)

function CSummonSkillItemTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Summon/CSummonSkillItemTipsView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "sub"
	self.m_DefaultPos = nil
	local dBandSkCost = data.globaldata.SUMMONCK[1].band_skill_cost
	self.m_CostItemId = dBandSkCost.sid
	self.m_CostItemCnt = dBandSkCost.num
end

function CSummonSkillItemTipsView.OnCreateView(self)
	self.m_ItemIcon = self:NewUI(1, CSprite)
	self.m_ItemName = self:NewUI(2, CLabel)
	self.m_ItemSkillGrade = self:NewUI(3, CLabel)
	self.m_ItemSkillDes = self:NewUI(4, CLabel)
	self.m_TipWidget = self:NewUI(5, CWidget)
	self.m_QalitySpr = self:NewUI(6, CSprite)
	self.m_ViewWidget = self:NewUI(7, CWidget)
	self.m_BindBtn = self:NewUI(8, CButton)
	self.m_BindBox = self:NewUI(9, CBox)
	self.m_NotBtnBg = self:NewUI(10, CWidget)
	self.m_BtnBg = self:NewUI(11, CWidget)

	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
	self.m_BindBtn:AddUIEvent("click", callback(self, "OnClickBind"))
end

--技能提示信息
function CSummonSkillItemTipsView.SetData(self, dp, v3, istalent, fun, dir)
	local iconlist = data.summondata.SKILL[dp.sk].iconlv
	local dConfig = SummonDataTool.GetSummonSkillInfo(dp.sk)
	self.m_ItemIcon:SpriteSkill(dConfig.iconlv[1].icon)
	self.m_ItemName:SetText(data.summondata.SKILL[dp.sk].name)
	local iQuality = dConfig.quality
	if 0==iQuality then
		iQuality = 2
	end
	self.m_QalitySpr:SetItemQuality(iQuality)
	if istalent then
	   	self.m_ItemSkillGrade:SetText("天赋")
	else
	   	self.m_ItemSkillGrade:SetActive(false)
	end
	local des = dConfig.des
 --    local formula1 = string.gsub(data.summondata.SKILL[dp.sk].formula1, "level", dp.level)
	-- local formula2 = string.gsub(data.summondata.SKILL[dp.sk].formula2, "level", dp.level) 
 --    local f1 = loadstring("return "..formula1) 
	-- local f2 = loadstring("return "..formula2) 
 --    if f1 then 
	-- 	des = string.gsub(des, "#1", math.floor(f1())) 
 --    end
	-- if f2 then 
	-- 	des = string.gsub(des, "#2", math.floor(f2())) 
 --    end
	self.m_ItemSkillDes:SetText(des)
	if dir ~= nil then
		v3.y = 0.7
		v3.x = 0
	else
		v3.y = v3.y + 0.5
		v3.x = v3.x - 0.6
	end
	if v3.x < -0.93 then
	   v3.x = -0.73
	end
	self.m_DefaultPos = v3
	self.m_Info = dp
	-- self.m_TipsShow:SetPos(v3)
	if dp.canOpera then
		self:ShowBindPart(dp)
	else
		self:HideBindPart()
	end
end

function CSummonSkillItemTipsView.SetArtifactSkillTips(self, oData, oWidget)
	self.m_ItemIcon:SpriteSkill(oData.icon)
	self.m_ItemName:SetText(oData.name)
	self.m_ItemSkillDes:SetText(oData.desc)
	-- v3.y = v3.y + 0.55
	-- v3.x = v3.x - 0.6
	-- if v3.x < -0.93 then
	--    v3.x = -0.73
	-- end
	-- self.m_DefaultPos = v3
	self:ShowBindBtnSwitch(false)
	self.m_BindBtn:SetActive(false)
	UITools.NearTarget(oWidget, self.m_ViewWidget, enum.UIAnchor.Side.TopLeft, Vector2.New(-100, 100))
end

--------------- 绑定状态显示 --------------
function CSummonSkillItemTipsView.ShowBindPart(self, dInfo)
	if dInfo.talent or dInfo.equip or dInfo.wenshi then --天赋/护符不能绑定
		self:HideBindPart()
		return
	end
	local dSummon
	if dInfo.summonId then
		dSummon = g_SummonCtrl:GetSummon(dInfo.summonId)
	end
	if not dSummon then
		self:HideBindPart()
		return
	end
	self.m_SummonInfo = dSummon
	-- 特殊处理
	if dInfo.sk >= 5300 and dInfo.sk < 5400 then
		self:HideBindPart()
		return
	end
	local iBindSk = SummonDataTool.GetSummonBindSkill(dSummon)
	if iBindSk then
		if iBindSk == dInfo.sk then
			self:SetUnbindView()
		else
			self:HideBindPart()
		end
	else
		self:SetBindView()
	end
end

function CSummonSkillItemTipsView.SetBindView(self)
	self.m_BindBtn:SetText("绑定")
	self:ShowBindBtnSwitch(true)
	-- self.m_ViewWidget:SetLocalPos(Vector3.New(-200, 150, 0))
	self.m_ViewWidget:SetPos(self.m_DefaultPos)
end

function CSummonSkillItemTipsView.SetUnbindView(self)
	self.m_BindBtn:SetText("解绑")
	self:ShowBindBtnSwitch(true)
	self.m_ViewWidget:SetPos(self.m_DefaultPos)
end

function CSummonSkillItemTipsView.HideBindPart(self)
	self:ShowBindBtnSwitch(false)
	self.m_BindBtn:SetActive(false)
	self.m_ViewWidget:SetPos(self.m_DefaultPos)
end

function CSummonSkillItemTipsView.ShowBindBtnSwitch(self, bShow)
	self.m_BindBtn:SetActive(bShow)
	self.m_NotBtnBg:SetActive(not bShow)
	self.m_BtnBg:SetActive(bShow)
	self.m_BindBox:SetActive(false)
end

-------------------------绑定信息-----------------------
function CSummonSkillItemTipsView.RefreshBindBoxInfo(self)
	-- 只刷新一次
	if self.m_HasRefreshBind then
		return
	end
	self.m_TipWidget:SetActive(false)
	local oBox = self.m_BindBox
	self:InitBindBox(oBox)
	self.m_HasRefreshBind = true
	self.m_ViewWidget:SetLocalPos(Vector3.New(200, 50, 0))
	local dSummon = self.m_SummonInfo
	self:RefreshBindDesc(dSummon.name)
	self:RefreshBindItemBox(oBox)
	self:RefreshBindSkillBox(oBox)
	self.m_BindBox:SetActive(true)
end

function CSummonSkillItemTipsView.InitBindBox(self, oBox)
	oBox.itemBox = oBox:NewUI(1, CBox)
	oBox.descL = oBox:NewUI(2, CLabel)
	oBox.okBtn = oBox:NewUI(3, CButton)
	oBox.closeBtn = oBox:NewUI(4, CButton)
	oBox.skillBox = oBox:NewUI(5, CBox)
	oBox.okBtn:AddUIEvent("click", callback(self, "OnClickComfirmBind"))
	oBox.closeBtn:AddUIEvent("click", callback(self, "OnClose"))
	oBox.itemBox:AddUIEvent("click", callback(self, "OnClickItem"))
end

function CSummonSkillItemTipsView.RefreshBindItemBox(self, oBox)
	local oItem = oBox.itemBox
	oItem.iconSpr = oItem:NewUI(1, CSprite)
	oItem.qualitySpr = oItem:NewUI(2, CSprite)
	oItem.nameL = oItem:NewUI(3, CLabel)
	oItem.cntL = oItem:NewUI(4, CLabel)
	local dItem = DataTools.GetItemData(self.m_CostItemId)
	local iCnt = g_ItemCtrl:GetBagItemAmountBySid(self.m_CostItemId)
	oItem.iconSpr:SpriteItemShape(dItem.icon)
	oItem.nameL:SetText(dItem.name)
	oItem.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal(dItem.id, dItem.quality or 0 ))
	if iCnt >= self.m_CostItemCnt then
		oItem.cntL:SetText(iCnt)
	else
		oItem.cntL:SetText("[D71420]" .. iCnt)
	end
end

function CSummonSkillItemTipsView.RefreshBindSkillBox(self, oBox)
	local oSkill = oBox.skillBox
	oSkill.iconSpr = oSkill:NewUI(1, CSprite)
	oSkill.qualitySpr = oSkill:NewUI(2, CSprite)
	oSkill.nameL = oSkill:NewUI(3, CLabel)
	local dSk = SummonDataTool.GetSummonSkillInfo(self.m_Info.sk)
	oSkill.iconSpr:SpriteSkill(dSk.iconlv[1].icon)
	oSkill.nameL:SetText(dSk.name)
	local iQuality = dSk.quality
	if 0==iQuality then
		iQuality = 2
	end
	oSkill.qualitySpr:SetItemQuality(iQuality)
end

function CSummonSkillItemTipsView.RefreshBindDesc(self, sName)
	local sDesc = SummonDataTool.GetText(2026)
	sDesc = string.replace(sDesc, "\\n", "\n")
	self.m_BindBox.descL:SetText(string.format(sDesc, sName))
end

function CSummonSkillItemTipsView.UnbindConfirm(self)
	local sDesc = "确定解除绑定技能?"
	local iSummon, iSk = self.m_Info.summonId, self.m_Info.sk
    local windowConfirmInfo = {
        msg = sDesc,
        title = "提示",
        okCallback = function()
        	netsummon.C2GSSummonBindSKill(iSummon, iSk, 0)
        end
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

-----------------------events ----------------------
-- 左边的绑定按钮
function CSummonSkillItemTipsView.OnClickBind(self)
	if not self.m_Info then
		return
	end
	local dSkInfo = self.m_Info
	local bBind = false
	if dSkInfo.bind and dSkInfo.bind == 1 then
		self:UnbindConfirm()
		self:OnClose()
	else
		self:RefreshBindBoxInfo()
	end	
end

-- 右边确认框确定绑定
function CSummonSkillItemTipsView.OnClickComfirmBind(self)
	local dSkInfo = self.m_Info
	if not dSkInfo then return end
	netsummon.C2GSSummonBindSKill(dSkInfo.summonId, dSkInfo.sk, 1)
	self:OnClose()
end

function CSummonSkillItemTipsView.OnClickItem(self)
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_CostItemId)
end

return CSummonSkillItemTipsView