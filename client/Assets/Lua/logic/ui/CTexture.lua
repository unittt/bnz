local CTexture = class("CTexture", CWidget)

function CTexture.ctor(self, obj)
	CWidget.ctor(self, obj)
	self.m_LoadingPath = nil
	self.m_Path = nil
	self.m_LoadingShape = nil
	self.m_LoadingDoneCb = nil
	self.m_AsyncLoad = true
	if self.m_UIWidget.material then
		self.m_UIWidget.material = self.m_UIWidget.material:Instantiate()
	end
end

function CTexture.SetAsyncLoad(self, bAsync)
	self.m_AsyncLoad = bAsync
end

function CTexture.SetShader(self, shader)
	self.m_UIWidget.shader = shader
end

function CTexture.SetMainTexture(self, texture)
	if Utils.IsNil(texture) then
		texture = nil
	end
	if self.m_UIWidget.mainTexture then
		g_ResCtrl:DelManagedAsset(self.m_UIWidget.mainTexture, self.m_GameObject)
	end
	self.m_UIWidget.mainTexture = texture
	if texture then
		if Utils.IsTypeOf(texture, classtype.Texture2D) then
			g_ResCtrl:AddManageAsset(self.m_UIWidget.mainTexture, self.m_GameObject, self.m_Path)
		end
	else
		self.m_Path = nil
	end
end

function CTexture.GetMainTexture(self)
	return self.m_UIWidget.mainTexture
end

function CTexture.LoadPath(self, path, cb)
	if self.m_LoadingPath == path then
		return
	elseif self.m_Path == path then
		if cb then
			cb(self)
		end
		return
	end
	self.m_LoadingPath = path
	self.m_LoadingDoneCb = cb
	if self.m_AsyncLoad then
		g_ResCtrl:LoadAsync(path, callback(self, "OnTexureLoadDone"))
	else
		g_ResCtrl:Load(path, callback(self, "OnTexureLoadDone"))
	end
end

function CTexture.OnTexureLoadDone(self, asset, path)
	if self.m_LoadingPath == path then
		self.m_LoadingPath = nil
		self.m_Path = path
		if asset then
			self:SetMainTexture(asset)
		end
		if self.m_LoadingDoneCb then
			self.m_LoadingDoneCb(self)
		end
	end
end

function CTexture.TextureNpcHalfPhoto(self, shapeID, func)
	self:LoadTextureShape("half_", shapeID, func)
end

function CTexture.TextureNpcFullPhoto(self, shapeID, func)
	self:LoadTextureShape("full_", shapeID, func)
end

function CTexture.SetChangeMainTexture(self, fileName, imageName, func)
	self.m_LoadingDoneCb = func
	self:LoadTexture(fileName, imageName)	
end

function CTexture.LoadTexture(self, fileName, imageName)
	local sPath = string.format("Texture/%s/%s.png", fileName, imageName)
	g_ResCtrl:LoadAsync(sPath, callback(self, "OnTextureDone"))
end 

function CTexture.OnTextureDone(self, prefab, errcode)
	if prefab then
		self:SetMainTexture(prefab)
	elseif errcode then
		printc(errcode)
	end
	if self.m_LoadingDoneCb then
		self.m_LoadingDoneCb()
	end
end

function CTexture.LoadTextureShape(self, prefix, shapeID, func)
	shapeID = (shapeID and shapeID ~= 0) and shapeID or define.Model.Defalut_Shape
	if self.m_Shape == shapeID or self.m_LoadingShape == shapeID then
		return
	end
	self.m_LoadingShape = shapeID
	local sPath, bExistPath = self:GetPath(prefix, shapeID)
	if not bExistPath then
		shapeID = define.Model.Defalut_Shape
	end
	self.m_LoadingDoneCb = func
	g_ResCtrl:LoadAsync(sPath, callback(self, "OnTextureShapeDone", shapeID))
end

function CTexture.GetPath(self, prefix, shapeID)
	local shapePath = string.format("Texture/Photo/" .. prefix .. shapeID ..".png")
	local abPath = IOTools.GetGameResPath("/"..shapePath)
	return shapePath, true
	-- if C_api.IOHelper.Exists(abPath) then
	-- 	return shapePath, true
	-- else
	-- 	shapeID = define.Model.Defalut_Shape
	-- 	return string.format("Texture/Photo/half_" .. shapeID ..".png"), false
	-- end
end

function CTexture.OnTextureShapeDone(self, shapeID, prefab, errcode)
	if self.m_LoadingShape ~= shapeID then
		return
	end
	self.m_LoadingShape = nil
	if prefab then
		self.m_Shape = shapeID
		self:SetMainTexture(prefab)
		self:MakePixelPerfect()
	elseif errcode then
		printc(errcode)
	end
	if self.m_LoadingDoneCb then
		self.m_LoadingDoneCb()
	end
end

function CTexture.SetMainTextureNil(self)
	self.m_UIWidget.mainTexture = nil
	self.m_LoadingPath = nil
	self.m_Path = nil
end

function CTexture.GetMaterial(self)
	return self.m_UIWidget.material
end

function CTexture.SetFlip(self, iFlip)
	self.m_UIWidget.flip = iFlip
end

function CTexture.GetFlip(self)
	return self.m_UIWidget.flip
end

function CTexture.SetGray(self, isGray)
	if isGray then 
		self.m_UIWidget.color = Color.New(0.5, 0.5, 0.5, 1)
	else 
		self.m_UIWidget.color = Color.New(1, 1, 1, 1)
	end 
end

return CTexture