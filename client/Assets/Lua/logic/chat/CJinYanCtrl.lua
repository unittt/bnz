local CJinYanCtrl = class("CJinYanCtrl")

function CJinYanCtrl.ctor(self)
	self.m_MaskWordList = {}
end

function CJinYanCtrl.InitMaskTree(self, oList, bIsInit)
	if bIsInit then
		self.m_MaskWordTree = CMaskWordTree.New(true)
		self.m_MaskWordList = {}
	end
	if self.m_MaskWordTree then
		self.m_MaskWordTree:UpdateNodes(oList)
		for k,v in ipairs(oList) do
			table.insert(self.m_MaskWordList, v)
		end
	end
end

function CJinYanCtrl.IsContainMaskWord(self, str, bIsNeedId)
	if self.m_MaskWordTree then
		local bIsContain, oId = self.m_MaskWordTree:IsContainMaskWord(str)
		if bIsNeedId then
			return bIsContain, oId
		else
			return bIsContain
		end
	else
		if bIsNeedId then
			return false, nil
		else
			return false
		end
	end
end

function CJinYanCtrl.IsContainMaskWordTwo(self, str)
	for k,v in ipairs(self.m_MaskWordList) do
		if string.match(str, v.word) then
			return true, v.id
		end
	end
	return false, nil
end

return CJinYanCtrl