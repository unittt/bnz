local CMasterTeachView = class("CMasterTeachView", CViewBase)

function CMasterTeachView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Master/MasterTeachView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CMasterTeachView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CheckBtn = self:NewUI(2, CButton)
	self.m_ResultBtn = self:NewUI(3, CButton)
	self.m_CheckRedPoint = self:NewUI(4, CSprite)
	self.m_ResultRedPoint = self:NewUI(5, CSprite)
	self.m_CheckPart = self:NewPage(6, CMasterCheckPart)
	self.m_ResultPart = self:NewPage(7, CMasterResultPart)
	self.m_TabGrid = self:NewUI(8, CGrid)
	self.m_BgSp = self:NewUI(9, CSprite)

	self.m_IsNotCheckOnLoadShow = true

	self:InitContent()
end

function CMasterTeachView.InitContent(self)
	self.m_CheckBtn:SetGroup(self:GetInstanceID())
	self.m_ResultBtn:SetGroup(self:GetInstanceID())

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CheckBtn:AddUIEvent("click", callback(self, "OnClickCheckBtn"))
	self.m_ResultBtn:AddUIEvent("click", callback(self, "OnClickResultBtn"))
end

function CMasterTeachView.RefreshUI(self)
	
end

function CMasterTeachView.ShowSubPageByIndex(self, iIndex, ...)
	if iIndex == 1 then
		self.m_CheckBtn:SetSelected(true)
	elseif iIndex == 2 then
		self.m_ResultBtn:SetSelected(true)
	else
		self.m_CheckBtn:SetSelected(true)
	end
	CGameObjContainer.ShowSubPageByIndex(self, iIndex, ...)
end

function CMasterTeachView.OnClickCheckBtn(self)
	self:ShowSubPageByIndex(1)
end

function CMasterTeachView.OnClickResultBtn(self)
	self:ShowSubPageByIndex(2)
end

return CMasterTeachView