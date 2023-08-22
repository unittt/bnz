local CAutoPatrolSceneBox = class("CAutoPatrolSceneBox", CBox)

function CAutoPatrolSceneBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self.m_CallBack = cb

	self.m_ItemBtn = self:NewUI(1, CButton, true, false)
	self.m_LvLabel = self:NewUI(2, CLabel)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_JiaoBiaoSprite = self:NewUI(4, CSprite)
	self.m_MonsterTexture = self:NewUI(5, CTexture)

	self.m_ItemBtn:AddUIEvent("click", callback(self, "OnClick"))
	self.m_Index = 0
	self.m_MapID = 0
end

function CAutoPatrolSceneBox.SetAutoPatrolBox(self, data, idx)
	self.m_Index = idx
	self.m_MapID = data.id
	self.m_NameLabel:SetText(data.name)
	self.m_LvLabel:SetText(data.desc)
	self.m_JiaoBiaoSprite:SetActive(false)
	self.m_ItemBtn:SetGroup(10)

	local shapeID = data.icon
	self.m_MonsterTexture:LoadTextureShape("", shapeID, function ()
		self.m_MonsterTexture:SetSize(240, 165)
	end)
end

function CAutoPatrolSceneBox.OnClick(self)
	-- 当前场景ID
	local curSceneID = g_MapCtrl:GetSceneID()
	netscene.C2GSClickTrapMineMap(curSceneID, self.m_MapID)
	g_MapCtrl:SetAutoPatrol(true)
	self.m_ItemBtn:SetSelected(true)
	if self.m_CallBack then
		self.m_CallBack()
	end
end

return CAutoPatrolSceneBox