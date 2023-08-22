local CWeaponModel = class("CWeaponModel", CModelBase, CGameObjContainer)

function CWeaponModel.ctor(self, obj)

	CModelBase.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)

	self.m_ActID = 0

	self.m_LevelList1 = {}
	self.m_LevelList2 = {}
	self.m_LevelList3 = {}

	self.m_MatTrans = self:GetContainTransform(4)
	local trans1 = self:GetContainTransform(1)
	local trans2 = self:GetContainTransform(2)
	local trans3 = self:GetContainTransform(3)

	table.insert(self.m_LevelList1, trans1)
	table.insert(self.m_LevelList2, trans2)
	table.insert(self.m_LevelList3, trans3)
	for i=5,15 do
		local trans = self:GetContainTransform(i)
		if trans then
			if i < 10 then
				table.insert(self.m_LevelList2, trans)
			else
				table.insert(self.m_LevelList3, trans)
			end
		end
	end

	self.m_FumoMat = nil
end

function CWeaponModel.InitSkinMeshRender(self)
	local modelTrans = self.m_Transform:Find("weapon" .. tostring(self.m_ModelInfo.shape))
	if modelTrans then
		self.m_SkinnedMeshRenderer = modelTrans:GetComponent(classtype.Renderer)
		self.m_DefaultMat =  self.m_SkinnedMeshRenderer.material
	end

	if self.m_MatTrans then
		local renderer = self.m_MatTrans:GetComponent(classtype.Renderer)
		if renderer then
			self.m_FumoMat = renderer.materials[renderer.materials.Length-1]
		end
	end
end

-- 附魔（false：0， true：1），特效等级
function CWeaponModel.SetWeaponEffectLevel(self, bEffect, iLevel)
	if Utils.IsExist(self) then
		-- 设置材质
		if self.m_FumoMat then
			self.m_FumoMat:SetFloat("_LightenMain", bEffect and 1 or 0)
		end

		for i=1,3 do
			local transList = self["m_LevelList"..i]
			if transList then
				for _,v in ipairs(transList) do
					if bEffect and bEffect == 1 then 
						v.gameObject:SetActive(iLevel >= i)
					else
						v.gameObject:SetActive(false)
					end 
				end
			end
		end
	end
end

--注意，创建CWeaponModel对象时要设置self.m_Shape，不然不能播放
function CWeaponModel.CrossFade(self, sState, duration, startNormalized, endNormalized, func)
	if not self.m_Shape then
		return
	end
	self:ResetState()
	self.m_ActID = self.m_ActID + 1
	self:AllModelAnim(CModelBase.CrossFade, sState, duration, startNormalized)
	if endNormalized then
		local fixedTime = ModelTools.GetAnimClipInfo(self.m_Shape, "weapon_"..sState, nil).length * (endNormalized-startNormalized)
		self:FixedEvent(sState, fixedTime, func)
	end
end

function CWeaponModel.FixedEvent(self, sState, fixedTime, func)
	fixedTime = math.max((fixedTime or 1) - 0.01, 0)
	local iActID = self.m_ActID
	self.m_EventTimer = Utils.AddTimer(callback(self, "OnEvent", iActID, func, fixedTime), 0, fixedTime)
end

function CWeaponModel.OnEvent(self, actid, func, fixedTime)
	if self.m_ActID == actid and func then
		func(self)
	end
	self.m_EventTimer = nil
end

function CWeaponModel.AllModelAnim(self, animfunc, ...)
	local args = ...
	animfunc(self, args)
end

function CWeaponModel.ResetState(self)
	if self.m_EventTimer then
		Utils.DelTimer(self.m_EventTimer)
		self.m_EventTimer = nil
	end
end

function CWeaponModel.ClearEffect(self)
    self:SetWeaponEffectLevel()
end

return CWeaponModel