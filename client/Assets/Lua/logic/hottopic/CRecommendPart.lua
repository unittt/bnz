local CRecommendPart = class("CRecommendPart", CPageBase)

function CRecommendPart.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function CRecommendPart.OnInitPage(self)
	self.m_BtnGrid = self:NewUI(1, CGrid)
	self.m_BtnClone = self:NewUI(2, CBox)
	self.m_Scroll = self:NewUI(3, CScrollView)	
	self.m_Grid = self:NewUI(4, CGrid)
	self.m_BoxClone = self:NewUI(5, CBox)

	self:InitBtns()
	self:InitContent()
end

function CRecommendPart.InitBtns(self)
	self.m_BtnClone:SetActive(true)
	self.m_BtnClone.m_Name = self.m_BtnClone:NewUI(1, CLabel)
	self.m_BtnClone.m_Name:SetText("内容预告")
	self.m_BtnClone:ForceSelected(true)

	self.m_BtnGrid:Reposition()
end

function CRecommendPart.InitContent(self)
	-- 预告内容
	local recommendInfo = g_RecommendCtrl:GetRecommendInfo()

	for i, v in ipairs(recommendInfo) do
		local oBox = self:CreateBox(i)
		self:SetInfo(i, oBox, v)
	end

	self.m_Grid:Reposition()
	self.m_Scroll:ResetPosition()
end

function CRecommendPart.CreateBox(self, idx)
	local oBox = self.m_Grid:GetChild(idx)
	if not oBox then
		oBox = self.m_BoxClone:Clone()
		oBox.m_Icon = oBox:NewUI(1, CSprite)
		oBox.m_Content = oBox:NewUI(2, CLabel)

		oBox:SetActive(true)
		self.m_Grid:AddChild(oBox)
	end
	return oBox
end

function CRecommendPart.SetInfo(self, idx, box, info)
	local dConfig = g_RecommendCtrl:GetInfoByType(info.show_type)

	local sprs = {"h7_nryg_1", "h7_nryg_2", "h7_nryg_3"}
	box.m_Icon:SetSpriteName(sprs[idx])
	box.m_Icon:MakePixelPerfect()

	local dContent = dConfig[info.content_id].content
	box.m_Content:SetText(dContent)
end

return CRecommendPart