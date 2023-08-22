local CDungeonMainView = class("CDungeonMainView", CViewBase)
local min = math.min
local max = math.max

function CDungeonMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Dungeon/DungeonMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CDungeonMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_TitleL = self:NewUI(3, CLabel)
	self.m_DungeonGrid = self:NewUI(4, CGrid)
	self.m_DungeonBoxClone = self:NewUI(5, CBox)
	self.m_EliteBox = self:NewUI(6, CBox)
	self.m_TagWidget = self:NewUI(7, CWidget)
	self.m_TagGrid = self:NewUI(8, CGrid)
	self.m_TagItem = self:NewUI(9, CBox)
	self.m_CommonPanel = self:NewUI(10, CWidget)
	self.m_CommonScrollView = self:NewUI(11, CScrollView)

	self.m_TagInfo = {}
	self.m_SizeAniCfg = {
		min = 20,
		max = 684,
		minstep = 20,
	} 
	self:InitContent()
end

function CDungeonMainView.InitContent(self)
	self.m_DungeonBoxClone:SetActive(false)
	self.m_CloseBtn:SetActive(false)
	self.m_EliteBox:SetActive(false)
	self.m_TagWidget:SetActive(false)
	self.m_CommonPanel:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TagItem:SetActive(false)
	-- self:RefreshDungeonGrid()
	-- self:InitTags()
end

--界面加载完成时调用
function CDungeonMainView.LoadDone(self)
	CViewBase.LoadDone(self)
	self:ShowEnterAni()
end

function CDungeonMainView.ShowEnterAni(self)
	local _,H = self.m_ScrollView:GetSize()
	local W = self.m_SizeAniCfg.min
	self.m_ScrollView:SetRect(0, 0, W, H)
	local iStep = self.m_SizeAniCfg.max/5
	local function doExpandAni()
		if Utils.IsNil(self) then
			return false
		end
		self.m_CommonScrollView:SetActive(false)
		self.m_CommonScrollView:SetActive(true)
		W = min( W + iStep, self.m_SizeAniCfg.max)
		iStep = max(iStep*0.8, self.m_SizeAniCfg.minstep)
		self.m_ScrollView:SetRect(0, 0, W, H)
		if W >= self.m_SizeAniCfg.max then 
			self.m_CloseBtn:SetActive(true)
			if table.count(self.m_TagInfo) > 0 then
				self.m_TagWidget:SetActive(true)
			end
			return false
		end
		return true
	end
	Utils.AddTimer(doExpandAni, 0.05, 0.1)
end

