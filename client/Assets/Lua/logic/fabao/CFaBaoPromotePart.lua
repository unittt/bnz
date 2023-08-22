local CFaBaoPromotePart = class("CFaBaoPromotePart", CPageBase)

function CFaBaoPromotePart.ctor(self, obj)
	CPageBase.ctor(self, obj)

	self.m_SelIndex = 1
	self.m_SelFaBaoId = nil
	self.m_SelAttr = nil
end

function CFaBaoPromotePart.OnInitPage(self)
	self.m_FaBaoScroll = self:NewUI(1, CScrollView)
	self.m_FaBaoGrid = self:NewUI(2, CGrid)
	self.m_FaBaoClone = self:NewUI(3, CBox)

	self.m_NameL = self:NewUI(4, CLabel)
	self.m_Level = self:NewUI(5, CLabel)
	self.m_XianLingL = self:NewUI(6, CLabel)
	self.m_Slider = self:NewUI(7, CSlider)
	self.m_UpGredeBtn = self:NewUI(8, CButton)

	self.m_AttrGrid = self:NewUI(9, CGrid)
	self.m_AttrClone = self:NewUI(10, CBox)

	self.m_PromoteEffectL = self:NewUI(11, CLabel)
	self.m_PromoteConsnmeL = self:NewUI(12, CLabel)
	self.m_PromoteBtn  = self:NewUI(13, CButton)

	self.m_ResetEffectL = self:NewUI(14, CLabel)
	self.m_ResetConsumeL = self:NewUI(15, CLabel)
	self.m_ResetBtn = self:NewUI(16, CButton)

	self:InitContent()

end

function CFaBaoPromotePart.OnShowPage(self)
	CPageBase.OnShowPage(self)

	self.m_FaBaoGrid:Clear()
	self:RefreshFaBaolist()
	self:SetDefaultFaBao()
end

function CFaBaoPromotePart.InitContent(self)
	self.m_UpGredeBtn:AddUIEvent("click", callback(self, "OnUpGradeClick"))
	self.m_PromoteBtn:AddUIEvent("click", callback(self, "OnPromoteClick"))
	self.m_ResetBtn:AddUIEvent("click", callback(self, "OnResetClick"))

	g_FaBaoCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFaBaoEvent"))
end

function CFaBaoPromotePart.RefreshFaBaolist(self)
	--初始化已穿戴法宝
	local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()
	local dInfo = data.fabaodata.INFO

	for i, v in ipairs(fabaolist) do
		local oFaBao = self.m_FaBaoGrid:GetChild(i)
		if oFaBao == nil then
			oFaBao = self.m_FaBaoClone:Clone()
			oFaBao.m_Icon = oFaBao:NewUI(1, CSprite)
			oFaBao.m_Name = oFaBao:NewUI(2, CLabel)
			oFaBao.m_Level = oFaBao:NewUI(3, CLabel)
			oFaBao.m_SelName = oFaBao:NewUI(4, CLabel)

			local groupId = self.m_FaBaoGrid:GetInstanceID()
			oFaBao:SetGroup(groupId)
			oFaBao:AddUIEvent("click", callback(self, "OnFaBaoSelect", i))
			oFaBao:SetActive(true)
			self.m_FaBaoGrid:AddChild(oFaBao)
		end
		local info = dInfo[v.fabao]
		oFaBao.m_Icon:SpriteItemShape(info.icon)
		oFaBao.m_Name:SetText(info.name)
		oFaBao.m_SelName:SetText(info.name)
		oFaBao.m_Level:SetText("等级："..v.level)
	end
	
	self.m_FaBaoGrid:Reposition()
	self.m_FaBaoScroll:ResetPosition()
end

function CFaBaoPromotePart.SetDefaultFaBao(self)
	local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()

	local oFabao = self.m_FaBaoGrid:GetChild(self.m_SelIndex)
	if not oFabao then
		self.m_SelIndex = 1
		oFabao = self.m_FaBaoGrid:GetChild(1)
	end
	oFabao:SetSelected(true)
	local defaultFabao = fabaolist[self.m_SelIndex] --默认选择第一个
	self.m_SelFaBaoId = defaultFabao.id
	self:RefreshFaBaoInfo(defaultFabao)
end

function CFaBaoPromotePart.RefreshFaBaoInfo(self, fabaoInfo)
	local dInfo = data.fabaodata.INFO

	local info = dInfo[fabaoInfo.fabao]
	self.m_NameL:SetText(info.name)
	self.m_Level:SetText("等级："..fabaoInfo.level)

	local xianling = fabaoInfo.xianling or 0
	self.m_XianLingL:SetText("仙灵之气: "..xianling)

	local mExp, mLevel = g_FaBaoCtrl:GetFaBaoMaxExp(fabaoInfo.level)

	local exp = fabaoInfo.exp or 0
	if fabaoInfo.level >= mLevel then
		exp = mExp
	end
	local val = exp/mExp
	self.m_Slider:SetValue(val)
	self.m_Slider:SetSliderText(exp.."/"..mExp)

	local attrInfo = g_FaBaoCtrl:GetFaBaoAttrInfo(fabaoInfo.id)

	--self.m_AttrGrid:Clear()

	local attrList = {"physique", "magic", "strength", "endurance", "agility"}
	local groupId = self.m_AttrGrid:GetInstanceID()

	for i, v in ipairs(attrList) do
		local oAttr = self.m_AttrGrid:GetChild(i)
		if oAttr == nil then
			oAttr = self.m_AttrClone:Clone()
			oAttr.m_AttrLbl = oAttr:NewUI(1, CLabel)
			oAttr.m_AttrVal = oAttr:NewUI(2, CLabel)
			oAttr.m_SelAttrLbl = oAttr:NewUI(3, CLabel)

			oAttr:SetActive(true)
			oAttr:SetGroup(groupId)
			local attr = attrList[i]
			oAttr:AddUIEvent("click", callback(self, "OnAttrClick", attr))
			self.m_AttrGrid:AddChild(oAttr)
		end

		local attrLbl = g_FaBaoCtrl.m_Attr[v]
		local val = attrInfo[v]
		oAttr.m_AttrLbl:SetText(attrLbl)
		oAttr.m_AttrVal:SetText(val)
		oAttr.m_SelAttrLbl:SetText(attrLbl)
	end

	self.m_AttrGrid:Reposition()

	if self.m_SelAttr == nil then
		self.m_SelAttr = attrList[1]
		self.m_AttrGrid:GetChild(1):SetSelected(true)
	end

	self:RefreshAttrInfo()
