local CHotTopicPart = class("CHotTopicPart", CPageBase)

function CHotTopicPart.ctor(self, cb)
	CPageBase.ctor(self, cb)

	self.m_SelectID = 1
end

function CHotTopicPart.OnInitPage(self)
	self.m_HdScroll = self:NewUI(1, CScrollView)
	self.m_HdGrid = self:NewUI(2, CGrid)
	self.m_HdClone = self:NewUI(3, CBox)
	self.m_HdTexture = self:NewUI(4, CTexture)
	self.m_Btn = self:NewUI(5, CButton)

	self:InitContent()
end

function CHotTopicPart.InitContent(self)
	self.m_Btn:AddUIEvent("click", callback(self, "OnBtnClick"))

	self:InitHuodongInfo()
end

function CHotTopicPart.InitHuodongInfo(self)
	local list = g_HotTopicCtrl:GetHuodongList()
	local dConfig = data.huodongdata.HOTTOPIC
	local groupId = self.m_HdGrid:GetInstanceID()

	self.m_HdGrid:Clear()
	for i, v in ipairs(list) do
		local oClone = self.m_HdGrid:GetChild(i)
		if oClone == nil then
			oClone = self.m_HdClone:Clone()
			oClone.m_Name = oClone:NewUI(1, CLabel)

			oClone:AddUIEvent("click", callback(self, "OnHuodongClick", v))

			oClone:SetGroup(groupId)
			oClone:SetActive(true)
			self.m_HdGrid:AddChild(oClone)
		end

		local data = dConfig[v.hd_id]
		oClone.m_Name:SetText(data.name)
	end
	self.m_HdGrid:Reposition()
	self.m_HdScroll:ResetPosition()

	-- 默认选中第一个 --
	local oChild = self.m_HdGrid:GetChild(1)
	if oChild then
		oChild:SetSelected(true)
	end

	if #list == 0 then
		return
	end

	self.m_SelectID = list[1].hd_id
	local tName = g_HotTopicCtrl:GetTextureNameById(list[1].hd_id)
	self:RefreshTexture(tName)
end

function CHotTopicPart.RefreshTexture(self, name)
	if not name or string.len(name) == 0 then 
		return 
	end

	local sTextureName = string.format("Texture/HotTopic/%s.png", name)

	g_ResCtrl:LoadAsync(sTextureName, function(tex, errcode)
		if tex then
			self.m_HdTexture:SetMainTexture(tex)
		else
			print(errcode)
		end
	end)
end

function CHotTopicPart.OnHuodongClick(self, info)
	if self.m_SelectID == info.hd_id then
		return
	end
	self.m_SelectID = info.hd_id

	local tName = g_HotTopicCtrl:GetTextureNameById(info.hd_id)
	self:RefreshTexture(tName)
end

function CHotTopicPart.OnBtnClick(self)
	g_HotTopicCtrl:OpenHuodongView(self.m_SelectID)
	CHotTopicView:CloseView()
end

return CHotTopicPart