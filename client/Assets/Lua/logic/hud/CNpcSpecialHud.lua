local CNpcSpecialHud = class("CNpcSpecialHud", CAsynHud)

function CNpcSpecialHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/SpecialHud.prefab", cb)
end

function CNpcSpecialHud.OnCreateHud(self)
	self.m_SpecialLab = self:NewUI(1, CHudLabel)
	self.m_SpecialSpr = self:NewUI(2, CSprite)
end

function CNpcSpecialHud.SetNpcSpecialHud(self, title, spriteName)
	local titleSta = title and string.len(title) > 0
	local spriteSta = spriteName and string.len(spriteName) > 0
	if not titleSta and not spriteSta then
		printerror("错误：检查特殊称号设置")
		return
	end
	
	local xPos = 0
	if titleSta then
		if spriteSta then
			xPos = 41
		end
	elseif spriteSta then
		xPos = 82
	end
	self.m_SpecialLab:SetLocalPos(Vector3.New(xPos, 0, 0))

	self.m_SpecialLab:SetActive(titleSta)
	--由 namecolordata 表控制 -- 头上  特殊，脚下 普通
	local colorinfo = data.namecolordata.TITLEDATA[define.RoleTitle.NPCSpeTitle] --

	self.m_SpecialLab:SetFontSize(colorinfo.size)

	-- if titleSta and colorinfo.blod == 1 then
	-- 	title = "[b]"..title
	-- end
	if titleSta then
    	-- self.m_SpecialLab:SetEffectStyle(colorinfo.style)
		local title = colorinfo.color and ("["..colorinfo.color.."]" .. title) or title
		self.m_SpecialLab:SetText(title)                          -- 描边 
		-- if colorinfo.style == 1 then
		-- 	self.m_SpecialLab:SetEffectColor(Color.RGBAToColor(colorinfo.style_color))
		-- end
	end
	self.m_SpecialSpr:SetActive(spriteSta)
	if spriteSta then
		self.m_SpecialSpr:SetSpriteName(spriteName)
		self.m_SpecialSpr:MakePixelPerfect()
	end
end

return CNpcSpecialHud