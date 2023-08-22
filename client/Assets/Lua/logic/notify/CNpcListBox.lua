local CNpcListBox = class("CNpcListBox", CBox)

function CNpcListBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Scroll = self:NewUI(1, CScrollView)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_NpcBoxClone = self:NewUI(3, CBox)
	self.m_BgSprite = self:NewUI(4, CSprite)
	self.m_ContentAnchor = self:NewUI(5, CWidget)
	
	self:SetActive(false)
	self.m_NpcBoxClone:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self.m_BgSprite, callback(self, "SetActive", false))
end

-- 主界面NpcList信息列表
function CNpcListBox.InitNpcInfoList(self, npcInfoList)
	printc("点击重叠Npc展示信息")
	if not npcInfoList or #npcInfoList == 0 then
		return
	end
	local oNGUICamera = g_CameraCtrl:GetNGUICamera()
	local oUICamera = g_CameraCtrl:GetUICamera()
	local vTouchPos = oNGUICamera.lastEventPosition
	local vTouchWorldPos = oUICamera:ScreenToWorldPoint(Vector3.New(vTouchPos.x, vTouchPos.y, 0))
	local vTouchLocalPos = self:InverseTransformPoint(vTouchWorldPos)
	self.m_ContentAnchor:SetLocalPos(vTouchLocalPos)

	local maxlen = #npcInfoList > 4 and 4 or #npcInfoList
	local h = 24 + 81 * maxlen
	self.m_BgSprite:SetHeight(h)

	local npcBoxList = self.m_Grid:GetChildList()
	local oNpcBox = nil
	for i,v in ipairs(npcInfoList) do
		if i > #npcBoxList then
			oNpcBox = self.m_NpcBoxClone:Clone()
			oNpcBox.m_Icon = oNpcBox:NewUI(1, CSprite)
			oNpcBox.m_Name = oNpcBox:NewUI(2, CLabel)
			self.m_Grid:AddChild(oNpcBox)
		else
			oNpcBox = npcBoxList[i]
		end
		oNpcBox:AddUIEvent("click", function ()
			self:SetActive(false)
			if v.cb then
				v.cb()
				v.cb = nil
			end
		end)
		oNpcBox.m_Name:SetText(v.name)
		oNpcBox.m_Icon:SpriteAvatar(v.shape)
		oNpcBox:SetName("NpcBox_" .. v.name)
		oNpcBox:SetActive(true)
	end

	for i=#npcInfoList+1,#npcBoxList do
		oNpcBox = npcBoxList[i]
		if not oNpcBox then
			break
		end
		oNpcBox:SetActive(false)
	end
	self:SetActive(true)
	self.m_Scroll:ResetPosition()
	self.m_BgSprite.m_UIWidget:ResizeCollider()
	UITools.NearTarget(self.m_ContentAnchor, self.m_BgSprite, enum.UIAnchor.Side.Center)
	local function delay()
		self.m_Scroll:ResetPosition()
		return false
	end
	Utils.AddTimer(delay, 0.1, 0.1) 
end

return CNpcListBox

