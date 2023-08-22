local CGrid = class("CGrid", CObject, CUIEventHandler)

function CGrid.ctor(self, obj)
	CObject.ctor(self, obj)
	CUIEventHandler.ctor(self, obj)
	self.m_UIGrid = self:GetComponent(classtype.UIGrid)
	self.m_ChildChange = true
	self.m_TransformList = {} --transform缓存
	self.m_LuaObjDict = {}
end

function CGrid.CheckChange(self)
	if self.m_ChildChange then
		self.m_ChildChange = false
		self.m_TransformList = self.m_UIGrid:GetChildList()
	end
end

function CGrid.SetMaxPerLine(self, i)
	self.m_UIGrid.maxPerLine = i
end

function CGrid.GetCellSize(self)
	return self.m_UIGrid.cellWidth, self.m_UIGrid.cellHeight
end

function CGrid.SetCellSize(self, w, h)
	self.m_UIGrid.cellWidth = w
	self.m_UIGrid.cellHeight = h
end

function CGrid.Reposition(self)
	if self:GetActive(true) then
		self.m_UIGrid:Reposition()
	else
		self:RepositionLater()
	end
end

function CGrid.GetCount(self)
	self:CheckChange()
	return #self.m_TransformList
end

function CGrid.Clear(self)
	for i, obj in pairs(self.m_LuaObjDict) do
		self:RemoveChild(obj)
	end
	self.m_TransformList = {}
	self.m_LuaObjDict = {}
end


function CGrid.Recycle(self, matchFunc)
	for i, obj in pairs(self.m_LuaObjDict) do
		local dMatchInfo
		if matchFunc then
			dMatchInfo = matchFunc(obj)
		end
		g_ResCtrl:PutObjectInCache(obj:GetCacheKey(), obj, dMatchInfo)
	end
	self.m_TransformList = {}
	self.m_LuaObjDict = {}
end


function CGrid.InitChild(self, newfunc)
	self:CheckChange()
	local len = #self.m_TransformList
	for i = 1, len do
		local t = self.m_TransformList[i]
		self.m_LuaObjDict[t.gameObject:GetInstanceID()] = newfunc(t.gameObject, i)
	end
end

function CGrid.GetChild(self, index)
	self:CheckChange()
	local oChild = self.m_TransformList[index]
	if oChild then
		return self.m_LuaObjDict[oChild.gameObject:GetInstanceID()]
	end
end

function CGrid.GetChildIdx(self, transform)
	self:CheckChange()
	return table.index(self.m_TransformList, transform)
end

function CGrid.GetChildList(self)
	self:CheckChange()
	local list = {}
	local len = #self.m_TransformList
	for i = 1, len do
		local t = self.m_TransformList[i]
		local luaobj = self.m_LuaObjDict[t.gameObject:GetInstanceID()]
		if luaobj then
			table.insert(list, luaobj)
		end
	end
	return list
end

function CGrid.AddChild(self, obj, bNotRepos)
	self.m_ChildChange = true
	self.m_LuaObjDict[obj:GetInstanceID()] = obj
	obj:SetParent(self.m_Transform)
	if not bNotRepos then
		self:RepositionLater()
	end
end

function CGrid.RemoveChild(self, obj)
	self.m_ChildChange = true
	self.m_LuaObjDict[obj:GetInstanceID()] = nil
	obj:SetParent(nil)
	obj:Destroy()
	self:RepositionLater()
end

function CGrid.RepositionLater(self)
	self.m_UIGrid.repositionNow = true
end

function CGrid.SetHideinactive(self, b)
	self.m_UIGrid.hideInactive = b
end

function CGrid.HideAllChilds(self)
	local list = self:GetChildList()
	if list ~= nil then 
		for k, v in pairs(list) do 
			v:SetActive(false)
		end 
	end 
end

function CGrid.Destroy(self)
	self:Clear()
	CObject.Destroy(self)
	CUIEventHandler.Destroy(self)
end

return CGrid