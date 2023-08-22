local CSummonRAttrPart = class("CSummonRAttrPart", CBox)

function CSummonRAttrPart.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self.m_AddExpBtn = nil
	self.m_AddLifeBtn = nil
	self:InitContent()
end

function CSummonRAttrPart.InitContent(self)
	self.m_SliderList = self:NewUI(1,CGrid)
	local function InitSlider(obj, idx)
		local box = CBox.New(obj)
		box.slider = box:NewUI(2, CSlider)
		if idx == 3 then 
			box.btn = box:NewUI(3, CButton)
			box.btn:AddUIEvent("click", callback(self, "ExpAdd"))
			self.m_AddExpBtn = box.btn
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
			self.m_AddLifeBtn = box.btn
		end 
		return box
	end
	self.m_AttrList:InitChild(InitAttr)
end

function CSummonRAttrPart.SetInfo(self, data)
	self.m_CurSummonId = data.id
	local g_SummonCtrl = g_SummonCtrl
	self.m_Blood = self.m_SliderList:GetChild(1)
	self:SetSlider(self.m_Blood.slider, data.hp, data.max_hp)
	self.m_Magic = self.m_SliderList:GetChild(2)
	self:SetSlider(self.m_Magic.slider, data.mp, data.max_mp)
	local gradeInfo = SummonDataTool.GetUpgradeData(data.grade + 1)
	if gradeInfo ~= nil then
		self.m_Exp = self.m_SliderList:GetChild(3)
		local exp = data.exp
		self:SetSlider(self.m_Exp.slider,exp,gradeInfo.summon_exp)
	end 
	local attrList = {	data["phy_attack"],
						data["phy_defense"],						
						data["mag_attack"],
						data["mag_defense"],
						data["speed"],
						data["life"]
						}
	local bSpc = SummonDataTool.IsExpensiveSumm(data.type)
	self.m_AttrList:GetChild(6).btn:SetActive(not bSpc)
	for k,v in pairs(self.m_AttrList:GetChildList()) do
		if k == 6 and bSpc then
			v.number:SetText("永生") --神兽
		else
			v.number:SetText(attrList[k])
		end
	end
end

--添加寿命
function CSummonRAttrPart.OnAddLifeExp(self)
	CSummonAddLifeView:ShowView(function(oView)
		oView:SetData(self.m_CurSummonId)
		UITools.NearTarget(self.m_AttrList, oView.m_Bg, enum.UIAnchor.Side.Bottom, Vector2.New(0, 0))
	end)
end 

--添加经验
function CSummonRAttrPart.ExpAdd(self)
	CSummonAddExpView:ShowView(function(oView)
		oView:SetData(self.m_CurSummonId)
		UITools.NearTarget(self.m_SliderList, oView.m_Bg, enum.UIAnchor.Side.Bottom, Vector2.New(0, 0))
	end)
end

--潜力点分配
function CSummonRAttrPart.PotentialOper(self)
	local washPointView = nil
	CSummonPotentialView:ShowView(function(oView)
		oView:SetData(self.m_CurSummonId)
		washPointView = oView	
		end)
	return washPointView
end

function CSummonRAttrPart.SetSlider(self, slider, val1, val2)
	slider:SetValue(val1/val2)
	slider:SetSliderText(val1.."/"..val2)
end

function CSummonRAttrPart.HandleItemTip(self, iItemId)
	if iItemId == 10047 or iItemId == 10038 then
		self.m_AddLifeBtn:AddEffect("Rect")
	elseif iItemId == 10033 then
		self.m_AddExpBtn:AddEffect("Rect")
	end
end

function CSummonRAttrPart.RemoveItemTip(self)
	self.m_AddExpBtn:DelEffect("Rect")
	self.m_AddLifeBtn:DelEffect("Rect")
end

return CSummonRAttrPart