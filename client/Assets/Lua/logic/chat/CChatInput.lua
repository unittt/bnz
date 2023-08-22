local CChatInput = class("CChatInput", CInput)

function CChatInput.ctor(self, obj,inputargs)
	CInput.ctor(self, obj)
	self.m_Link = {}
	self.m_InputArgs = inputargs
	self:AddUIEvent("change", callback(self, "OnInputChange"))

	local mLabel = self:GetComponentInChildren(classtype.UILabel)
	if mLabel then
		self.m_ChildLabel = CLabel.New(mLabel.gameObject)
	end
	self.m_ColorStr = "#U"
end

--这里是input文本改变了的回调，设置实际的文本信息以及设置input的value显示
function CChatInput.OnInputChange(self)
	--这里是设置input文本的颜色
	--暂时屏蔽
	-- local str,count = string.gsub(self.m_UIInput.value,"(.-)"..self.m_ColorStr.."(.-)","%1".."%2")
	-- table.print(self.m_ColorStr)
	-- table.print(self.m_UIInput.value)
	-- if str ~= "" then
	-- 	self.m_UIInput.value = self.m_ColorStr..str
	-- else
	-- 	self.m_UIInput.value = ""
	-- end
	local sValue = self.m_UIInput.value
	local b = ""
	for sLink, sText in pairs(self.m_Link) do
		sValue = string.replace(sValue, sText, sLink)
	end
	self.m_RealText = sValue

	--暂时屏蔽
	-- if self.m_ChildLabel then
	-- 	local Width = UITools.CalculateRelativeWidgetBounds(self.m_ChildLabel.m_Transform).size.x
	-- 	if Width > self.m_InputArgs.Length then
	-- 		self.m_ChildLabel:SetLocalPos(Vector3.New(self.m_InputArgs.Posx-(Width-self.m_InputArgs.Length),0,0))
	-- 	else
	-- 		self.m_ChildLabel:SetLocalPos(Vector3.New(self.m_InputArgs.Posx,0,0))
	-- 	end
	-- end

	if self.m_ChangeCb then
		self.m_ChangeCb()
	end
end

--设置实际的文本信息以及设置input的value显示
function CChatInput.SetText(self, sText)
	sText = sText or ""
	-- self.m_RealText = sText
	self.m_Link = {}
	local t = {}
	for sLink in string.gmatch(sText, "%b{}") do
		--暂时屏蔽
		-- local sPrintText = LinkTools.GetPrintedColorText(sLink)
		local sPrintText = LinkTools.GetPrintedText(sLink)
		if t[sPrintText] then
			local k = t[sPrintText]
			t[sPrintText] = k + 1
			sPrintText = string.gsub(sPrintText, "]", string.format("%d]", k))
		else
			t[sPrintText] = 1
		end
		self.m_Link[sLink] = sPrintText
		sText = string.replace(sText, sLink, sPrintText)
	end
	----暂时屏蔽
	-- local str,count = string.gsub(sText,"(.-)"..self.m_ColorStr.."(.-)","%1".."%2")
	-- if str ~= "" then
	-- 	self.m_UIInput.value = self.m_ColorStr..str
	-- else
	-- 	self.m_UIInput.value = ""
	-- end

	--特殊处理这个红包图案
	sText = string.gsub(sText, "#jiang ", "")
	sText = string.gsub(sText, "#%u", "")
	sText = string.gsub(sText, "#n", "")
	sText = string.gsub(sText, "%[u%]", "")
	sText = string.gsub(sText, "%[/u%]", "")
	sText = string.gsub(sText, "%@([%w_]-)%@", "")

	self.m_UIInput.value = sText
end

--获取实际的文本信息，不是从input value获取的
function CChatInput.GetText(self)
	if self.m_RealText then
		self.m_RealText = self:ModifyText(self.m_RealText)
		return self.m_RealText
	else
		return ""
	end
end

--修正被玩家@的消息，确保@玩家名是在最开始
function CChatInput.ModifyText(self, sText)
	local text = sText
	local dLink = LinkTools.FindLink(sText, "OrgPlayerCallLink")
	if dLink then
		text = string.gsub(sText,"(.-)(%b{})(.-)","%2".."%1".."%3")
	end
	return text
end

--清除实际文本信息以及input value的链接，即只有一个链接
function CChatInput.ClearLink(self)
	local sValue = self.m_UIInput.value
	local sReal = self.m_RealText
	for sLink, sText in pairs(self.m_Link) do
		sValue = string.replace(sValue, sText, "")
		sReal = string.replace(sReal, sLink, "")
	end
	self.m_Link = {}
	self.m_RealText = sReal
	self.m_UIInput.value = sValue
end

return CChatInput