local CJieBaiDeclarationAniView = class("CJieBaiDeclarationAniView", CViewBase)

function CJieBaiDeclarationAniView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiDeclarationAniView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"
	

end

function CJieBaiDeclarationAniView.OnCreateView(self)

	self.m_Widget = self:NewUI(1, CWidget)
	self.m_MaskBg = self:NewUI(2, CTexture)
	self.m_BoxClone = self:NewUI(3, CJieBaiDeclarationText)
	self.m_CloseBtn = self:NewUI(4, CButton)
	self.m_Grid = self:NewUI(5, CGrid)

	self:InitContent()

end

function CJieBaiDeclarationAniView.InitContent(self)

	self.m_CurIndex = 1
	self:CreateTextItems()
	self:ShowEffect()

end

function CJieBaiDeclarationAniView.CreateTextItems(self)
	
	local contents = data.huodongdata.JIEBAI_DECLARATION[1].content
	for k, tex in ipairs(contents) do 
		local item = self.m_Grid:GetChild(k)
		if not item then 
			item = self.m_BoxClone:Clone()
			self.m_Grid:AddChild(item)
		end
		item:SetText(tex)
	end 

end

function CJieBaiDeclarationAniView.ShowEffect(self)
	
	local texItem = self.m_Grid:GetChild(self.m_CurIndex)

	if not texItem then 
		Utils.AddTimer(function ()
			self:OnClose()
		end,0, 1)
		return
	end 

	texItem:Show(function ()
		self.m_CurIndex = self.m_CurIndex + 1
		self:ShowEffect()
	end)

end

return CJieBaiDeclarationAniView