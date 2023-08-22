local CObject = class("CObject", CDelayCallBase)

function CObject.ctor(self, obj)
	CDelayCallBase.ctor(self)
	self.m_GameObject = obj
	self.m_Transform = obj.transform
	self.m_InstanceID = nil
	self.m_CacheKey = ""
	self.m_UITweeners = nil
	self.m_DestroyOnRecycle = nil
	self.m_FindTrans = {}
	self.m_IsDestroy = false
	-- z坐标要设置在相机后面，不然射线检测可能会影响到
	self.m_HidePos = Vector3.New(0, 0, -100000)
	self.m_IsHidePos = false
end

function CObject.GetTransform(self)
	return self.m_Transform
end

function CObject.InitUITwener(self, bChilds)
	if not self.m_UITweeners then
		local list1 = Utils.ArrayToList(self:GetComponents(classtype.UITweener))
		if bChilds then
			local list2 = Utils.ArrayToList(self:GetComponentsInChildren(classtype.UITweener, true))
			self.m_UITweeners = table.extend(list1, list2)
		else
			self.m_UITweeners = list1
		end
	end
end

function CObject.AddDestroyOnRecycle(self, obj)
	if not self.m_DestroyOnRecycle then
		self.m_DestroyOnRecycle = {}
	end
	table.insert(self.m_DestroyOnRecycle, weakref(obj))
end

function CObject.Recycle(self)
	if self.m_DestroyOnRecycle then
		for _, ref in pairs(self.m_DestroyOnRecycle) do
			local obj = getrefobj(ref)
			if obj then
				obj:Destroy()
			end
		end
		self.m_DestroyOnRecycle = nil
	end
end

function CObject.SetUITweenDuration(self, iTime)
	self:InitUITwener()
	for i, tweener in ipairs(self.m_UITweeners) do
		tweener.duration = iTime
	end
end

function CObject.UITweenPlay(self)
	self:InitUITwener()
	for i, tweener in ipairs(self.m_UITweeners) do
		tweener:ResetToBeginning()
		tweener:PlayForward()
	end
end

function CObject.UITweenStop(self)
	self:InitUITwener()
	for i, tweener in ipairs(self.m_UITweeners) do
		tweener.tweenFactor = 1
	end
end


function CObject.SetCacheKey(self, sPath)
	self.m_CacheKey = sPath
end

function CObject.GetCacheKey(self)
	return self.m_CacheKey
end

function CObject.GetForward(self)
	return self.m_Transform.forward
end

function CObject.SetForward(self, v)
	self.m_Transform.forward = v
end

function CObject.GetUp(self)
	return self.m_Transform.up
end

function CObject.GetRight(self)
	return self.m_Transform.right
end

function CObject.SetName(self, sName)
	self.m_GameObject.name = sName
end

function CObject.GetName(self)
	return self.m_GameObject.name
end

function CObject.AddComponent(self, sType)
	return self.m_GameObject:AddComponent(sType)
end

function CObject.GetComponent(self, sType)
	local component = self.m_GameObject:GetComponent(sType)
	if component then
		return component
	else
		if sType == classtype.UIWidget or sType == classtype.Animator or sType == classtype.BoxCollider then
			return
		end
		printerror(self.classname .. " | " .. self.m_GameObject.name .. " | " .. tostring(sType) .. " | 组件未找到")
	end
end

function CObject.GetComponents(self, sType)
	return self.m_GameObject:GetComponents(sType)
end

function CObject.GetComponentInChildren(self, classtype)
	return self.m_GameObject:GetComponentInChildren(classtype)
end

function CObject.GetComponentsInChildren(self, classtype, includeInactive)
	return self.m_GameObject:GetComponentsInChildren(classtype, includeInactive)
end

function CObject.GetComponentInParent(self, classtype)
	return self.m_GameObject:GetComponentInParent(classtype)
end

function CObject.GetMissingComponent(self, sType)
	-- printerror("get missing component ------- ", sType)
	return self.m_GameObject:GetMissingComponent(sType)
end

function CObject.SetAsFirstSibling(self)
	self.m_Transform:SetAsFirstSibling()
end

function CObject.SetAsLastSibling(self)
	self.m_Transform:SetAsLastSibling()
end

function CObject.SetSiblingIndex(self, index)
	self.m_Transform:SetSiblingIndex(index)
end

function CObject.GetSiblingIndex(self)
	return self.m_Transform:GetSiblingIndex()
end

function CObject.Find(self, s)
	if not self.m_FindTrans[s] then
		self.m_FindTrans[s] = self.m_Transform:Find(s)
	end
	return self.m_FindTrans[s]
end

function CObject.GetChild(self, idx)
	return self.m_Transform:GetChild(idx - 1)
end

-- 这个方法不要频繁的调用，消耗比较大（有优化空间）
function CObject.InitChild(self, newfunc)
	if not newfunc then
		printerror("参数错误：newfunc 为必须参数")
		return
	end
	for i = 1, self.m_Transform.childCount do
		local transform = self:GetChild(i)
		newfunc(transform.gameObject, i)
	end
end

function CObject.SetParent(self, parent, bWorldPositionStays)
	if not self.m_Transform then return end
	local bWorldPositionStays = bWorldPositionStays or false
	self.m_Transform:SetParent(parent, bWorldPositionStays)
end

function CObject.GetLayer(self)
	return self.m_GameObject.layer
