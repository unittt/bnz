local CHorseUpgradePart = class("CHorseUpgradePart", CPageBase)

function CHorseUpgradePart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CHorseUpgradePart.OnInitPage(self)
    self.m_UpgradeDes = self:NewUI(1, CButton)
	self.m_HorseName = self:NewUI(2, CLabel)
	self.m_HorseTexture = self:NewUI(3, CActorTexture)
	self.m_HorseGrade = self:NewUI(4, CLabel)
	--self.m_AttrGrid = self:NewUI(5, CGrid)
	self.m_SkillInfoBtn = self:NewUI(6, CButton)
	self.m_SkillPoint = self:NewUI(10, CLabel)
	self.m_StudySkillBtn = self:NewUI(11, CButton)
	self.m_HorseExpSlider = self:NewUI(12, CSlider)
	self.m_AddExpBtn = self:NewUI(13, CButton)
	self.m_HorseExpNumber = self:NewUI(15, CLabel)
	self.m_HorseAttrLabel  = self:NewUI(17, CLabel)
	self.m_horseAddExpBox  = self:NewUI(18, CHorseAddExpBox)
	self.m_previewSkill  = self:NewUI(19, CSprite)
	self.m_learnSkillRow = self:NewUI(20, CHorseLearnSkillRowBox)
	self.m_Grid = self:NewUI(21, CGrid)
	--self.m_SkillTipsBox = self:NewUI(22, CHorseSkillTipsBox)
--	self.m_ResetBtn = self:NewUI(23, CSprite)
	self.m_FullLevel = self:NewUI(24, CLabel)
	self.m_TupoBtn = self:NewUI(25, CSprite)

	self:InitContent()
end

function CHorseUpgradePart.InitContent(self)
	self.m_UpgradeDes:AddUIEvent("click", callback(self, "ShowDes"))
	self.m_StudySkillBtn:AddUIEvent("click", callback(self, "OnStudySkill"))
	self.m_AddExpBtn:AddUIEvent("click", callback(self, "OnAddExp"))
	self.m_SkillInfoBtn:AddUIEvent("click", callback(self, "OnShowSkillStore"))
	self.m_previewSkill:AddUIEvent("click", callback(self, "OnClickPreViewSkill"))
--	self.m_ResetBtn:AddUIEvent("click", callback(self, "OnResetBtn"))
	self.m_TupoBtn:AddUIEvent("click", callback(self, "OnClickTupoBtn"))
	g_HorseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	
end


--showPage的时候刷新各个部分
function CHorseUpgradePart.OnShowPage(self)

	self.m_horseId = g_HorseCtrl:GetCurSelHorseId()
	if self.m_horseId == nil then
		self.m_horseId = g_HorseCtrl:GetHorseSortIdByIdx(1)
	end
	self.m_SelectHorseData = data.ridedata.RIDEINFO[self.m_horseId]

	self:RefreshName()
	--self:RefreshAttr()
	self:RefreshHorseTexture()
	self:RefreshGrade()
	self:RefreshBtn()
	self:RefreshRemainSkillPoint()
	self:RefreshExpSlider()
	self:CreateSkillBox()
	self:RefreshSkillBox()
	self:RefreshResetBtn()

end

function CHorseUpgradePart.RefreshName(self)
	

	self.m_HorseName:SetText(self.m_SelectHorseData.name)

end

function CHorseUpgradePart.RefreshHorseTexture(self)

    local model_info = {}
    model_info.horse = self.m_SelectHorseData.id
	model_info.rendertexSize = 1.8

	self.m_HorseTexture:ChangeShape(model_info)

end

function CHorseUpgradePart.RefreshGrade(self)

	self.m_HorseGrade:SetText("等级：".. g_HorseCtrl.grade)

end

function CHorseUpgradePart.RefreshRemainSkillPoint(self)
	
	self.m_SkillPoint:SetText(g_HorseCtrl.point)

