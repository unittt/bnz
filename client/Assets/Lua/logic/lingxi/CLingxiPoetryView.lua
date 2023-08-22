local CLingxiPoetryView = class("CLingxiPoetryView", CViewBase)

function CLingxiPoetryView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Lingxi/LingxiPoetryView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
	self.m_Test = false
end

function CLingxiPoetryView.OnCreateView(self)
	self.m_Widget = self:NewUI(1, CWidget)
	self.m_MaskBg = self:NewUI(2, CTexture)
	self.m_BoxClone = self:NewUI(3, CBox)
	self.m_CloseBtn = self:NewUI(4, CButton)
	self.m_Grid = self:NewUI(5, CGrid)

	self:InitContent()
end

function CLingxiPoetryView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Widget, 10, 10)
	UITools.ResizeToRootSize(self.m_MaskBg, 10, 10)

	self.m_BoxClone:SetActive(false)
	self.m_CloseBtn:SetActive(false)

	self.m_Widget.m_IgnoreCheckEffect = true
	self.m_Widget:AddEffect("Screen", "ui_eff_0031")

	-- local typetween = self.m_DescLbl:GetComponent(classtype.TypewriterEffect)
	-- typetween.enabled = true
	-- typetween:ResetToBeginning()
	-- typetween.onFinished = function ()
		
	-- end

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_Widget:AddUIEvent("click", callback(self, "OnClickWidget"))

	-- g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	-- g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMapEvent"))
end

function CLingxiPoetryView.RefreshUI(self, pbdata)
	self.m_PoetryData = pbdata
	if self.m_Test then
		self.m_PoetryConfig = {"身无彩凤双飞翼4", "身无彩凤双飞翼3", "身无彩凤双飞翼2", "身无彩凤双飞翼1"}
		self.m_ShowPoetryData = {}
		table.copy(self.m_PoetryConfig, self.m_ShowPoetryData)
	else
		local config = table.randomvalue(data.lingxidata.POEM)
		self.m_PoetryConfig = {}
		for k,v in ipairs(config.content) do
			table.insert(self.m_PoetryConfig, 1, v)
		end
		self.m_ShowPoetryData = {}
		table.copy(self.m_PoetryConfig, self.m_ShowPoetryData)
	end
	self.m_CloseBtn:SetActive(false)

	self:SetPoetryList()
	self.m_PoetryCount = #self.m_PoetryConfig + 1
	self.m_PoetryIndex = self.m_PoetryCount

	self.m_CharPerSec = 1
	local oTime = self.m_PoetryData and self.m_PoetryData.sec or 30
	self.m_CharPerSec = math.floor((string.len(self.m_ShowPoetryData[1])/3) / (oTime/#self.m_PoetryConfig))
	if self.m_CharPerSec < 1 then
		self.m_CharPerSec = 1
	end

	self:SetEffect()
end

function CLingxiPoetryView.SetEffect(self)
	local oChild = self.m_Grid:GetChild(self.m_PoetryIndex)
	oChild:SetActive(true)
	local typetween = oChild:NewUI(2, CLabel):GetComponent(classtype.TypewriterEffect)
	typetween.enabled = true
	typetween.charsPerSecond = self.m_CharPerSec
	typetween:ResetToBeginning()
	typetween.onFinished = function ()
		self.m_PoetryIndex = self.m_PoetryIndex - 1
		if self.m_PoetryIndex >= 2 then
			self:SetEffect()
		else
			self.m_CloseBtn:SetActive(true)
		end
	end
end

function CLingxiPoetryView.SetPoetryList(self)
	local optionCount = #self.m_ShowPoetryData
	local GridList = self.m_Grid:GetChildList() or {}
	local oPoetryBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPoetryBox = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oPoetryBox = GridList[i]
			end
			self:SetPoetryBox(oPoetryBox, self.m_ShowPoetryData[i])
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

	self.m_Grid:Reposition()
end

function CLingxiPoetryView.SetPoetryBox(self, oPoetryBox, oData)
	-- oPoetryBox:SetActive(true)

	oPoetryBox:NewUI(2, CLabel):SetText(oData)

	self.m_Grid:AddChild(oPoetryBox)
	self.m_Grid:Reposition()
end

------------------以下是点击事件----------------

function CLingxiPoetryView.OnClickWidget(self)
	-- self.m_PoetryIndex = 1

	-- for k,v in pairs(self.m_Grid:GetChildList()) do
	-- 	v:SetActive(true)
	-- 	local typetween = v:NewUI(2, CLabel):GetComponent(classtype.TypewriterEffect)
	-- 	typetween:Finish()
	-- end
	-- self.m_CloseBtn:SetActive(true)
end

function CLingxiPoetryView.OnHideView(self)
	g_LingxiCtrl.m_IsInLingxiPoetry = false
	for k,v in pairs(g_LingxiCtrl.m_PoetryEndCbList) do
		if v then v() end
	end
	g_LingxiCtrl.m_PoetryEndCbList = {}
end

return CLingxiPoetryView