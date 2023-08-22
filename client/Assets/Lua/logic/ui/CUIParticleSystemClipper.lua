local CUIParticleSystemClipper = class("CUIParticleSystemClipper")

function CUIParticleSystemClipper.ctor(self)
	self.m_shader = nil
	self.m_targetPanel = nil
	self.m_ShaderName = "Baoyu/UI/Particles/Additive"
	self.m_shader = UnityEngine.Shader.Find(self.m_ShaderName)
end

-- function CUIParticleSystemClipper.OnInit(self, panel)
-- 	-- printc("CUIParticleSystemClipper.OnInit")
-- 	oTargetPanel = panel	
-- end

--每次特效可能发生位置改变时都要调用以下这个方法，重新切割
function CUIParticleSystemClipper.Progress(self, oTargetPanel)
	if not Utils.IsNil(oTargetPanel) then
		local clipArea = self:CalcClipArea(oTargetPanel)
		local sublist = oTargetPanel.m_GameObject:GetComponentsInChildren(classtype.ParticleSystem)
		for i = 0, sublist.Length-1 do
			local mat = sublist[i]:GetComponent(classtype.Renderer).material
			--会改变粒子所用的材质
			if mat.shader.name ~= self.m_ShaderName then
				mat.shader = self.m_shader
			end
			mat:SetVector("_ClipRange", clipArea)
		end
	end
end

function CUIParticleSystemClipper.CalcClipArea(self, oTargetPanel)
	local clipRegion = oTargetPanel.m_UIPanel.finalClipRegion
	local nguiArea = Vector4.New(clipRegion.x - clipRegion.z / 2, clipRegion.y - clipRegion.w / 2, clipRegion.x + clipRegion.z / 2, clipRegion.y + clipRegion.w / 2)
	local uiRoot = Utils.GetGameRoot()
	local pos = oTargetPanel:GetPos() - uiRoot.transform.position
	local h = 2
    local temp = h / uiRoot:GetComponent(classtype.UIRoot).manualHeight
    return Vector4.New(-1, pos.y + nguiArea.y * temp, 1, pos.y + nguiArea.w * temp) --pos.x + nguiArea.x * temp, | pos.x + nguiArea.z * temp,
end

return CUIParticleSystemClipper