end

function CHorseUpgradePart.RefreshResetBtn(self)
	
	if g_HorseCtrl.skills and next(g_HorseCtrl.skills) then 
		--self.m_ResetBtn:SetGrey(false)
		--self.m_ResetBtn:AddUIEvent("click", callback(self, "OnResetBtn"))

	else
		--self.m_ResetBtn:SetGrey(true)
		--self.m_ResetBtn:DelUIEvent("click")
	end  

	
	
end

function CHorseUpgradePart.OnClickTupoBtn(self)
	
	if g_HorseCtrl:IsFullGrade() then 
		g_NotifyCtrl:FloatMsg("已满级")
		return
	end 
	CHorseExpUpgradeView:ShowView(function (oView)
		oView:SetData(self.m_SelectHorseData)
	end)

end

function CHorseUpgradePart.RefreshBtn(self)

	if g_HorseCtrl:IsFullGrade() then 
		self.m_TupoBtn:SetActive(false)
		self.m_AddExpBtn:SetActive(false)
	else
		self.m_TupoBtn:SetActive(g_HorseCtrl:IsCanTupo())
		self.m_AddExpBtn:SetActive(not g_HorseCtrl:IsCanTupo())
	end 

end

--刷新经验条
function CHorseUpgradePart.RefreshExpSlider(self)
	
	local nextExp = g_HorseCtrl:GetExpByGrade(g_HorseCtrl.grade + 1)
    local needExp = 0
	if nextExp then
        local curGradeExp = g_HorseCtrl:GetExpByGrade(g_HorseCtrl.grade)
        local curExp = g_HorseCtrl.exp
        needExp = nextExp
		self.m_HorseExpSlider:SetValue(curExp/needExp)
    	self.m_HorseExpNumber:SetText(curExp .."/"..needExp)
    	self.m_FullLevel:SetActive(false)
    	self.m_AddExpBtn:SetActive(true)
	else
		local exp = g_HorseCtrl:GetExpByGrade(g_HorseCtrl.grade)
		self.m_HorseExpSlider:SetValue(1)
		if exp then 
			self.m_HorseExpNumber:SetText(exp .. "/" .. exp)
		end 
        self.m_AddExpBtn:SetActive(false) 
        self.m_FullLevel:SetActive(true)
        self.m_horseAddExpBox:SetActive(false)

	end

end


function CHorseUpgradePart.RefreshAll(self, info)

    --经验条
    self:RefreshExpSlider()

    --等级
	self:RefreshGrade()

	self:RefreshBtn()

    --属性
	--self:RefreshAttr()

	--技能点
	self:RefreshRemainSkillPoint()

	self:RefreshSkillBox()

	self:RefreshResetBtn()


end

function CHorseUpgradePart.OnCtrlEvent(self, oCtrl)

	if oCtrl.m_EventID == define.Horse.Event.HorseAttrChange then
		self:RefreshAll()
	end
	if oCtrl.m_EventID == define.Horse.Event.ResetSkill then 
		self:ShowResetTip(oCtrl.m_EventData)
	end 

end

function CHorseUpgradePart.ShowResetTip(self, data)

	local exp = data.cost_exp
	local grade = data.grade
	local point = data.point

	local s = "重置坐骑技能，您可以获得" .. tostring(point) .. "点技能点\n需要消耗：" .. tostring(exp).."点坐骑经验\n坐骑降级为：".. tostring(grade) .. "级\n是否继续重置技能?"

	local windowConfirmInfo = {
	msg = s,
	title = "提示",
	okCallback = function ()
		g_HorseCtrl:C2GSResetRideSkill()
	end,
	cancelCallback = function ()

	end,
	}


	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)

	end)

end


