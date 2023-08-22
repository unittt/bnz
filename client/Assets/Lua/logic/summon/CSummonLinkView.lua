local CSummonLinkView = class("CSummonLinkView", CViewBase)

function CSummonLinkView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Summon/SummonLinkView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Dialog"
end

function CSummonLinkView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_LAttPage = self:NewUI(2, CBox)
	self.m_RSkillPage = self:NewUI(3, CSummonLinkRPart)
	self:InitLAttPage()
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CSummonLinkView.InitLAttPage(self)
	self.m_Name = self.m_LAttPage:NewUI(1, CLabel)
	self.m_Grade = self.m_LAttPage:NewUI(2, CLabel)
	self.m_ModelTexture = self.m_LAttPage:NewUI(3, CActorTexture)
	self.m_ScoreValue = self.m_LAttPage:NewUI(4, CLabel)
	self.m_ScoreLevel = self.m_LAttPage:NewUI(5, CLabel)
	self.m_TypeBtn = self.m_LAttPage:NewUI(6, CSprite)
	self.m_AttrGrid = self.m_LAttPage:NewUI(7, CGrid)
    self.m_LockSpr = self.m_LAttPage:NewUI(8, CSprite)
    self.m_LockL = self.m_LAttPage:NewUI(9, CLabel)
    self.m_LockL:SetActive(false)
    self.m_LockSpr:AddUIEvent("press", callback(self, "OnPressLock"))
    self.m_LockSpr:SetLongPressTime(0.3)
	local function Init(obj, idx)
		local box = CBox.New(obj)
		box.number = box:NewUI(2,CLabel)
		return box
	end
	self.m_AttrGrid:InitChild(Init)
end


function CSummonLinkView.SetSummon(self, data)
	self.m_Data = data
	self:RefreshLeftInfo()
	self:RefreshLAttPageInfo()
	self.m_RSkillPage:SetInfo(data)
end

function CSummonLinkView.RefreshLeftInfo(self)
	local ldata = self.m_Data
	self.m_Name:SetText(ldata["name"])
	self.m_Grade:SetText(ldata["grade"])
	-- self.m_ScoreValue:SetText(ldata["score"])
	if ldata.summon_score then
		self.m_ScoreValue:SetText(string.format("(%d)",ldata["summon_score"]))
		self.m_ScoreValue:SetActive(true)
	else
		self.m_ScoreValue:SetActive(false)
	end
	if self.m_ModelTexture ~= nil then 
		local modelInfo = table.copy(ldata.model_info)
		modelInfo.rendertexSize = 1.35
		modelInfo.pos = Vector3(0, -0.78, 3)
		self.m_ModelTexture:ChangeShape(modelInfo)
		--{shape = ldata.model_info.shape}
	end
	local iType = ldata["type"]
	local dType = SummonDataTool.GetTypeInfo(iType)
	if dType then
		self.m_TypeBtn:SetSpriteName(dType.icon)
		if iType == 8 or iType == 7 then
			self.m_TypeBtn:SetSize(32, 104)
		else
			self.m_TypeBtn:SetSize(36, 82)
		end
	end
	for k,v in pairs(data.summondata.SCORE) do
		if v.rank == ldata["rank"] then 
			self.m_ScoreLevel:SetText(data.summondata.SCORE[k].label)
			break	
		end
	end	
	self.m_LockSpr:SetActive(1==ldata.key)
end

function CSummonLinkView.RefreshLAttPageInfo(self)
	local data = self.m_Data
	local list = {
	data["max_hp"],
	data["max_mp"],
	data["phy_attack"],
	data["phy_defense"],
	data["mag_attack"],
	data["mag_defense"],
	data["speed"],
	data["life"]
	}
	for k, v in ipairs(list) do
		if k == 8 and SummonDataTool.IsExpensiveSumm(data.type) then
			self.m_AttrGrid:GetChild(k).number:SetText("永生")
		else
			self.m_AttrGrid:GetChild(k).number:SetText(v)
		end
	end
end

function CSummonLinkView.OnPressLock(self, oBtn, bPress)
    self.m_LockL:SetActive(bPress)
end

return CSummonLinkView