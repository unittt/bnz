local COnlyEmojiView = class("COnlyEmojiView", CViewBase)

function COnlyEmojiView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Barrage/OnlyEmojiView.prefab", cb)

	self.m_DepthType = "BeyondTop"
	self.m_ExtendClose = "ClickOut"
end

function COnlyEmojiView.OnCreateView(self)
	self.m_RightWidget = self:NewUI(1, CWidget)
	self.m_EmojiBox = self:NewUI(2, CBox)
	self.m_Container = self:NewUI(3, CWidget)
	self.m_EmojiPage = self.m_EmojiBox:NewUI(1, CFactoryPartScroll)

	self.m_SendFunc = nil
	self:InitContent()
end


function COnlyEmojiView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self:RefreshUI()
end

function COnlyEmojiView.RefreshUI(self)
	local oPage = self.m_EmojiPage
	oPage:SetPartSize(7, 3)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.m_Sprtite = oBox:NewUI(1, CSprite)
			local sPrefix = string.format("#%d_", dData.idx)
			oBox.m_Sprtite:SetSpriteName(sPrefix.."00")
			oBox.m_Sprtite:SetNamePrefix(sPrefix)
			oBox.m_Sprtite:SetFramesPerSecond(4)
			oBox.m_Sprtite:AddUIEvent("click", callback(self, "OnEmoji", dData.idx))
			oBox:SetActive(true)
			return oBox
		end
	end
	oPage:SetFactoryFunc(factory)
	local function data()
		local t = {}
		for i= 1, 40 do
			table.insert(t, {idx = i})
		end
		return t
	end
	oPage:SetDataSource(data)
	oPage:RefreshAll()
end

function COnlyEmojiView.OnEmoji(self, idx)
	self:Send("#"..tostring(idx))
end

function COnlyEmojiView.SetSendFunc(self, f)
	self.m_SendFunc = f
end

function COnlyEmojiView.Send(self, s)
	if self.m_SendFunc then
		self.m_SendFunc(s)
	end
end

function COnlyEmojiView.SetWidget(self, oWidget)
	UITools.NearTarget(oWidget, self.m_Container, enum.UIAnchor.Side.Right)
end

return COnlyEmojiView