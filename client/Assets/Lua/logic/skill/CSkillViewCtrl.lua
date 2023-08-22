local CSkillViewCtrl = class("CSkillViewCtrl")

function CSkillViewCtrl.ctor(self)
	
end

function CSkillViewCtrl.OpenSkillCultivatePart(self,itemId)
	local bIsOpen = g_OpenSysCtrl:GetOpenSysState(define.System.Cultivation, true)
	if not bIsOpen then
		return
	end
	CSkillMainView:ShowView(function (oView)
		local part = oView:GetCultivatePart()
		if itemId and itemId == 10008 then
			part:SetDefaultIndex(5)
		else
			part:SetDefaultIndex(1)
		end
		oView:ShowSubPageByIndex(oView:GetPageIndex("Cultivation"))
	end)
end

return CSkillViewCtrl