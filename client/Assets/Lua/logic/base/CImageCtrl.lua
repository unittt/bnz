local CImageCtrl = class("CImageCtrl", CCtrlBase)
CImageCtrl.g_TestImage = false
function CImageCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_ImageCache = {}
end

--保存录音为png格式，返回保存图片的路径
function CImageCtrl.SaveToPng(self, key)
	local pngPath = IOTools.GetRoleFilePath(string.format("/image/%s.png", key))
	return pngPath
end

---------------以下为上传本地图片文件到服务器-----------------
function CImageCtrl.UploadToServer(self, key, path, dUploadArgs)
	g_QiniuCtrl:UploadFile(key, path, enum.QiniuType.Image, callback(self, "OnUploadResult", path, dUploadArgs))
end

function CImageCtrl.OnUploadResult(self, path, dUploadArgs, key, sucess)
	if sucess then
		local filetype = string.gsub(IOTools.GetExtension(path), "%.", "")
		print("上传成功", filetype)
	else
		print("上传失败", key)
	end
end

--获取并压缩本地图片
function CImageCtrl.ReadAndCompressPhoto(self, filename, func, resizeWidth, resizeHeight)
	local resizeWidth = resizeWidth or 1024
	local resizeHeight = resizeHeight or 768
	return C_api.PhotoReaderManager.Instance:ReadAndCompressPhoto(filename, resizeWidth, resizeHeight, func)
end

function CImageCtrl.GetImageByKey(self, key, cb)
	if self.m_ImageCache[key] then
		cb(self.m_ImageCache[key])
		printc("缓存")
	else
		self:DownloadFromServer(key,"png", cb)
	end
end

function CImageCtrl.GetTestImagePath(self)
	return IOTools.GetGameResPath("/Texture/Photo/full_1110.png")
end

function CImageCtrl.GetLocalImagePath(self, name)
	return IOTools.GetGameResPath(string.format("/Texture/Schedule/%s.png", name))
end

-- key 以"local:"开头的读取本地目录"GameRes\Texture\Schedule"下的png
function CImageCtrl.DownloadFromServer(self, key, type, cb)
	if CImageCtrl.g_TestImage then
		local path = self:GetTestImagePath()
		local www = {}
		www.bytes = IOTools.LoadByteFile(path)
		self:OnDownloadResult(type, cb, key, www)
	elseif string.match(key, "^local:") then
		local path = self:GetLocalImagePath(string.sub(key, 7))
		local www = {}
		www.bytes = IOTools.LoadByteFile(path)
		self:OnDownloadResult(type, cb, key, www)
	else
		printc("根据key下载图片")
		g_QiniuCtrl:DownloadFile(key, callback(self, "OnDownloadResult", type, cb))
	end
end

--根据下载的字节保存为本地文件
function CImageCtrl.OnDownloadResult(self, type, cb, key, www)
	if www then		
		local path = IOTools.GetRoleFilePath(string.format("/image/%s.%s", key, type))
		IOTools.SaveByteFile(path, www.bytes)
		self.m_ImageCache[key] = www.bytes
		if cb then
			cb(www.bytes)
		end
		printc("下载成功")
	else
		printc("CImageCtrl.OnDownloadResult,没有www")
		print("下载失败", key)
	end
end

return CImageCtrl