local CUIRedDot = class("CUIRedDot", CObject)

function CUIRedDot.ctor(self, oAttach, size, pos)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {size=size, pos=pos}
	g_ResCtrl:LoadCloneAsync("UI/UIEffect/redDot.prefab", callback(self, "OnEffLoad"), false)
end

function CUIRedDot.OnEffLoad(self, oClone, errcode) 
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CWidget.New(oClone)
		local iSize
		if self.m_Args.size then
			iSize = self.m_Args.size
		else
			iSize = 30
			local w, h = oAttach:GetSize()
			if w<iSize*2 or h<iSize*2 then
				iSize = iSize / 2
			end
		end
		self.m_Eff:SetSize(iSize, iSize)
		self.m_Eff:SetParent(self.m_Transform)
		local pos 
		if self.m_Args.pos then
			pos = self.m_Args.pos
		else
			pos = Vector2.New(-iSize*0.8, -iSize*0.5)
		end
		UITools.NearTarget(oAttach, self.m_Eff, enum.UIAnchor.Side.TopRight, pos, false)
		local depth = UITools.CalculateNextDepth(oAttach.m_GameObject)
		self.m_Eff:SetDepth(depth)
	else
		oClone:Destroy()
	end
end

return CUIRedDot