end

function CObject.SetLayer(self, layer, bSetChild)
	if bSetChild then
		NGUI.NGUITools.SetLayer(self.m_GameObject, layer)
	else
		self.m_GameObject.layer = layer
	end
end

function CObject.GetParent(self)
	return self.m_Transform.parent
end

function CObject.SetLocalPos(self, vector3)
	-- printerror("========== CObject.SetLocalPos", self:GetName(), vector3)
	-- table.print(vector3)
	if self.m_IsHidePos then
		return
	end
	self.m_Transform.localPosition = vector3
end

function CObject.GetLocalPos(self)
	return self.m_Transform.localPosition
end

function CObject.SetPos(self, v3)
	if self.m_IsHidePos then 
		return
	end
	self.m_Transform.position = v3
end

function CObject.GetPos(self)
	return self.m_Transform.position
end

function CObject.SetLocalRotation(self, quaternion)
	self.m_Transform.localRotation = quaternion
end

function CObject.GetLocalRotation(self)
	return self.m_Transform.localRotation
end

function CObject.SetRotation(self, quaternion)
	self.m_Transform.rotation = quaternion
end

function CObject.GetRotation(self)
	return self.m_Transform.rotation
end

function CObject.SetEulerAngles(self, angle)
	self.m_Transform.eulerAngles = angle
end

function CObject.SetLocalEulerAngles(self, angle)
	self.m_Transform.localEulerAngles = angle
end

function CObject.GetEulerAngles(self)
	return self.m_Transform.eulerAngles
end

function CObject.GetLocalEulerAngles(self)
	return self.m_Transform.localEulerAngles
end

function CObject.SetLocalScale(self, v3)
	self.m_Transform.localScale = v3
end

function CObject.GetLocalScale(self)
	return self.m_Transform.localScale
end

function CObject.SetActive(self, bActive)
	if self:GetActive() ~= bActive then
		self:OnActive(bActive)
		self.m_GameObject:SetActive(bActive)
	end
end

function CObject.ReActive(self)
	self:SetActive(false)
	self:SetActive(true)
end

function CObject.OnActive(self, bActive)
	--override
end

function CObject.GetActive(self, bHierarchy)
	if bHierarchy then
		return self.m_GameObject.activeInHierarchy
	else
		return self.m_GameObject.activeSelf
	end
end

function CObject.Destroy(self)
	if not self:IsDestroy() then
		self.m_GameObject:Destroy()
	end
	self.m_DestroyOnRecycle = nil
	self.m_FindTrans = nil
	self.m_IsDestroy = true
end

function CObject.GetInstanceID(self)
	if not self.m_InstanceID then
		self.m_InstanceID = self.m_GameObject:GetInstanceID()
	end
	return self.m_InstanceID
end

function CObject.SetSiblingIndex(self, index)
	self.m_Transform:SetSiblingIndex(index)
end

function CObject.IsDestroy(self)
	if not self.m_IsDestroy then
		self.m_IsDestroy = not C_api.Utils.IsObjectExist(self.m_GameObject)
	end
	return self.m_IsDestroy
end

function CObject.InverseTransformPoint(self, worldPoint)
	return self.m_Transform:InverseTransformPoint(worldPoint)
end

function CObject.InverseTransformVector(self, worldVec)
	return self.m_Transform:InverseTransformVector(worldVec)
end

function CObject.InverseTransformDirection(self, worldDir)
	return self.m_Transform:InverseTransformDirection(worldDir)
end

function CObject.TransformPoint(self, lcoalPoint)
	return self.m_Transform:TransformPoint(lcoalPoint)
end

function CObject.TransformVector(self, localVec)
	return self.m_Transform:TransformVector(localVec)
end

function CObject.TransformDirection(self, lcoalDir)
	return self.m_Transform:TransformDirection(lcoalDir)
end

function CObject.Translate(self, v, space)
	space = space or enum.Space.Self
	self.m_Transform:Translate(v, space)
end

function CObject.RotateAround(self, vPoint, vAxis, iAngle)
	self.m_Transform:RotateAround(vPoint, vAxis, iAngle)
end

function CObject.Rotate(self, iEulerAngle)
	self.m_Transform:Rotate(iEulerAngle)
end

function CObject.LookAt(self, transOrPos, vDirUp)
	self.m_Transform:LookAt(transOrPos, vDirUp)
end

function CObject.Clone(self, ...)
	local obj = self.m_GameObject:Instantiate()
	return self.classtype.New(obj, ...)
end

function CObject.CloneAnsy(self, func, ...)
	local args = {...}
	local len = select("#", ...)
	local clonefunc = function()
		if Utils.IsExist(self) then
			local obj = self:Clone(unpack(args, 1, len))
			local success, bRet = xxpcall(func, obj)
			local b = success and bRet~=false
			if not b then
				obj:Destroy()
			end
			return b
		else
			return false
		end
	end
	g_ResCtrl:InsertInCloneList(self.m_CacheKey, clonefunc)
end

function CObject.SetPosHide(self, b)
	if self.m_IsHidePos == b then
		return
	end
	if b then
		self.m_CurPos = self:GetPos()
		self:SetPos(self.m_HidePos)
		self.m_IsHidePos = b
	else
		self.m_IsHidePos = b
		self:SetPos(self.m_CurPos)
	end
end
return CObject