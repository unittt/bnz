local CSummonRAttrPageBox = class("CSummonRAttrPageBox", CBox)

function CSummonRAttrPageBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self:InitContent()	
end

function CSummonRAttrPageBox.InitContent(self)
	self.m_SliderList = self:NewUI(1,CGrid)
	local function InitSlider(obj, idx)
		local box = CBox.New(obj)
		box.slider = box:NewUI(2, CSlider)
		if idx == 3 then 
			box.btn = box:NewUI(3, CButton)
			box.btn:AddUIEvent("click", callback(self, "ExpAdd"))	
		end
		return box
	end
	self.m_SliderList:InitChild(InitSlider)
	self.m_AttrList = self:NewUI(2, CGrid)
	local function InitAttr(obj, idx)
		local box = CBox.New(obj)
		box.number = box:NewUI(2, CLabel)
		if idx == 6 then 
			box.btn = box:NewUI(3, CButton)
			box.btn:AddUIEvent("click", callback(self, "OnAddLifeExp"))
		end 
		return box
	end
	self.m_AttrList:InitChild(InitAttr)
	self.m_Potential = self:NewUI(3, CBox)
	self.m_PotentialNumber = self.m_Potential:NewUI(2, CLabel)
	self.m_PotentialBtn = self.m_Potential:NewUI(3, CButton)
	self.m_PotentialBtn:AddUIEvent("click", callback(self, "PotentialOper"))
end

function CSummonRAttrPageBox.SetInfo(self, summonId)
	self.m_CurSummonId = summonId
	local g_SummonCtrl = g_SummonCtrl
	local data = g_SummonCtrl:GetSummon(summonId)	
	self.m_Blood = self.m_SliderList:GetChild(1)
	self:SetSlider(self.m_Blood.slider, data["hp"], data["max_hp"])
	self.m_Magic = self.m_SliderList:GetChild(2)
	self:SetSlider(self.m_Magic.slider, data["mp"], data["max_mp"])
	local gradeInfo = self:GetUpgradeData()[data["grade"] + 1]
	if gradeInfo ~= nil then
		self.m_Exp = self.m_SliderList:GetChild(3)
		local exp = self:GetCurGradeExp(data)
		self:SetSlider(self.m_Exp.slider,exp,gradeInfo.summon_exp)
	end 
	local attrList = {	data["phy_attack"],
						data["phy_defense"],						
						data["mag_attack"],
						data["mag_defense"],
						data["speed"],
						data["life"]
						}
	for k,v in pairs(self.m_AttrList:GetChildList()) do
		v.number:SetText(attrList[k])
	end
	self.m_PotentialNumber:SetText(data["point"])
end

--当前经验计算
function CSummonRAttrPageBox.GetCurGradeExp(self, data)
	return data["exp"]
end

--获取等级信息
function CSummonRAttrPageBox.GetUpgradeData(self)
	return data.upgradedata.DATA
end

--添加寿命
function CSummonRAttrPageBox.OnAddLifeExp(self)
	CSummonAddLifeView:ShowView(function(oView)
		oView:SetData(self.m_CurSummonId)		
	end)
	g_SummonCtrl:SetSummonRedPoint(self.m_CurSummonId, false)
end 

--添加经验
function CSummonRAttrPageBox.ExpAdd(self)
	CSummonAddExpView:ShowView(function(oView)
		oView:SetData(self.m_CurSummonId)				
	end)
	g_SummonCtrl:SetSummonRedPoint(self.m_CurSummonId, false)
end

--潜力点分配
function CSummonRAttrPageBox.PotentialOper(self)
	local washPointView = nil
	CSummonPotentialView:ShowView(function(oView)
		oView:SetData(self.m_CurSummonId)
		washPointView = oView	
		end)
	g_SummonCtrl:SetSummonRedPoint(self.m_CurSummonId, false)	
	return washPointView
end

function CSummonRAttrPageBox.SetSlider(self, slider, val1, val2)
	slider:SetValue(val1/val2)
	slider:SetSliderText(val1.."/"..val2)
end

return CSummonRAttrPageBox