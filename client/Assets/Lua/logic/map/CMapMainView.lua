local CMapMainView = class("CMapMainView", CViewBase)
CMapMainView.cityDataDic = {}
function CMapMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Map/MapMainView.prefab", cb)
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CMapMainView.OnCreateView(self)
	self.m_WorldMapPart = self:NewPage(1, CWorldMapPart)
	self.m_MiniMapPart = self:NewPage(2, CMiniMapPart)

	self.m_WorldMapTweenAlpha = self.m_WorldMapPart:GetComponent(classtype.TweenAlpha)
	self.m_WorldMapTweenScale = self.m_WorldMapPart:GetComponent(classtype.TweenScale)
	self.m_WorldMapTweenPosition = self.m_WorldMapPart:GetComponent(classtype.TweenPosition)
	self.m_MiniMapTweenAlpha = self.m_MiniMapPart:GetComponent(classtype.TweenAlpha)
	self.m_MiniMapTweenScale = self.m_MiniMapPart:GetComponent(classtype.TweenScale)
	self.m_MiniMapTweenPosition = self.m_MiniMapPart:GetComponent(classtype.TweenPosition)
end

function CMapMainView.GetCityData(self, mapID)
	local mapInfo = CMapMainView.cityDataDic[mapID]
	if mapInfo then
		return mapInfo
	end
	local cityID = 101000
	-- 特殊(镇魔塔)
	if g_ZhenmoCtrl:IsInZhenmoTask() then
		cityID = 103000
	end
	return CMapMainView.cityDataDic[cityID]
end

function CMapMainView.ShowMapSpecificPart(self, index, tween)
	index = index or 1
	self:ShowSubPage(self.m_PageList[index])
	if tween then
		if index == 1 then
			self.m_WorldMapTweenAlpha:ResetToBeginning()
			self.m_WorldMapTweenAlpha.from = 0
			self.m_WorldMapTweenAlpha.to = 1
			self.m_WorldMapTweenAlpha.duration = 0.5
			self.m_WorldMapTweenAlpha:Play(true)

			self.m_WorldMapTweenScale:ResetToBeginning()
			self.m_WorldMapTweenScale.from = Vector3.New(0.1, 0.1, 1)
			self.m_WorldMapTweenScale.to = Vector3.one
			self.m_WorldMapTweenScale.duration = 0.5
			self.m_WorldMapTweenScale:Play(true)

			self.m_WorldMapTweenPosition:ResetToBeginning()
			self.m_WorldMapTweenPosition.from = self.m_MiniMapPart.m_SearchBtn:GetLocalPos()
			self.m_WorldMapTweenPosition.to = Vector3.zero
			self.m_WorldMapTweenPosition.duration = 0.5
			self.m_WorldMapTweenPosition:Play(true)
		else
			self.m_MiniMapTweenAlpha:ResetToBeginning()
			self.m_MiniMapTweenAlpha.from = 0
			self.m_MiniMapTweenAlpha.to = 1
			self.m_MiniMapTweenAlpha.duration = 0.5
			self.m_MiniMapTweenAlpha:Play(true)

			self.m_MiniMapTweenScale:ResetToBeginning()
			self.m_MiniMapTweenScale.from = Vector3.New(0.1, 0.1, 1)
			self.m_MiniMapTweenScale.to = Vector3.one
			self.m_MiniMapTweenScale.duration = 0.5
			self.m_MiniMapTweenScale:Play(true)

			self.m_MiniMapTweenPosition:ResetToBeginning()
			local mapInfo = self:GetCityData(g_MapCtrl:GetMapID())
			self.m_MiniMapTweenPosition.from = mapInfo.pos
			self.m_MiniMapTweenPosition.to = Vector3.zero
			self.m_MiniMapTweenPosition.duration = 0.5
			self.m_MiniMapTweenPosition:Play(true)
		end
	end
end

return CMapMainView