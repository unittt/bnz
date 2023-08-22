local CSprite = class("CSprite", CWidget)

function CSprite.ctor(self, obj)
	CWidget.ctor(self, obj)
	self.m_UISpriteAnimation = nil
	self.m_SpriteName = self.m_UIWidget.spriteName

	self.m_LastLoatAtlasPath = ""
	self.m_LastLoadSprName = ""
end

function CSprite.SetSpriteName(self, sName)
	sName = sName and tostring(sName) or ""
	if self.m_UIWidget.spriteName ~= sName then
		self.m_SpriteName = sName
		self.m_UIWidget.spriteName = sName
	end
end

function CSprite.GetSpriteName(self)
	return self.m_SpriteName
end

function CSprite.SetFillAmount(self, iFillAmount)
	self.m_UIWidget.fillAmount = iFillAmount 
end

function CSprite.SetAtlas(self, oAtlas)
	self.m_UIWidget.atlas = oAtlas
end

function CSprite.GetAtlas(self)
	return self.m_UIWidget.atlas
end

function CSprite.GetAltasName(self)
	if self.m_UIWidget.atlas then
		if self.m_UIWidget.atlas.replacement then
			return self.m_UIWidget.atlas.replacement.name
		else
			return self.m_UIWidget.atlas.name
		end
	end
end

function CSprite.SetFlip(self, iFlip)
	self.m_UIWidget.flip = iFlip
end

function CSprite.SpriteAvatar(self, iShape)
	self:DynamicSprite("Avatar", iShape)
end

function CSprite.SpriteItemShape(self, iItemShape)
	self:DynamicSprite("Item", iItemShape)
end

function CSprite.SpriteSchool(self, iShool)
	self:DynamicSprite("School", iShool)
end

function CSprite.SpriteSkill(self, iSkill)
	self:DynamicSprite("Skill", iSkill)
end

function CSprite.SpriteAdvancedSkill(self, iSkillList, skilllv)
	local spr = nil
	--//当作一个重载函数
	if not skilllv then
		skilllv = 1
	end
	--//
	local function recursion(iSkillList, skilllv)
		for i,v in ipairs(iSkillList) do
			if skilllv >= v.level then
				spr = v.icon
			else
				break
			end
		end
		if not spr then
			recursion(iSkillList, skilllv-1)
		elseif spr == nil and skilllv == 1 then
			printc("宠物技能已经下调至1,依然没有对应的技能UI,excel有问题")
			return
		end 
	end
	recursion(iSkillList, skilllv)
	self:DynamicSprite("Skill", spr)
end

function CSprite.SpriteMagic(self, iMagic)
	local dMagic = DataTools.GetMagicData(iMagic)
	local iconName = iMagic
	if dMagic and dMagic.skill_icon and dMagic.skill_icon > 0 then
		iconName = dMagic.skill_icon
	end
	self:DynamicSprite("Skill", iconName)
end

function CSprite.SpriteBuff(self, iBuff)
	self:DynamicSprite("Buff", iBuff)
end

function CSprite.DynamicSprite(self, sType, iKey)
	local dAtlasMap = datauser.dynamicatlasdata.DATA[sType]
	if not dAtlasMap then
		print("DynamicSprite dAtlasMap", sType, iKey)
		self:DefalutSprite()
		return
	end
	iKey = tonumber(iKey)
	if not iKey then
		return
	end
	local dSprInfo = dAtlasMap[iKey]
	if not dSprInfo then
		print("DynamicSprite dSprInfo", sType, iKey)
		self:DefalutSprite()
		return
	end
	local curName = self:GetAltasName()
	self.m_LastLoatAtlasPath = string.format('Atlas/DynamicAtlas/%s/%s.prefab', dSprInfo.atlas, dSprInfo.atlas)
	self.m_LastLoadSprName = dSprInfo.sprite
	
	if curName and curName == dSprInfo.atlas then
		self:SetSpriteName(dSprInfo.sprite)
	else
		g_ResCtrl:Load(self.m_LastLoatAtlasPath, callback(self, "AtlasLoadDone", dSprInfo.sprite, nil))
	end
