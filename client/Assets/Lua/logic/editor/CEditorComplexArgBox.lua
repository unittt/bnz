local CEditorComplexArgBox = class("CEditorComplexArgBox", CEditorArgBoxBase)

function CEditorComplexArgBox.ctor(self, obj)
	CEditorArgBoxBase.ctor(self, obj)
	self.m_Table = self:NewUI(1, CTable)
	self.m_NormalArgBoxClone = self:NewUI(2, CEditorNormalArgBox)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_BgSprite = self:NewUI(4, CSprite)
	self.m_NormalArgBoxClone:SetActive(false)
	self.m_ComplexType = nil
	self.m_ChangeFunc = nil
end

function CEditorComplexArgBox.SetArgInfo(self, dInfo)
	self:SetKey(dInfo.key)
	self.m_NameLabel:SetText(dInfo.name)
	self.m_ComplexType = dInfo.complex_type 
	local list = config.arg[self.m_ComplexType].sublist
	if dInfo.col then
		self.m_Table:SetColumns(dInfo.col)
	end
	self.m_ChangeFunc = self:GetChangeFunc(dInfo)
	for i, v in ipairs(list) do
		local oBox = self.m_NormalArgBoxClone:Clone()
		oBox:SetActive(true)
		oBox:SetArgInfo(config.arg.template[v])
		oBox:SetValueChangeFunc(self.m_ChangeFunc)
		self.m_Table:AddChild(oBox)
	end
	self.m_Table:Reposition()
	local bouds = UITools.CalculateRelativeWidgetBounds(self.m_Transform)
	self.m_BgSprite:SetSize(bouds.size.x + 15, bouds.size.y + 15)
end

function CEditorComplexArgBox.GetChangeFunc(self, dInfo)
	local func
	if dInfo.complex_type == "complex_pos" and dInfo.pos_cam then
		func = function (v)
			local oCam = dInfo.pos_cam()
			local dInfo = self:GetArgData()[self.m_Key]
			for k, v in pairs(dInfo) do
				if v == "nil" then
					return
				end
			end
			local atkObj = g_WarCtrl:GetWarrior(1)
			local vicObj = g_WarCtrl:GetWarrior(15)
			if dInfo.base_pos ~= "nil" then
				local vPos = MagicTools.GetLocalPosByType(config.run_env, dInfo.base_pos, atkObj, vicObj)
				if atkObj ~= vicObj then
					local oRelative = MagicTools.GetRelativeObj(dInfo.base_pos, atkObj, vicObj)
					if oRelative and dInfo.relative_angle and dInfo.relative_dis then
						vPos = vPos + MagicTools.CalcRelativePos(oRelative,dInfo.relative_angle, dInfo.relative_dis)
					end
				end
				vPos = MagicTools.CalcDepth(vPos, dInfo.depth, config.run_env)
				oCam:SetLocalPos(vPos)
				oCam:LookAt(atkObj.m_WaistTrans, atkObj.m_WaistTrans.up)
			end
		end
	end
	return func
end

function CEditorComplexArgBox.GetArgData(self)
	local dVal = {}
	for i, oBox in ipairs(self.m_Table:GetChildList()) do
		local dSub = oBox:GetArgData()
		table.update(dVal, dSub)
	end
	return {[self.m_Key]=dVal}
end

function CEditorComplexArgBox.SetValue(self, v, bInput, bCallback)
	for i, oBox in ipairs(self.m_Table:GetChildList()) do
		local k = oBox:GetKey()
		if k and v[k] ~= nil then
			oBox:SetValue(v[k], bInput, bCallback)
		else
			oBox:ResetDefault()
		end
	end
end

function CEditorComplexArgBox.ResetDefault(self)
	for i, oBox in ipairs(self.m_Table:GetChildList()) do
		oBox:ResetDefault()
	end
end

return CEditorComplexArgBox