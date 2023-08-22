local CPopupBox = class("CPopupBox", CBox)

function CPopupBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ButtonBg = self:NewUI(1, CSprite)
	self.m_MainBtn = self:NewUI(2, CButton, true ,false)
	self.m_BtnGrid = self:NewUI(3, CGrid)
	self.m_BoxClone = self:NewUI(4, CBox)
	self.m_MainLabel = self:NewUI(5, CLabel)
	self.m_ScrollView = self:NewUI(6, CScrollView)

	self.m_Index = 1
	self.m_SelectedSubMenu = nil
	self.m_SelectedIndex = -1
	self.m_Callback = nil
	self.m_Menus = {}

	self.m_BoxClone:SetActive(false)
	self.m_TweenHeight = self.m_ButtonBg:GetComponent(classtype.TweenHeight)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnTouchOutDetect"))
end

function CPopupBox.OnTouchOutDetect(self)
	if self.m_ButtonBg:GetActive() then
		self:ClickSubMenu(self.m_SelectedSubMenu)
	end
end

--设置回调，回调函数带参以方便返回当前控件 
--example:OnValueChange(oBox)
--@param cb 回调函数
function CPopupBox.SetCallback(self, cb)
	self.m_Callback = cb
end

--设置父菜单的文本
function CPopupBox.SetMainMenu(self, sMenu)
	self.m_MainLabel:SetText(sMenu)
end

--清空弹出列表
function CPopupBox.Clear(self)
	self.m_Index = 1
	self.m_SelectedIndex = -1
	self.m_SelectedSubMenu = nil
	self.m_BtnGrid:Clear()
	self:ResizeBg()
	self.m_ScrollView:ResetPosition()
end

--[[添加子菜单数据，默认选中第一个子菜单
	@param sMenu 子菜单文本
	@param dExtra 子菜单绑定的额外数据]]
function CPopupBox.AddSubMenu(self, sMenu, dExtra)
	local box = self.m_BoxClone:Clone(false)
	box.m_Label = box:NewUI(1, CLabel)
	box.m_Label:SetText(sMenu)
	box.m_ExtraData = dExtra
	box.m_Index = self.m_Index
	local callback = function()
		self:ClickSubMenu(box)
	end
	box:AddUIEvent("click", callback)
	box:SetActive(true)
	self.m_BtnGrid:AddChild(box)
	self:ResizeBg()

	if self.m_Index == 1 then
		self:SetSelectedIndex(1)
	end

	self.m_Index = self.m_Index + 1
end

function CPopupBox.ClickSubMenu(self, oMenu)
	self:SetSelectedIndex(oMenu.m_Index)
	self.m_ButtonBg:SetActive(false)
	self.m_TweenHeight:Toggle()
end

--设置选定的下标
function CPopupBox.SetSelectedIndex(self, iIndex)
	local oMenu = self.m_BtnGrid:GetChild(iIndex)
	if not oMenu then
		print("not index .."..iIndex)
		return
	end
	print("index .."..iIndex)

	self.m_SelectedSubMenu = oMenu
	self.m_SelectedIndex = oMenu.m_Index
	self:SetMainMenu(oMenu.m_Label:GetText())
	if self.m_Callback then
		self.m_Callback(self)
	end
end

--返回选中的子菜单
--@return 子菜单
function CPopupBox.GetSelectedSubMenu(self)
	return self.m_SelectedSubMenu
end

--返回选中的子菜单下标
--@return 子菜单下标
function CPopupBox.GetSelectedIndex(self)
	return self.m_SelectedIndex
end

--返回子菜单的额外数据
--@return extradata,失败为nil
function CPopupBox.GetExtraDataFromSubMenu(self, oSubMenu)
	if oSubMenu then
		return oSubMenu.m_ExtraData
	end
	return nil
end

function CPopupBox.GetMenuCount(self)
	return self.m_BtnGrid:GetCount()
end

function CPopupBox.ResizeBg(self)
	local _,h = self.m_BtnGrid:GetCellSize()
	local upperH = 400
	self.m_TweenHeight.to = math.min((math.floor((self.m_Index + 1)/2) + 0.5) * h + 15, upperH + 20)
end

return CPopupBox