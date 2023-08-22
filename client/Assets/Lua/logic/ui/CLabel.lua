local CLabel = class("CLabel", CWidget)

function CLabel.ctor(self, obj)
	CWidget.ctor(self, obj)
	self.m_EmojiController = nil
	self.m_RawText = ""
	self.m_IsRequest = false
end

function CLabel.Destroy(self)
	self.m_Links = nil
	self.m_EmojiController = nil
	self.m_RawText = nil
	CWidget.Destroy(self)
end

function CLabel.SetOverflowWidth(self, iWidth)
	self.m_UIWidget.overflowWidth = iWidth
end

function CLabel.InitEmoji(self)
	if not self.m_EmojiController then
		self.m_EmojiController = self:GetMissingComponent(classtype.EmojiAnimationController)
	end
end

function CLabel.SetFontSize(self, iSize)
	self.m_UIWidget.fontSize = iSize
end

function CLabel.SetText(self, sText)
	sText = tostring(sText) or ""
	sText = string.gsub(sText, "#gamename", g_GameDataCtrl:GetGameName())
	--替换为原来的普通颜色
	for sLink in string.gmatch(sText, "%@([%w_]-)%@") do
		local oStr = sLink
		if data.colorinfodata.OTHER[oStr] then
			if string.find(data.colorinfodata.OTHER[oStr].colorold, "#") then
				sText = string.gsub(sText, "%@([%w_]-)%@", data.colorinfodata.OTHER[oStr].colorold, 1)
			else
				sText = string.gsub(sText, "%@([%w_]-)%@", "["..data.colorinfodata.OTHER[oStr].colorold.."]", 1)
			end
		elseif g_ChatCtrl.m_ItemColorConfig[oStr] then
			if string.find(g_ChatCtrl.m_ItemColorConfig[oStr].colorold, "#") then
				sText = string.gsub(sText, "%@([%w_]-)%@", g_ChatCtrl.m_ItemColorConfig[oStr].colorold, 1)
			else
				sText = string.gsub(sText, "%@([%w_]-)%@", "["..g_ChatCtrl.m_ItemColorConfig[oStr].colorold.."]", 1)
			end
		end
	end	
	self.m_UIWidget.text = sText
end

function CLabel.SetCommaNum(self, sNum, char, offset)
	sNum = string.AddCommaToNum(sNum, char, offset) or ""
	self.m_UIWidget.text = sNum
end

function CLabel.GetText(self)
	return self.m_UIWidget.text
end

-- 获取实际的文本内容
function CLabel.GetRawText(self)
	return self.m_RawText
end

-- 有链接的时候加上BoxCollider
function CLabel.SetRichText(self, sText, iTag, bReplace, isMainMenuChatBox)
	sText = sText or ""
	-- 替换#role为主角名字
	sText = string.gsub(sText, "#role", "#G"..g_AttrCtrl.name.."#n")
	-- 游戏名称替换
	sText = string.gsub(sText, "#gamename", g_GameDataCtrl:GetGameName())
	--替换为原来的普通颜色
	for sLink in string.gmatch(sText, "%@([%w_]-)%@") do
		local oStr = sLink		
		if data.colorinfodata.OTHER[oStr] then
			local oColorShow
			if isMainMenuChatBox then
				oColorShow = data.colorinfodata.OTHER[oStr].colormainmenu
			else
				oColorShow = data.colorinfodata.OTHER[oStr].colorold
			end
			if string.find(oColorShow, "#") then
				sText = string.gsub(sText, "%@([%w_]-)%@", oColorShow, 1)
			else
				sText = string.gsub(sText, "%@([%w_]-)%@", "["..oColorShow.."]", 1)
			end
		elseif g_ChatCtrl.m_ItemColorConfig[oStr] then
			local oColorShow
			if isMainMenuChatBox then
				oColorShow = g_ChatCtrl.m_ItemColorConfig[oStr].colormainmenu
			else
				oColorShow = g_ChatCtrl.m_ItemColorConfig[oStr].colorold
			end
			if string.find(oColorShow, "#") then
				sText = string.gsub(sText, "%@([%w_]-)%@", oColorShow, 1)
			else
				sText = string.gsub(sText, "%@([%w_]-)%@", "["..oColorShow.."]", 1)
			end
		end
	end	
	self:InitEmoji()
	local sUrlText, lLink = LinkTools.GetLinks(sText)
	if next(lLink) then
		if not self.m_UIEventHandler then
			self:AddUIEventHandler()
			self.m_UIWidget.autoResizeBoxCollider = true
			self:GetMissingComponent(classtype.BoxCollider)
			self.m_UIEventHandler:AddEventType(enum.UIEvent["click"])
		end
	end
	self.m_Links = lLink
	self.m_RawText = sText
	self.m_Tag = iTag
	self.m_IsMainMenuChatBox = isMainMenuChatBox

	--主界面左下聊天框颜色替换
	if isMainMenuChatBox then
		local repMainChatBoxColorTable = {
			["#K"] = "[00baff]",
			["#G"] = "[0fff32]",
			["#B"] = "[00baff]",
		}
		for k, v in pairs(repMainChatBoxColorTable) do
			sUrlText = string.gsub(sUrlText, k, v)
		end
	end

	--显示链接的具体文字
	if bReplace then
		local colortable = {
			["#K"] = "#M",
			["#L"] = "#N"
		}
		for k, v in pairs(colortable) do
			sUrlText = string.gsub(sUrlText, k, v)
		end
	end
	self.m_EmojiController:SetEmojiText(sUrlText)
	--重置Anchor
	self:UpdateEmojiAnchor()
	-- printc("显示链接的具体文字",sUrlText)