--升级属性由服务端发来
function CHorseUpgradePart.RefreshAttr(self)

	-- if self.m_SelectHorseData == nil then
	-- 	return
	-- end 

	-- local attrList = {
	-- 	phy_defense = "物防",
	-- 	phy_attack = "物攻", 
	-- 	max_hp = "气血", 
	-- 	cure_power = "治疗强度", 
	-- 	endurance = "耐力", 
	-- 	speed = "速度", 
	-- 	mag_attack = "法攻", 
	-- 	mag_defense = "法防",
	-- 	seal_ratio = "封印强度",
	-- 	res_seal_ratio = "封印抗性",
	-- }

	-- if g_HorseCtrl.attrs then

	-- 	self.m_AttrGrid:HideAllChilds()
	-- 	local i = 1
	-- 	for k, v in pairs(g_HorseCtrl.attrs) do 
	-- 		local item = self.m_AttrGrid:GetChild(i)
	-- 		if item == nil then
	-- 			item = self.m_HorseAttrLabel:Clone()	
	-- 			self.m_AttrGrid:AddChild(item)	
	-- 		end
		
	-- 		item:SetText("[284A4B]" .. attrList[v.key] .. ":".."[-][218113]+" .. v.value .. "[-]")
	-- 		item:SetActive(true)
		
	-- 		i = i + 1
	-- 	end 

	-- end 

end

-- function CHorseUpgradePart.OnResetBtn(self)

-- 	g_HorseCtrl:C2GSResetSkillInfo()
	
-- end

function CHorseUpgradePart.CreateSkillBox(self)

	for i = 1 , 6 do 

		local rowItem = self.m_Grid:GetChild(i)
		if not rowItem then 
			rowItem = self.m_learnSkillRow:Clone()
			rowItem:SetActive(true)
			self.m_Grid:AddChild(rowItem)
		end 

	end 

end

function CHorseUpgradePart.ResetSkillBox(self)

	for i = 1 , 6 do 

		local rowItem = self.m_Grid:GetChild(i)
		if rowItem then 
			rowItem:ResetRowItem()
		end 

	end 

end

function CHorseUpgradePart.RefreshSkillBox(self)

	self:ResetSkillBox()

	local skillList = g_HorseCtrl.skills

	for k, v in pairs(skillList) do 

   		local rowItem = self.m_Grid:GetChild(v.row)
   		if rowItem then 
   			rowItem:SetInfo(v.col, v.sk)
   			rowItem:SetActive(true)
	        rowItem:AddCb(callback(self, "OnShowTips"))
   		end 

   	end

end


function CHorseUpgradePart.OnShowTips(self, id)

	--self.m_SkillTipsBox:SetActive(true)
	--self.m_SkillTipsBox:SetInfo(id)
	CHorseSkillTipsView:ShowView(function (oView)
		
		oView:SetInfo(id)

	end)

end

function CHorseUpgradePart.OnClickRemainTimeBtn(self)

	CHorseBuyView:ShowView(function (oView)
		oView:SetInfo(g_HorseCtrl:GetCurSelHorseId())
	end)

end


function CHorseUpgradePart.OnShowSkillStore(self)

	CHorseSkillStoreView:ShowView()

end

function CHorseUpgradePart.OnAddExp(self)

	CHorseExpUpgradeView:ShowView(function ( oView )
		oView:SetData(self.m_SelectHorseData)
	end)

end

function CHorseUpgradePart.OnClickPreViewSkill(self)
	
	CHorseSkillStoreView:ShowView()

end

function CHorseUpgradePart.OnStudySkill(self)
	
	if g_HorseCtrl.point == 0 then 
		 g_NotifyCtrl:FloatMsg("没有技能点！")
		 return
	end 

	CHorseStudySkillView:ShowView(function (oView)

	end)

end

function CHorseUpgradePart.ShowDes(self)

	local zContent = {title = "规则",desc = data.instructiondata.DESC[10004].desc}
    g_WindowTipCtrl:SetWindowInstructionInfo(zContent)

end


return CHorseUpgradePart