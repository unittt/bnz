local CTesterCtrl = class("CTesterCtrl", CCtrlBase)

function CTesterCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_KesFuncList = {
		no_guide = function (open)
			if open then
				printc("=============== 开放引导")
			else
				printc("=============== 关闭引导")
			end
		end,
		sys_open = function (open)
			if open then
				printc("=============== 开放系统")
			else
				printc("=============== 关闭系统")
			end
		end
	}
end

function CTesterCtrl.ResetTester(self, keys)
	for k,f in pairs(self.m_KesFuncList) do
		local open = false
		for _,v in ipairs(keys) do
			if k == v then
				open = true
				break
			end
		end
		f(open)
	end
end

return CTesterCtrl