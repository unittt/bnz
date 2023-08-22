local CTable = class("CTable", CObject, CUIEventHandler)

function CTable.ctor(self, obj)
	CObject.ctor(self, obj)
	CUIEventHandler.ctor(self, obj)
	self.m_UITable = self:GetComponent(classtype.UITable)
	self.m_ChildChange = true
	self.m_TransformList = {} --transform缓存
	self.m_LuaObjDict = {}
end

function CTable.CheckChange(self)
	if self.m_ChildChange then
		self.m_ChildChange = false
		self.m_TransformList = self.m_UITable:GetChildList()
	end
end

function CTable.SetColumns(self, columns)
	self.m_UITable.columns = columns
end

function CTable.SetDirection(self, direction)
	self.m_UITable.direction = direction
end

function CTable.SetPivot(self, pivot)
	self.m_UITable.pivot = pivot
end

function CTable.SetCellAlignment(self, cellAlignment)
	self.m_UITable.cellAlignment = cellAlignment
end

function CTable.Reposition(self)
	if self:GetActive(true) then
		self.m_UITable:Reposition()
	else
		self:RepositionLater()
	end
end

function CTable.GetCount(self)
	self:CheckChange()
	return #self.m_TransformList
end

function CTable.Clear(self)
	for i, obj in pairs(self.m_LuaObjDict) do
		self:RemoveChild(obj)
	end
	self.m_TransformList = {}
	self.m_LuaObjDict = {}
end

function CTable.Recycle(self, matchFunc)
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

function CTable.InitChild(self, newfunc)
	self:CheckChange()
	local len = #self.m_TransformList
	for i = 1, len do
		local t = self.m_TransformList[i]
		self.m_LuaObjDict[t.gameObject:GetInstanceID()] = newfunc(t.gameObject, i)
	end
end

function CTable.GetChildIdx(self, transform)
	self:CheckChange()
	return table.index(self.m_TransformList, transform)
end

function CTable.GetChildList(self)
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

function CTable.AddChild(self, obj, silbing)
	self.m_ChildChange = true
	self.m_LuaObjDict[obj:GetInstanceID()] = obj
	obj:SetParent(self.m_Transform)
	if silbing then
		obj:SetSiblingIndex(silbing)
	end
	self:RepositionLater()
end

function CTable.RemoveChild(self, obj)
	self.m_ChildChange = true
	self.m_LuaObjDict[obj:GetInstanceID()] = nil
	obj:SetParent(nil)
	obj:Destroy()
	self:RepositionLater()
end

function CTable.GetChild(self, index)
	self:CheckChange()
	local oChild = self.m_TransformList[index]
	if oChild then
		return self.m_LuaObjDict[oChild.gameObject:GetInstanceID()]
	end
end

function CTable.RemoveChildList(self, list)
	local removeList = {}
	for i = 1, #list do
		local obj = self:GetChild(list[i])
		table.insert(removeList, obj)
	end

	for _, obj in pairs(removeList) do
		self:RemoveChild(obj)
	end

	for _, pos in pairs(list) do
		table.remove(self.m_TransformList, pos)
	end
end

function CTable.RepositionLater(self)
	self.m_UITable.repositionNow = true
end

function CTable.GetPadding(self)
	return self.m_UITable.padding
end

return CTable