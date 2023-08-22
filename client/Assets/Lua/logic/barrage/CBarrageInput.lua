local CBarrageInput = class("CBarrageInput", CInput)

function CBarrageInput.ctor(self, obj)
	CInput.ctor(self, obj)
	self.m_Link = {}
	self:AddUIEvent("change", callback(self, "OnInputChange"))

	local mLabel = self:GetComponentInChildren(classtype.UILabel)
	if mLabel then
		self.m_ChildLabel = CLabel.New(mLabel.gameObject)
	end
end

--这里是input文本改变了的回调，设置实际的文本信息以及设置input的value显示
function CBarrageInput.OnInputChange(self)
	local sValue = self.m_UIInput.value
	local b = ""
	for sLink, sText in pairs(self.m_Link) do
		sValue = string.replace(sValue, sText, sLink)
	end
	self.m_RealText = sValue
end

--设置实际的文本信息以及设置input的value显示
function CBarrageInput.SetText(self, sText)
	sText = sText or ""
	self.m_RealText = sText
	self.m_Link = {}
	local t = {}
	for sLink in string.gmatch(sText, "%b{}") do
		local sPrintText = LinkTools.GetPrintedColorText(sLink)
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
	self.m_UIInput.value = sText
end

--获取实际的文本信息，不是从input value获取的
function CBarrageInput.GetText(self)
	if self.m_RealText then
		-- self.m_RealText = self:ModifyText(self.m_RealText)
		return self.m_RealText
	else
		return ""
	end
end

--修正被玩家@的消息，确保@玩家名是在最开始
function CBarrageInput.ModifyText(self, sText)
	local text = sText
	local dLink = LinkTools.FindLink(sText, "OrgPlayerCallLink")
	if dLink then
		text = string.gsub(sText,"(.-)(%b{})(.-)","%2".."%1".."%3")
	end
	return text
end

--清除实际文本信息以及input value的链接，即只有一个链接
function CBarrageInput.ClearLink(self)
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

return CBarrageInput