end

function CSprite.DefalutSprite(self)
	self:SetStaticSprite("CommonAtlas", "pic_missing")
end

function CSprite.SetStaticSprite(self, sAtlas, sName, cb)
	local isV2 = string.find(sAtlas, "V2")
	local sixff = isV2 and "AtlasV2" or "Atlas"
	self.m_LastLoatAtlasPath = string.format("%s/Ref%s.prefab", sixff, sAtlas)
	self.m_LastLoadSprName = sName
	local curName = self:GetAltasName()
	if curName and curName == sAtlas then
		self:SetSpriteName(sName)
	else
		g_ResCtrl:Load(self.m_LastLoatAtlasPath, callback(self, "AtlasLoadDone", sName, cb))
	end
end

function CSprite.AtlasLoadDone(self, sName, cb, asset, path)
	if asset then
		local oAtlas = asset:GetComponent(classtype.UIAtlas)
		if self.m_LastLoatAtlasPath == path then
			self:SetAtlas(oAtlas)
		end
		if self.m_LastLoadSprName == sName then
			self:SetSpriteName(sName)
		end
		if cb then
			cb(oAtlas)
		end
	else
		print("AtlasLoadDone Error 图集加载错误，名称：", sName)
	end
end

function CSprite.InitSpriteAnimation(self)
	if not self.m_UISpriteAnimation then
		self.m_UISpriteAnimation = self:GetComponent(classtype.UISpriteAnimation)
	end
end

function CSprite.SetNamePrefix(self, s)
	self:InitSpriteAnimation()
	self.m_UISpriteAnimation.namePrefix = s
end

function CSprite.GetNamePrefix(self)
	self:InitSpriteAnimation()
	return self.m_UISpriteAnimation.namePrefix
end

function CSprite.SetFramesPerSecond(self, i)
	self:InitSpriteAnimation()
	self.m_UISpriteAnimation.framesPerSecond = i
end

function CSprite.GetFramesPerSecond(self)
	self:InitSpriteAnimation()
	return self.m_UISpriteAnimation.framesPerSecond
end

function CSprite.PauseSpriteAnimation(self)
	self:InitSpriteAnimation()
	self.m_UISpriteAnimation:Pause()
end

function CSprite.StartSpriteAnimation(self)
	self:InitSpriteAnimation()
	self.m_UISpriteAnimation:Play()
end

function CSprite.SetItemQuality(self, iQuality)
	if not iQuality then
		return
	end
	local tName = {
		[0] = "h7_pinzhikuang_0",
		[1] = "h7_pinzhikuang_1",
		[2] = "h7_pinzhikuang_2",
		[3] = "h7_pinzhikuang_3",
		[4] = "h7_pinzhikuang_4",
		[5] = "h7_pinzhikuang_5",
		[6] = "h7_pinzhikuang_0"
	}
	self:SetSpriteName(tName[iQuality])
end

function CSprite.SetItemColorQuality(self, iQuality)
	if not iQuality then
		return
	end
	local color = {
		[0] = Color.white,
		[1] = Color.green,
		[2] = Color.blue,
		[3] = Color.yellow,
		[4] = Color.red,
		[5] = Color.yellow,
		[6] = Color.white,
	}
	self:SetColor(color[iQuality])
end

function CSprite.SpriteCurrency(self, iType)
	local Icons = {"10002","10003","10001", "10221", "10221"}
	self:SetSpriteName(Icons[iType])
end

function CSprite.MakePixelPerfect(self)

	self.m_UISprite = self:GetComponent(classtype.UISprite)
	if self.m_UISprite then
		self.m_UISprite:MakePixelPerfect()
	end 
end

function CSprite.SpriteGemstoneBg(self, iColor)
	local tName = {
		[1] = "hunshi_06",
		[2] = "hunshi_03",
		[3] = "h7_texiaotubiaokuang", 
	}
	self:SetSpriteName(tName[iColor])
end

return CSprite