end

function CLabel.SetOverflow(self, iOverflow)
	self.m_UIWidget.overflowMethod = iOverflow
end

function CLabel.SetAlignment(self, iAlign)
	self.m_UIWidget.alignment = iAlign
end

function CLabel.SetApplyGradient(self, iGradient)
	self.m_UIWidget.applyGradient = iGradient
end

function CLabel.SetGradientTop(self, iColor)
	self.m_UIWidget.gradientTop = iColor
end

function CLabel.SetGradientBottom(self, iColor)
	self.m_UIWidget.gradientBottom = iColor
end

function CLabel.SetEffectStyle(self, iStyle)
	self.m_UIWidget.effectStyle = iStyle
end

function CLabel.SetEffectDistance(self, v2)
	self.m_UIWidget.effectDistance = v2 or Vector2.one
end

function CLabel.SetEffectColor(self, color)
	self.m_UIWidget.effectColor = color
end

function CLabel.SetSpacingX(self, iSpacingX)
	self.m_UIWidget.spacingX = iSpacingX
end

function CLabel.SetSpacingY(self, iSpacingY)
	self.m_UIWidget.spacingY = iSpacingY
end

function CLabel.GetUrlAtPosition(self, worldPos)
	return self.m_UIWidget:GetUrlAtPosition(worldPos)
end

function CLabel.Wrap(self, sText)
	return self.m_UIWidget:Wrap(sText, nil)
end

function CLabel.CalculatePrintedSize(self, sText)
	return self.m_UILabel:CalculatePrintedSize(sText)
end

--有BoxCollider的时候,点击label都会执行这里
function CLabel.SpecialExtendEvent(self, iEvent, ...)
	if iEvent == enum.UIEvent["click"] or iEvent == enum.UIEvent["press"] then
		local worldpos = g_CameraCtrl:GetNGUICamera().lastWorldPosition
		local sUrlContent = self.m_UIWidget:GetUrlAtPosition(worldpos)
		if sUrlContent then
			if iEvent == enum.UIEvent["click"] then
				self.m_IsRequest = true
			elseif iEvent == enum.UIEvent["press"] then
				self.m_IsRequest = not self.m_IsRequest
			end
			--解析具体的文字,然后根据id执行具体的函数,现在一个text只能有一个链接，所以现在id都是1
			local iUrl = tonumber(string.split(sUrlContent, ",")[1])
			-- printc("执行链接的具体函数sUrlContent",sUrlContent)

			local dLink = self.m_Links[iUrl]
			if self.m_IsMainMenuChatBox and iUrl == 6 and dLink and dLink.sType == "SpeechLink" then
				if self.m_Tag then
					CChatMainView:ShowView(function (oView)
						oView:SwitchChannel(self.m_Tag)
					end)
				else
					if dLink and dLink.func and self.m_IsRequest then
						dLink.func(self)
						return true
					end
				end
			else
				if dLink and dLink.func and self.m_IsRequest then
					dLink.func(self)
					return true
				end
			end
		else
			--这里是如果点击的是主界面左下的聊天文字，点击的区域不是链接的话就打开聊天界面并选中某个频道
			if self.m_Tag then
				CChatMainView:ShowView(function (oView)
					oView:SwitchChannel(self.m_Tag)
				end)
			end
		end
	end
	return false
end

-- 默认10w开始转换
function CLabel.SetNumberString(self, number, iNeedConvert)
	number = tonumber(number)
	local str = ""
	iNeedConvert = iNeedConvert or 100000
	
	if number >= iNeedConvert then
		number = number / 10000
		number = math.ceil(number)
		str = string.format("%d万", number)
	else
		str = tostring(number)
	end
	self:SetText(str)
end

--刷新label下表情图片的Anchor，解决问题：重用item时旧的item下的图片[emoticon]宽高会很大，没有重置
function CLabel.UpdateEmojiAnchor(self)
	local oEmoji = self:Find("[emoticon]")
	local oEmojiWidget
	if oEmoji then
		oEmojiWidget = CWidget.New(oEmoji)
		oEmojiWidget:ResetAndUpdateAnchors()
	end
end


local AlignmentConfig = {
	[18] = {[2] = 34, [3] = 8, [4] = 0},
	[20] = {[2] = 40, [3] = 10, [4] = 0},
}

--对齐宽度
function CLabel.AlignmentWidth(self, name)
	
	local size = self.m_UIWidget.fontSize

	local config = AlignmentConfig[size]
	if not config then 
		printc("请配置文字大小和间距")
		return
	end

	local strlen = string.utfStrlen(name) 

	if strlen == 2 then 
		 self:SetSpacingX(config[2])
	elseif strlen == 3 then 
		self:SetSpacingX(config[3])
	elseif strlen == 4 then 
		self:SetSpacingX(config[4])
	end 

end

return CLabel
