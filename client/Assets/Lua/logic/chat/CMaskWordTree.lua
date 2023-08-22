local CMaskWordTree = class("CMaskWordTree")

function CMaskWordTree.ctor(self, bIsJinYan)
	self.m_RootNode = self:CreateNode('r') 
	self.m_IsJinYan = bIsJinYan
end

function CMaskWordTree.UpdateNodes(self, words)
	if self.m_IsJinYan then
		for i, v in pairs(words) do
			local chars = self:GetCharList(string.lower(v.word))
			if #chars > 0 then
				self:InsertNode(self.m_RootNode, chars, 1, v.id)
			end
		end
	else
		for i, v in pairs(words) do
			local chars = self:GetCharList(string.lower(v))
			if #chars > 0 then
				self:InsertNode(self.m_RootNode, chars, 1)
			end
		end
	end
end

--树节点创建
function CMaskWordTree.CreateNode(self, char, flag, childs)
	local node = {}
	node.char = char or nil		--字符
	node.flag = flag or 0		--是否结束标志，0：继续，1：结尾
	node.childs = childs or {}	--保存子节点
	node.isleaf = true --childs数量为0则是叶子节点
	return node
end

--插入节点
function CMaskWordTree.InsertNode(self, parent, chars, index, oId)
	local node = self:FindNode(parent, chars[index])
	if node == nil then
		node = self:CreateNode(chars[index])
		parent.isleaf = false
		table.insert(parent.childs, node)
	end
	local len = #chars
	if index == len then
		node.flag = 1
		node.jinyanid = oId
	else
		index = index + 1
		if index <= len then
			self:InsertNode(node, chars, index, oId)
		end
	end
end

--节点中查找子节点
function CMaskWordTree.FindNode(self, node, char)
	local childs = node.childs
	for i, child in ipairs(childs) do
		if child.char == string.lower(char) then 
			return child
		end
	end

end

function CMaskWordTree.GetCharList(self, str)
	local list = {}
	while str do
		local utf8 = string.byte(str,1)
		if utf8 == nil then
			break
		end
		--utf8字符1byte,中文3byte
		if utf8 > 127 then
			local tmp = string.sub(str,1,3)
			table.insert(list,tmp)
			str = string.sub(str,4)
		else
			local tmp = string.sub(str,1,1)
			table.insert(list,tmp)
			str = string.sub(str,2)
		end
	end
	return list
end

--将字符串中敏感字用*替换返回
-- flag == true，替换的 * 的数量 = 敏感词长度；flag == false，默认使用 *** 替换
function CMaskWordTree.ReplaceMaskWord(self, str, flag)
	local chars = self:GetCharList(str)
	local index = 1
	local node = self.m_RootNode
	local prenode = nil
	local matchs = {}
	local isReplace = false
	local lastMatchLen = nil
	local totalLen = #chars
	local function replace(chars, list, last, flag)
        local stars = ""
		for i=1, last do
			local v = list[i]
			if flag then
				chars[v] = "*"
				isReplace = true
			else
				if isReplace then
					chars[v] = ""
				else
					chars[v] = "***"
					isReplace = true
				end
			end
		end
	end
	while totalLen >= index do
		prenode = node
		node = self:FindNode(node, chars[index])
		if chars[index] == " " then
			if #matchs then
				table.insert(matchs, index)
				node = prenode
			else
				node = self.m_RootNode
			end
		elseif node == nil then
			index = index - #matchs
			if lastMatchLen then
				replace(chars, matchs, lastMatchLen, flag)
				index = index + (lastMatchLen - 1)
				lastMatchLen = nil
			else
				isReplace = false
			end
			node = self.m_RootNode
			matchs = {}
		elseif node.flag == 1 then
			table.insert(matchs, index)
			if node.isleaf or totalLen == index then
				replace(chars, matchs, #matchs, flag)
				lastMatchLen = nil
				matchs = {}
				node = self.m_RootNode
			else
				lastMatchLen = #matchs
			end
		else
			table.insert(matchs, index)
		end
		index = index + 1
	end
	local str = ''
	for i, v in ipairs(chars) do
		str = str..v
	end
	return str
end

--字符串中是否含有敏感字
function CMaskWordTree.IsContainMaskWord(self, str)
	local sCheck = string.gsub(str, " ", "")
	local chars = self:GetCharList(sCheck)
	local index = 1
	local node = self.m_RootNode
	local masks = {}
	while #chars >= index do
		node = self:FindNode(node, chars[index])
		if node == nil then
			index = index - #masks 
			node = self.m_RootNode
			masks = {}
		elseif node.flag == 1 then
			if self.m_IsJinYan then
				return true, node.jinyanid
			else
				return true
			end
		else
			table.insert(masks,index)
		end
		index = index + 1
	end
	if self.m_IsJinYan then
		return false, nil
	else
		return false
	end
end


return CMaskWordTree