end

function CFaBaoPromotePart.RefreshAttrInfo(self)
	local promote = g_FaBaoCtrl:GetFaBaoPromote(self.m_SelFaBaoId, self.m_SelAttr)
	promote = math.clamp(promote + 1, 1, 15)

	local dXianlingInfo = data.fabaodata.XIANLING
	local xInfo = dXianlingInfo[self.m_SelAttr]
	local xianling = xInfo.resume[promote].xianling
	local gold = xInfo.resume[promote].gold
	self.m_PromoteEffectL:SetText(string.format("增加%d点%s", xInfo.value, xInfo.desc))
	self.m_PromoteConsnmeL:SetText(xianling.."点仙灵之气")

	if promote-1 <= 0 then  --基础属性不显示重置信息
		self.m_ResetEffectL:SetActive(false)
		self.m_ResetConsumeL:SetActive(false)
	else
		local xianling = xInfo.resume[promote - 1].xianling
		local text1 = string.format("退还%d点仙灵之气, ", xianling)       
		local text2 =  string.format("减少%d点%s", xInfo.value, xInfo.desc)

		self.m_ResetEffectL:SetActive(true)
		self.m_ResetConsumeL:SetActive(true)

		self.m_ResetEffectL:SetText(text1..text2)
		self.m_ResetConsumeL:SetText(gold)
	end
end

--选中法宝，刷新属性信息
function CFaBaoPromotePart.OnFaBaoSelect(self, idx)
	if self.m_SelIndex == idx then
		return
	end
	
	local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()
	local fabaoInfo = fabaolist[idx]

	self.m_SelIndex = idx
	self.m_SelFaBaoId = fabaoInfo.id

	self:RefreshFaBaoInfo(fabaoInfo)
end

--选中法宝的某项属性
function CFaBaoPromotePart.OnAttrClick(self, attr)
	if self.m_SelAttr == attr then
		return
	end
	self.m_SelAttr = attr

	self:RefreshAttrInfo()
end

--法宝升级
function CFaBaoPromotePart.OnUpGradeClick(self)
	local id = self.m_SelFaBaoId
	netfabao.C2GSUpGradeFaBao(id)
end

-- 属性提升
function CFaBaoPromotePart.OnPromoteClick(self)
	local id = self.m_SelFaBaoId
	local op = 1 --提升
	local attr = self.m_SelAttr

	netfabao.C2GSXianLingFaBao(id, op, attr)
	-- local promote = g_FaBaoCtrl:GetFaBaoPromote(id, attr)
	-- promote = math.clamp(promote + 1, 1, 15)
	-- local dXianlingInfo = data.fabaodata.XIANLING[attr]
	-- local needAmount = dXianlingInfo.resume[promote].gold
	-- if g_AttrCtrl.silver < needAmount then
	-- 	g_NotifyCtrl:FloatMsg("银币不足")
	-- 	CCurrencyView:ShowView(function(oView)
	-- 		oView:SetCurrencyView(define.Currency.Type.Silver)
	-- 	end)
	-- else
		
	-- end
end

-- 属性重置
function CFaBaoPromotePart.OnResetClick(self)
	local id = self.m_SelFaBaoId
	local op = 2 --重置
	local attr = self.m_SelAttr

	local fabaoInfo = g_FaBaoCtrl:GetFaBaoById(id)
	if not fabaoInfo.promotelist or table.count(fabaoInfo.promotelist) == 0 then
		g_NotifyCtrl:FloatMsg("基础属性不能重置")
		return
	end

	for i, v in ipairs(fabaoInfo.promotelist) do
		if v.attr == attr then
			if not v.promote or v.promote <= 0 then
				g_NotifyCtrl:FloatMsg("基础属性不能重置")
				return
			end
		end
	end

	local promote = g_FaBaoCtrl:GetFaBaoPromote(id, attr)
	promote = math.clamp(promote + 1, 1, 15)
	local dXianlingInfo = data.fabaodata.XIANLING[attr]
	local needAmount = dXianlingInfo.resume[promote].gold
	if g_AttrCtrl.silver < needAmount then
		g_NotifyCtrl:FloatMsg("银币不足")
		-- CCurrencyView:ShowView(function(oView)
		-- 	oView:SetCurrencyView(define.Currency.Type.Silver)
		-- end)
		g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)
	else
		netfabao.C2GSXianLingFaBao(id, op, attr)
	end
end

function CFaBaoPromotePart.OnFaBaoEvent(self, oCtrl)
	if oCtrl.m_EventID == define.FaBao.Event.RefreshFaBaoInfo then
		self:RefreshFaBaolist()
		self:RefreshFaBaoInfo(oCtrl.m_EventData)
	end
end

return CFaBaoPromotePart