local CSummonComOutView = class("CSummonComOutView", CViewBase)

function CSummonComOutView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Summon/SummonComOutView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.g_SummonCtrl = g_SummonCtrl
end

function CSummonComOutView.OnCreateView(self)
	self.m_AptiBox = self:NewUI(1, CSummonAptiBox)
	self.m_OkBtn = self:NewUI(2, CButton)
	self.m_LAttPage = self:NewUI(3, CBox)
	self.m_SkillBox = self:NewUI(4, CSummonSkillBox)
 	self:InitLAttPage()
 	self.m_AptiBox:InitTextUI(true)
 	self:InitEvent()
end

function CSummonComOutView.InitEvent(self)
	-- self.m_CloseBtn:AddUIEvent("click",callback(self,"OnClose"))
	self.m_OkBtn:AddUIEvent("click",callback(self,"OnClose"))
	self.g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CSummonComOutView.InitLAttPage(self)
	self.m_SummonName = self.m_LAttPage:NewUI(1, CLabel)
	self.m_SummonGrade = self.m_LAttPage:NewUI(2, CLabel)
	self.m_SummonType = self.m_LAttPage:NewUI(3, CSprite)	
	self.m_SummonTexture = self.m_LAttPage:NewUI(4, CActorTexture)
	self.m_SummonScore = self.m_LAttPage:NewUI(5, CLabel)
	self.m_SummonRank = self.m_LAttPage:NewUI(6, CLabel)
end

function CSummonComOutView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo then
		if self.m_CurSummonId == oCtrl.m_EventData.id then
			self:SetData(self.m_CurSummonId)
		end
	end			
	if oCtrl.m_EventID == define.Summon.Event.DelSummon or self.m_CurSummonId == oCtrl.m_EventData then				
		if next(self.g_SummonCtrl:GetSummons()) == nil then
			self:OnClose()
		end
	end
end	

function CSummonComOutView.SetLAttPageInfo(self,id)
	local  dp = self.g_SummonCtrl.m_SummonsDic[id]
	self.m_SummonName:SetText(dp["name"])
	self.m_SummonGrade:SetText("等级:"..dp["grade"])
	local iType = dp.type
	self.m_SummonType:SetSpriteName(data.summondata.SUMMTYPE[iType].icon)
	if iType == 8 or iType == 7 then
		self.m_SummonType:SetSize(32, 104)
	else
		self.m_SummonType:SetSize(36, 82)
	end
	if self.m_SummonTexture ~= nil then
		local modelInfo = table.copy(dp.model_info)
		modelInfo.rendertexSize = 1.4
		modelInfo.pos = Vector3(0, -0.85, 3)
		self.m_SummonTexture:ChangeShape(modelInfo)
	end
	self.m_SummonScore:SetText(string.format("(%d)", dp["summon_score"]))
	for k,v in pairs(data.summondata.SCORE) do
		if v.rank == dp["rank"] then 
			self.m_SummonRank:SetText(data.summondata.SCORE[k].label)
			break	
		end
	end
end

function CSummonComOutView.SetData(self, id)
	self.m_CurSummonId = id 
	self:SetLAttPageInfo(id)
	local dInfo = g_SummonCtrl:GetSummon(id)
	self.m_AptiBox:SetInfo(dInfo)
    local skills = SummonDataTool.GetSkillInfo(dInfo)
    self.m_SkillBox:SetInfo(skills)
end

return CSummonComOutView