function CDungeonMainView.InitTags(self)
	local tagInfo = {}
	for idx, name in pairs(self.m_TagInfo) do
		table.insert(tagInfo, {idx = idx, spriteName = name})
	end
	table.sort(tagInfo, function(a, b)
		return a.idx < b.idx
	end)
	for i, v in ipairs(tagInfo) do
		local oTag = self.m_TagItem:Clone()
		oTag.nameSpr = oTag:NewUI(1, CSprite)
		oTag.lineSpr = oTag:NewUI(2, CSprite)
		oTag.tailSpr = oTag:NewUI(3, CSprite)
		oTag.selNameSpr = oTag:NewUI(4, CSprite)
		oTag.nameSpr:SetSpriteName(v.spriteName.."_2")
		oTag.selNameSpr:SetSpriteName(v.spriteName)
		oTag.lineSpr:SetActive(i~=1)
		oTag.tailSpr:SetActive(i==#tagInfo)
		self.m_TagGrid:AddChild(oTag)
		oTag:SetActive(true)
		if i==1 then
			oTag:SetSelected(true)
			self:OnClickTag(v.idx)
		end
		oTag:AddUIEvent("click", callback(self, "OnClickTag", v.idx))
	end
end

-- 由协议判断 iType: 1 普通副本 2 精英副本
function CDungeonMainView.RefreshDungeonGrid(self, iType)
	self.m_DungeonGrid:Clear()
	local tData = data.fubendata.DATA
	local mSeque = {}
	for i,v in pairs(tData) do
		table.insert(mSeque, v.fuben_id)
	end
	table.sort(mSeque)
	if not iType or iType == 1 then
		self.m_CommonPanel:SetActive(true)
		for i=1,#mSeque do
			local dDungeon = tData[mSeque[i]]
			if dDungeon.is_open == 1 then
				local iTheme = dDungeon.fuben_theme
				local oBox = self:CreateDungeonBox()
				self:UpdateDungeonBox(oBox, dDungeon)
				self.m_DungeonGrid:AddChild(oBox)
				if not self.m_TagInfo[iTheme] then
					self.m_TagInfo[iTheme] = "h7_xiaying"
				end
			end
		end
	elseif iType == 2 then
		-- if g_OpenSysCtrl:GetOpenSysState(define.System.JyFuben) then
			self:UpdateEliteBox()
			self.m_EliteBox:SetActive(true)
		-- end
	end
	self.m_DungeonGrid:Reposition()
end

function CDungeonMainView.CreateDungeonBox(self)
	local oBox = self.m_DungeonBoxClone:Clone()
	oBox.m_TitleL = oBox:NewUI(1, CLabel)
	oBox.m_Texture = oBox:NewUI(2, CTexture)
	oBox.m_TypeSpr = oBox:NewUI(3, CSprite)
	oBox.m_DescL = oBox:NewUI(4, CLabel)
	oBox.m_EnterBtn = oBox:NewUI(5, CButton)
	oBox.m_TypeSpr:SetActive(false)
	return oBox
end

function CDungeonMainView.UpdateEliteBox(self)
	local dDungeon = DataTools.GetDungeonData(1)
	if not dDungeon then return end
	-- self.m_TagInfo[dDungeon.fuben_theme] = "h7_xiantu"
	if not self.m_HasInitedElite then
		self.m_EliteBox.m_TitleL = self.m_EliteBox:NewUI(1, CLabel)
		self.m_EliteBox.m_Texture = self.m_EliteBox:NewUI(2, CTexture)
		self.m_EliteBox.m_DescL = self.m_EliteBox:NewUI(4, CLabel)
		self.m_EliteBox.m_EnterBtn = self.m_EliteBox:NewUI(5, CButton)
		self.m_EliteBox.m_Bg = self.m_EliteBox:NewUI(6, CWidget)
		-- local _, iBgHeight = self.m_EliteBox.m_Bg:GetSize()
		-- self.m_EliteBox.m_Bg:SetSize(self.m_SizeAniCfg.max, iBgHeight)
		self.m_HasInitedElite = true
	end
	self.m_EliteBox.m_TitleL:SetText(dDungeon.name)
	local sDesc = dDungeon.desc
	sDesc = string.replace(sDesc, "\\n", "\n")
	self.m_EliteBox.m_DescL:SetText(sDesc)
	local sTextureName = "Texture/Minimap/minimap_"..dDungeon.minimap..".jpg"
	g_ResCtrl:LoadAsync(sTextureName, function(tex, errcode)
		if tex then
			self.m_EliteBox.m_Texture:SetMainTexture(tex)
		else
			print(errcode)
		end
	end)
	self.m_EliteBox.m_EnterBtn:AddUIEvent("click", callback(self, "RequestEnterElite"))
end

function CDungeonMainView.UpdateDungeonBox(self, oBox, dDungeon)
	oBox:SetActive(true)
	oBox.m_TitleL:SetText(dDungeon.name)
	if dDungeon.fuben_theme == 1 then
		oBox.m_TypeSpr:SetSpriteName("h7_xiaying_1")
	else
		oBox.m_TypeSpr:SetSpriteName("h7_xiantu_1")
	end
	oBox.m_DescL:SetText(dDungeon.desc)
	oBox.m_EnterBtn:AddUIEvent("click", callback(self, "RequestEnter", dDungeon.fuben_id))
	local function SetTexture(prefab, errcode)
		if prefab then
			oBox.m_Texture:SetMainTexture(prefab)
		else
			print(errcode)
		end
	end
	local sTextureName = "Texture/Minimap/minimap_"..dDungeon.minimap..".jpg"
	g_ResCtrl:LoadAsync(sTextureName, SetTexture)
end

function CDungeonMainView.RequestEnter(self, iDungeonId)
	self:CloseView()
	netopenui.C2GSOpenFBComfirm(iDungeonId)
end

function CDungeonMainView.RequestEnterElite(self)
	self:CloseView()
	nethuodong.C2GSJoinJYFuben()
end

function CDungeonMainView.OnClickTag(self, idx)
	self.m_CommonPanel:SetActive(idx == 1)
	self.m_EliteBox:SetActive(idx == 2)
end

return CDungeonMainView