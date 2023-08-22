local string = string

-- function string.safesplit(splitstr, sep)
-- 	local t = {}
-- 	if sep then
-- 		local p 
-- 		local len = string.len(sep)
-- 		if len > 1 and sep ~= string.rep(".", len) and not sep:find("%%") then
-- 			p = "(.-)"..sep
-- 			splitstr = splitstr .. sep
-- 		else
-- 			p = "([^"..sep.."]+)"
-- 		end
-- 		for str in splitstr:gmatch(p) do
-- 			if str ~= "" then
-- 				table.insert(t, str)
-- 			end
-- 		end
-- 	end
-- 	return t
-- end

-- function string.split(splitstr, sep)
-- 	local b, ret = pcall(string.safesplit, splitstr, sep)
-- 	if b then
-- 		return ret
-- 	else
-- 		printerror("splitstr:", splitstr, ",sep:", sep, ",errmsg:", ret)
-- 		return {}
-- 	end
-- end

function string.split(splitstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	local i = 1
	for str in string.gmatch(splitstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

string.oriformat = string.format
function string.format(s, ...)
	local list = {}
	local len = select("#", ...)
	for i=1, len do
		local v = select(i, ...)
		if v == nil or type(v) == "boolean" then
			table.insert(list, tostring(v))
		else
			table.insert(list, v)
		end
	end
	return string.oriformat(s, unpack(list))
end

function string.startswith(s, starts)
	if #starts > #s then
		return false
	end
	for i = 1, #starts do
		if string.byte(s, i) ~= string.byte(starts, i) then
			return false
		end
	end
	return true
end

function string.endswith(s, ends)
	local lenS = #s
	local lenEnds = #ends
	if lenEnds > lenS then
		return false
	end
	local offset = lenS - lenEnds
	for i = 1, lenEnds do
		if string.byte(s, offset+i) ~= string.byte(ends, i) then
			return false
		end
	end
	return true
end

--非正则替换
function string.replace(s, pat, repl, n)
	local list = {"(", ")", ".", "+", "-", "*", "?", "[", "^", "$"}
	for k, v in ipairs(list) do
		pat = string.gsub(pat, "%"..v, "%%"..v)
	end
	return string.gsub(s, pat, repl, n)
end

--获取UTF8字符串长度
--@param str 目标字符串
--@return cnt 字符长度
function string.utfStrlen(str)
	local len = #str
	local left = len 
	local cnt = 0
	local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	while left ~= 0 do
		local temp = string.byte(str, -left)
		local i = #arr
		while arr[i] do
			if temp >= arr[i] then
				left = left - i
				break
			end
			i = i - 1
		end
		cnt = cnt + 1
	end
	return cnt
end

--判断是否存在非法字符
--@param s 目标字符串
--@return bool
--allowlist只是处理特殊字符(不是中文,字母,数字的字符),允许输入的特殊字符
function string.isIllegal(s, allowlist)  
    local ss = ""  
    for k = 1, #s do  
        local c = string.byte(s,k)
        if not c then break end  
        if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then  
			ss = ss..string.char(c) 
        elseif c>=228 and c<=233 then  
            local c1 = string.byte(s,k+1)  
            local c2 = string.byte(s,k+2)  
            if c1 and c2 then  
                local a1,a2,a3,a4 = 128,191,128,191  
                if c == 228 then a1 = 184  
                elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165  
                end  
                if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then  
                    k = k + 2  
					ss = ss..string.char(c,c1,c2)
                end  
            end
        else
        	if allowlist then
	        	for k,v in pairs(allowlist) do
	        		if string.char(c) == v then
	        			ss = ss..v
	        			break
	        		end
	        	end
	        end
        end  
    end
	if #s ~= #ss then --存在不是中文,字母,数字的字符	
    	return false
	end
	return true
end

function string.isIllegalInverse(s, notAllowList)
	local ss = ""  
	-- local notAllowList = {"#"}
    for k = 1, #s do  
        local c = string.byte(s,k)
        if not c then break end  
        local isCheck = false
        for k,v in pairs(notAllowList) do
    		if string.char(c) == v then
    			isCheck = true
    			break
    		end
    	end
    	if not isCheck then
    		ss = ss..string.char(c)
    	end
    end
	if #s ~= #ss then --不是原先完整的字符	
    	return false
	end
	return true
end

--string.eval("a+b", {a=1, b=2})
function string.eval(s, t)
	local f = loadstring(string.format("do return %s end", s))
	setfenv(f, t)
	return f()
end

--转换函数 超过10 0000   显示 10万
function string.numberConvert(number)
	local str = ""
	number = tonumber(number)
	if number >= 100000 then
		number = number / 10000
		number = math.ceil(number)
		str = string.format("%d万", number)
	else
		str = tostring(number)
	end		
	return str
end

--阿拉伯数字转中文
function string.number2text(n, isbig)
	local t = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "零"}
	local bigt = {"壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "零"}
	if isbig then
		return bigt[n]
	else
		return t[n]
	end
end

function string.print4Pos(oNum, bLow)
	local m_ChineseList = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"}
	local m_TypeList = {"", "十", "百", "千"}
	local numStr = tostring(oNum)
	if numStr == "" then
		return ""
	end
	local oLen = string.len(numStr)
	local oRetStr = ""
	for i = 0, oLen-1 do
		local isExecute = true
		local index = string.char(string.byte(numStr, i+1)) - '0'
		if index >= 0 then
			if 0 == index then
				if ( ((i + 1) < oLen and 0 == string.char(string.byte(numStr, i+1+1)) - '0' ) or (i+1 == oLen)) then
					isExecute = false
				end
			end

			if isExecute then
				if index > 1 or not (2 == oLen and 0 == i) then
					oRetStr = oRetStr..m_ChineseList[index + 1]
				end
				local oUnder = oLen - 1 - i
				if true then--not bLow or oLen > 3 or (i+1 ~= oLen and (string.char(string.byte(numStr, i+1+1)) - '0') ~= 0) then
					if index ~= 0 then
						oRetStr = oRetStr..m_TypeList[oUnder + 1]
					end
				end
			end
		end
	end
	return oRetStr
end

--数字转中文数字
function string.printInChinese(oNum)
	if oNum == 0 then
		return "零"
	end
	local numStr = tostring(tonumber(oNum))
	local hight4 = ""
	local low4 = ""
	local oLen = string.len(numStr)
	if oLen < 5 then
		low4 = numStr
	else
		low4 = string.sub(numStr, -4 , -1)
		hight4 = string.sub(numStr, 1 , -5)
	end
	local oChineseNum = ""
	oChineseNum = oChineseNum..string.print4Pos(hight4, false)
	if string.len(hight4) > 0 then
		oChineseNum = oChineseNum.."万"
	end
	oChineseNum = oChineseNum..string.print4Pos(low4, true)
	return oChineseNum
end

function string.getutftable(str)
	local t = {}
	for uchar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
		t[#t+1] = uchar
	end
	return t
end

--获取固定长度字符串，超出长度都用……替代
function string.gettitle(str, size, sPattern)
	local sPattern = sPattern or "……"
	local t = string.getutftable(str)
	local result = {}
	local cnt = 0
	for k, v in pairs(t) do
		if string.byte(v) > 0xc0 then
			cnt = cnt + 2
		else
			cnt = cnt + 1
		end
		if cnt <= size then
			table.insert(result, v)
		else
			table.insert(result, sPattern)
			break
		end
	end
	return table.concat(result, "")
end

function string.findstr(str, starget)
	local amountstr = string.len(str)
	local amounttarget = string.len(starget)
	if amounttarget > amountstr then
		return false
	end
	for i = 1, amountstr do
		local flag = true
		for j = 1, amounttarget do
			if string.sub(str, i-1+j, i-1+j) ~= string.sub(starget, j, j) then
				flag = false
			end
		end
		if flag then
			return i
		end
	end
end

function string.getFirstChar(str)
	local utf8 = string.byte(str,1)
	if utf8 == nil then
		return
	end
	--utf8字符1byte,中文3byte
	if utf8 > 127 then
		return string.sub(str,1,3)
	else
		return string.sub(str,1,1)
	end
end

-- 不考虑小数情况（有需求再调整）
function string.getSegmentaStr(str, char, offset)
	str = tostring(str)
	if not str or #str <= 0 then
		return
	end
	char = char or ','
	offset = (offset or 3) * -1
	local finalStr = nil
	for i=#str,1, offset do
		local idx = i+offset+1
		if idx < 0 then
			idx = 0
		end
		local s = string.sub(str, idx, i)
		if finalStr then
			finalStr = s .. "," .. finalStr
		else
			finalStr = s
		end
	end
	return finalStr
end

function string.AddCommaToNum(str, char, offset)
	char = char or ","
	offset = offset or 3

	if offset < 1 then
		return str
	end

	local num = math.floor(tonumber(str))
	if num == 0 then
		return "0"
	end

	local isNegative = false
	if num < 0 then
		isNegative = true
		num = -num
	end

	local powOffset = 10 ^ offset
	local s = ""
	while num > 0 do
		local remainder = num % powOffset
		remainder = string.format("%0" .. offset .. "d", remainder)
		s = char .. remainder .. s
		num = math.modf(num / powOffset)
	end

	-- 截掉最前面的 ","
	s = string.sub(s, 2)

	-- 截掉最前面的 "0"
	local function truncateLeadingZeroes(s)
		for i = 1, #s do
			if string.sub(s, i, i) ~= "0" then
				return i
			end
		end
	end

	local startIdx = truncateLeadingZeroes(s)
	s = string.sub(s, startIdx)

	-- 负数前面补 "-"
	if isNegative then
		return "-" .. s
	else
		return s
	end
end

--转化文字提示内容 
function string.GetContentMacthColor(contentTable, textId, rep)
	local tColorInfoOther = data.colorinfodata.OTHER
	local content_tab = {}
	for i,val in pairs(contentTable) do
		local _,macth_num = string.gsub(val.content,"#+","")
		local contentStr = val.content
		local tem = {}
		tem.num = macth_num
		tem.str = nil
		if macth_num > 0 then 
		    for k,v in pairs(tColorInfoOther) do
		        local t_color = string.gsub(v.color, "%%s","#"..k) 
		     	local s_color,n_num = string.gsub(contentStr, "#"..k, t_color )
		     	if n_num > 0 then
		     	   contentStr = s_color
		     	   macth_num = macth_num - 1
		     	end
		     	if macth_num == 0 then
		     	   tem.str = s_color
		     	   content_tab[i] = tem
		     	   break
		     	end
		    end
		else
			tem.str = contentStr
			content_tab[i] = tem
		end
	end
	local matchContent = content_tab[textId]
		if matchContent then
		local matchStr = matchContent.str
		local macthing_num = matchContent.num
	    if macthing_num > 0 then 
		    for k,v in pairs(tColorInfoOther) do
		     	local s_color,n_num = string.gsub(matchStr, "#"..k, rep )
		     	if n_num > 0 then
		     	   matchStr = s_color
		     	   macthing_num = macthing_num - 1
		     	end
		     	if macthing_num == 0 then
		     	   return s_color
		     	end
		    end
		end
	end
end

--剥除聊天输入内容的非法字符,防止用户输入颜色,url等非法标记
function string.StripChatSymbols(str)
    return NGUI.NGUIText.StripSymbols(str)
end

--example ("#role使用#amount个#item获得#exp经验", {role = "玩家1", amount=1, item="#R经验道具#n",exp=1000})
-- mReplace支持table: {amount = {[1] = 5, [2] = 3}}
--bColor 加颜色，颜色表: data.colorinfodata.OTHER
function string.FormatString(sText, mReplace, bColor)
    assert(type(sText)=="string", "FormatColorString, sText must be string")
    if not mReplace then return sText end
    local mAllColor
    if bColor then
        mAllColor = data.colorinfodata.OTHER
    end
    for sKey, rReplace in pairs(mReplace) do
        local sPatten = "#"..sKey
        local sType = type(rReplace)
        local sColor = "%s"
        if bColor then
            local mColor = mAllColor[sKey]
            sColor = mColor and mColor.color or "%s"
        end
        if sType == "string" or sType == "number" then
            sText = string.gsub(sText, sPatten, {[sPatten]=string.format(sColor, rReplace)})
        elseif sType == "table" then
            local iCnt = 0
            sText = string.gsub(sText, sPatten, function()
                iCnt = iCnt+1
                return string.format(sColor, rReplace[iCnt])
            end)
        end
    end
    return sText
end

-- 获取指定长度随机字符串
function string.GetRandomString(iLen)
	local function random(n, m)
		math.randomseed(os.clock()*math.random(1000000, 90000000)+math.random(1000000, 90000000))
		return math.random(n, m)
	end
	local function randomString(len)
		local bc = "QWERTYUIOPASDFGHJKLZXCVBNM"
		local sc = "qwertyuiopasdfghjklzxcvbnm"
		local no = "0123456789"
		local maxLen = 62
		local tmplete = no .. sc .. bc

		local srt = {}
		for i=1,len,1 do
			local index = random(1, maxLen)
			srt[i] = string.sub(tmplete, index, index)
		end
		return table.concat(srt, "")
	end
	return randomString(iLen)
end

-- 给 num 每位数字都加上 "#gold_"
function string.ConvertToArt(num)
	local sNum = tostring(num)
	local artNum = string.gsub(sNum, "%d", function(s)
		return "#gold_" .. s
	end)
	return artNum
end