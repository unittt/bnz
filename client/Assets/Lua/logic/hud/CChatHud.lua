local CChatHud = class("CChatHud", CAsynHud)

function CChatHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/ChatHud.prefab", cb)
end

function CChatHud.OnCreateHud(self)
	self.m_FloatTable = self:NewUI(1, CTable)
	self.m_FloatBox = self:NewUI(2, CFloatBox)
	self.m_ArrowSpr = self:NewUI(3, CSprite)
	self.m_FloatBox:SetActive(false)
	self.m_ArrowSpr:SetActive(false)
	self.m_LocalPos = self.m_FloatBox:GetLocalPos()
end

--time<=0，不隐藏
function CChatHud.AddMsg(self, sMsg, time)
	--self.m_ArrowSpr:SetActive(true)
	local oBox = self.m_FloatBox:Clone()
	oBox:SetActive(true)
	if (time or 2) > 0 then
		oBox:SetTimer(time or 2, callback(self, "OnTimerUp"))
		if g_WarCtrl:IsWar() then
			g_WarCtrl:OnShowChatMsg()
		end
	end

	--处理链接显示不对
	local t = {}
	for sLink in string.gmatch(sMsg, "%b{}") do
		local sPrintText = LinkTools.GetPrintedText(sLink)
		if t[sPrintText] then
			local k = t[sPrintText]
			t[sPrintText] = k + 1
			sPrintText = string.gsub(sPrintText, "]", string.format("%d]", k))
		else
			t[sPrintText] = 1
		end
		sMsg = string.replace(sMsg, sLink, sPrintText)
	end

	local oCheckStr = string.gsub(sMsg, "#%d%d?", "赓赓")
	oCheckStr = string.gettitle(oCheckStr, 22, "&^")
	if string.find(oCheckStr, "&^") then
		oBox.m_FloatLabel:SetAlignment(1)
		oBox.m_FloatLabel:SetOverflow(enum.UILabel.Overflow.ResizeHeight)
		oBox.m_FloatLabel.m_UIWidget.width = 240
	else
		oBox.m_FloatLabel:SetAlignment(2)
		oBox.m_FloatLabel:SetOverflow(enum.UILabel.Overflow.ResizeFreely)
	end

	-- oBox:SetMaxWidth(240)
	-- oBox:SetText(oMsg:GetValue("channel") and oMsg:GetText() or oMsg.m_Data)
	oBox:SetText(sMsg)

	local oStr2, oCount2 = string.gsub(sMsg, "#%d+", "")
	if oCount2 > 0 then
		oBox.m_FloatLabel:SetSpacingY(5)
	else
		oBox.m_FloatLabel:SetSpacingY(1)
	end

	local sCountText = string.gettitle(sMsg, 22)
	local oStr, oCount = string.gsub(sCountText, "#%d+", "")
	if oCount > 0 then
		oBox.m_BgSprite:SetAnchorTarget(oBox.m_FloatLabel.m_GameObject, 0, 0, 0, 0)		
		oBox.m_BgSprite:SetAnchor("topAnchor", 16, 1)
		if oCount2 > 0 then
			oBox.m_BgSprite:SetAnchor("bottomAnchor", -7, 0)
		else
        	oBox.m_BgSprite:SetAnchor("bottomAnchor", -10, 0)
        end
        oBox.m_BgSprite:SetAnchor("leftAnchor", -10, 0)
    	oBox.m_BgSprite:SetAnchor("rightAnchor", 10, 1)    
		oBox.m_BgSprite:ResetAndUpdateAnchors()
	else
		oBox.m_BgSprite:SetAnchorTarget(oBox.m_FloatLabel.m_GameObject, 0, 0, 0, 0)
		oBox.m_BgSprite:SetAnchor("topAnchor", 7, 1)
        if oCount2 > 0 then
			oBox.m_BgSprite:SetAnchor("bottomAnchor", -3, 0)
		else
        	oBox.m_BgSprite:SetAnchor("bottomAnchor", -10, 0)
        end
        oBox.m_BgSprite:SetAnchor("leftAnchor", -10, 0)
    	oBox.m_BgSprite:SetAnchor("rightAnchor", 10, 1)
		oBox.m_BgSprite:ResetAndUpdateAnchors()
	end	

	self.m_FloatTable:AddChild(oBox)
	-- local v3 = oBox:GetLocalPos()
	oBox:SetLocalPos(Vector3.New(self.m_LocalPos.x, self.m_LocalPos.y-20, self.m_LocalPos.z))
	oBox:SetAsFirstSibling()

	local scale = 1
	if g_WarCtrl:IsWar() then
		scale = 1.5
	end
	self:SetLocalScale(Vector3.one*scale)
end

function CChatHud.OnTimerUp(self, oBox)
	self.m_FloatTable:RemoveChild(oBox)
	self.m_FloatTable:Reposition()
	if self.m_FloatTable:GetCount() == 0 then
		self.m_ArrowSpr:SetActive(false)
	end
	if g_WarCtrl:IsWar() then
		g_WarCtrl:EndChatMsg()
	end
end

return CChatHud