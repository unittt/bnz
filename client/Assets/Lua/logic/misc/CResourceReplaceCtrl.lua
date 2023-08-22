local CResourceReplaceCtrl = class("CResourceReplaceCtrl", CCtrlBase)

function CResourceReplaceCtrl.ctor(self)
	self.m_AtlasNameList = {
		"RefCommonAtlas",
		"RefScheduleAtlas",
		"RefMainMenuAtlas",
		"RefCommonBgAtlas",
	}

	self.m_SpriteNameList = {}
	self.m_ReplaceAtlas = nil

	self.m_OpenReplace = false
	self.m_ReplaceAtlasName = ""
	self.m_ReplaceTextureFolder = ""
end

function CResourceReplaceCtrl.GetReplaceAtlas(self)
	if not self.m_ReplaceAtlas then
		local path = "Atlas/" .. self.m_ReplaceAtlasName .. ".prefab"
		local atlasAsset = C_api.ResourceManager.Load(path)
		if atlasAsset then
			self.m_ReplaceAtlas = atlasAsset:GetComponent(classtype.UIAtlas)
			if self.m_ReplaceAtlas then
				local spriteList = self.m_ReplaceAtlas.spriteList
				for i=0,spriteList.Count-1 do
					table.insert(self.m_SpriteNameList, spriteList[i].name)
				end
			else
				printerror("esoureceReplaceHelper load asset is error:", self.m_ReplaceAtlasName)
			end
		end
	end
	return self.m_ReplaceAtlas
end

function CResourceReplaceCtrl.ReplaceUI(self, go)
	if self.m_OpenReplace then
		local replaceAtlas = g_ResourceReplaceCtrl:GetReplaceAtlas()
		local uiSpriteList = go:GetComponentsInChildren(classtype.UISprite, true)
		for i=0,uiSpriteList.Length-1 do
			local v = uiSpriteList[i]
			if v and v.atlas and replaceAtlas then
				if self:IsReplaceAtlas(v.atlas.name) and table.index(self.m_SpriteNameList, v.spriteName) then
					v.atlas = replaceAtlas
				end
			end
		end
	end
end

function CResourceReplaceCtrl.ReplaceTexturePath(self, path)
	if self.m_OpenReplace and self:IsReplaceTexture(path) then
		path = string.gsub(path, "Currency", self.m_ReplaceTextureFolder)
		path = string.gsub(path, ".png", "_" .. self.m_ReplaceTextureFolder .. ".png")
		return path
	end
end

function CResourceReplaceCtrl.IsReplaceAtlas(self, atlasName)
	if self.m_ReplaceAtlasName ~= "" then
		return table.index(self.m_AtlasNameList, atlasName)
	end
end

function CResourceReplaceCtrl.IsReplaceTexture(self, path)
    return string.find(path, "Currency")
end

function CResourceReplaceCtrl.SetReplaceRes(self, configInfo)
	self.m_OpenReplace = g_LoginPhoneCtrl:IsShenhePack()
	if self.m_OpenReplace then
		if configInfo.replaceAtlas and configInfo.replaceAtlas ~= "" and configInfo.replaceTexture and configInfo.replaceTexture ~= "" then
			self.m_ReplaceAtlasName = sReplaceAtlasName
			self.m_ReplaceTextureFolder = sReplaceTextureFolder
		end
	end
end

-- function CResourceReplaceCtrl.SetReplaceRes(self, configInfo)
-- 	self.m_OpenReplace = true --g_LoginPhoneCtrl:IsShenhePack()
-- 	if self.m_OpenReplace then
-- 		-- if configInfo.replaceAtlas and configInfo.replaceAtlas ~= "" and configInfo.replaceTexture and configInfo.replaceTexture ~= "" then
-- 			self.m_ReplaceAtlasName = "RefReplaceAtlas"--sReplaceAtlasName
-- 			self.m_ReplaceTextureFolder = "ReplaceTex"--sReplaceTextureFolder
-- 		-- end
-- 	end
-- end

return CResourceReplaceCtrl
