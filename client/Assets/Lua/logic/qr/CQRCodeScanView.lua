local CQRCodeScanView = class("CQRCodeScanView", CViewBase)

function CQRCodeScanView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Qr/QRCodeScanView.prefab", cb)
	--界面设置
	self.m_DepthType = "BeyondGuide"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CQRCodeScanView.OnCreateView(self)
	self.m_ScanTexture = self:NewUI(1, CTexture)
	self.m_TipLbl = self:NewUI(2, CLabel)
	self.m_ReturnBtn = self:NewUI(3, CButton)
	self.m_ViewWidget = self:NewUI(4, CWidget)

	self.m_CloseCallback = nil
	self.m_InternalCloseCallback = nil
	self.m_CloseDelay = 0.1

	self.m_DecodeInterval = 0.5
	self.m_LastDecodeTime = 0
	self.m_FixSize = 100

	--检测是否正在等待服务器回应
	self.m_WaitServerResponse = false

	--用于判断摄像机是否初始化成功的值，据说有可能会出现这个问题
	self.m_WebCamTextureInitSuccessSize = 100
	self.m_FirstInit = false
	self.m_ViewSize = 0
	
	self:InitContent()
end

function CQRCodeScanView.InitContent(self)
    self.m_WebCamTexture = C_api.WebCamTextureHelper.GetNewWebCamTexture(800, 480, true, 120)
    if self.m_WebCamTexture ~= nil then
    	printc("生成m_WebCamTexture成功", self.m_WebCamTexture.width, ",", self.m_WebCamTexture.height, ",", self.m_WebCamTexture.didUpdateThisFrame)
    	self.m_WebCamTexture:Play()
    else
    	printc("生成m_WebCamTexture失败,m_WebCamTexture为nil")
    end
    self.m_ScanTexture.m_UIWidget.mainTexture = self.m_WebCamTexture
    self.m_FirstInit = true
    self.m_WaitServerResponse = false

    self.m_ReturnBtn:AddUIEvent("click", callback(self, "OnReturnBtnClick"))

    if self.m_CheckTimer then
		Utils.DelTimer(self.m_CheckTimer)
		self.m_CheckTimer = nil
	end
	-- self.m_CheckTimer = Utils.AddTimer(callback(self, "CheckQRUpdate"), 0.02, 0)
end

function CQRCodeScanView.SetData(self, closeCallback)
	self.m_CloseCallback = closeCallback
	if self.m_WebCamTexture ~= nil then
	else
		self:OnReturnBtnClick()
		local windowConfirmInfo = {
			msg = "获取摄像头错误",
			thirdCallback = function ()
				
			end,
			thirdStr = "确定",
			closeType = 3,
			style = CWindowNetComfirmView.Style.Single,
			pivot = enum.UIWidget.Pivot.Center,
		}
		g_WindowTipCtrl:SetWindowNetConfirm(windowConfirmInfo)
	end
end

function CQRCodeScanView.OnReturnBtnClick(self)
	self:QRCodeScanDelayCallback(self.m_CloseCallback)
	self.m_CloseCallback = nil
	self:CloseView()
end

function CQRCodeScanView.CloseView(self)
	if self.m_WebCamTexture then
		self.m_WebCamTexture:Stop()
		self.m_WebCamTexture:Destroy()
		self.m_WebCamTexture = nil
	end
	CViewBase.CloseView(self)
end

function CQRCodeScanView.QRCodeScanDelayCallback(self, callback)
	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
		self.m_DelayTimer = nil
	end
	local function delay()
		if callback then
			callback()
		end
		if self.m_InternalCloseCallback then
			self.m_InternalCloseCallback()
			self.m_InternalCloseCallback = nil
		end
		return false
	end
	self.m_DelayTimer = Utils.AddTimer(delay, 0, self.m_CloseDelay)
end

function CQRCodeScanView.CheckQRUpdate(self)
	if not self.m_WebCamTexture then
		return true
	end
	if self.m_WebCamTexture then
		printc("扫码过程中, m_WebCamTexture", self.m_WebCamTexture.width, ",", self.m_WebCamTexture.height, ",", self.m_WebCamTexture.didUpdateThisFrame)
	end
	if self.m_WebCamTexture and self.m_WebCamTexture.didUpdateThisFrame and self.m_WebCamTexture.width > self.m_WebCamTextureInitSuccessSize and self.m_WebCamTexture.height > self.m_WebCamTextureInitSuccessSize then
		--必须每次都计算
		self.m_ScanTexture:SetLocalScale(Vector3.New(1, self.m_WebCamTexture.videoVerticallyMirrored and -1 or 1, 1))
		self.m_ScanTexture:SetRotation(UnityEngine.Quaternion.AngleAxis(self.m_WebCamTexture.videoRotationAngle, Vector3.forward))

		if self.m_FirstInit then
			self.m_FirstInit = false
			local isBasedOnWidth = (1* UnityEngine.Screen.width / UnityEngine.Screen.height) > (1 * self.m_WebCamTexture.width / self.m_WebCamTexture.height)
			self.m_ScanTexture.m_UIWidget.keepAspectRatio = isBasedOnWidth and 1 or 2 --UIWidget.AspectRatioSource.BasedOnWidth UIWidget.AspectRatioSource.BasedOnHeight
			self.m_ScanTexture.m_UIWidget.aspectRatio = 1 * self.m_WebCamTexture.width / self.m_WebCamTexture.height
			self.m_ScanTexture.m_UIWidget:ResetAndUpdateAnchors()
			local scale = isBasedOnWidth and (1 * self.m_ScanTexture.m_UIWidget.width / self.m_WebCamTexture.width) or (1 * self.m_ScanTexture.m_UIWidget.height / self.m_WebCamTexture.height)
			--正方形
			local resultSize = (self.m_ViewWidget.m_UIWidget.width + self.m_FixSize) / scale
			local pointPos = string.find(tostring(resultSize), "%.")
			local subEndPos = -1
			if pointPos then
				subEndPos = pointPos-1
			end
			self.m_ViewSize = tonumber( string.sub(tostring(resultSize), 1, subEndPos) )
		end

		if self.m_WebCamTexture then
			printc("扫码过程中，有m_WebCamTexture viewsize", self.m_ViewSize)
		end

		--保证初始化完毕
		if UnityEngine.Time.realtimeSinceStartup - self.m_LastDecodeTime > self.m_DecodeInterval and not self.m_WaitServerResponse then
			local result
			local qrDecode = function ()
				result = C_api.AntaresQRCodeUtil.Decode(self.m_WebCamTexture, self.m_ViewSize, self.m_ViewSize)
			end		
			xxpcall(qrDecode)

			self.m_LastDecodeTime = UnityEngine.Time.realtimeSinceStartup

			if result and result ~= "" then
				printc("扫码获得的信息字符串: ", result)
				local qrData = decodejson(result)

				if qrData then
					--判断版本
					-- local function close()
					-- 	local windowConfirmInfo = {
					-- 		msg				= "扫码端和PC端版本不符",
					-- 		thirdCallback	= function ()
								
					-- 		end,
					-- 		thirdStr		= "确定",
					-- 		closeType		= 3,
					-- 		style 			= CWindowNetComfirmView.Style.Single,
							-- pivot = enum.UIWidget.Pivot.Center,
					-- 	}
					-- 	g_WindowTipCtrl:SetWindowNetConfirm(windowConfirmInfo)
					-- end			
					-- self.m_InternalCloseCallback = close
					-- self:OnReturnBtnClick()
					-- return true

					self.m_WaitServerResponse = true
					local needList = {account_token = g_ServerPhoneCtrl.m_PostServerData.info.token, code_token = qrData.sid}
					g_QRCtrl:PostQRLoginRequest(needList, function (tResult)
						self.m_WaitServerResponse = false

						if Utils.IsNil(self)then
							return false
						end
						if not tResult then
							return true
						end

						if tResult.errcode == 0 then
							local closeCallback = self.m_CloseCallback
							self.m_CloseCallback = nil

							local function close()
								CQRCodeEnsureView:CloseView()
								CQRCodeEnsureView:ShowView(function (oView)
									oView:SetData(closeCallback, qrData.sid, qrData.notice_ver)
								end)
							end			
							self.m_InternalCloseCallback = close
							self:OnReturnBtnClick()
						elseif tResult.errcode == 502 then
							local function close()
								g_NotifyCtrl:FloatMsg("PC端二维码已过期,请重刷二维码")
							end			
							self.m_InternalCloseCallback = close
							self:OnReturnBtnClick()
						elseif tResult.errcode == 501 then
							local function close()
								g_NotifyCtrl:FloatMsg("账号登录失效,请手机端重新登录账号")
								--打开sdk登录界面
								if g_LoginPhoneCtrl.m_IsPC then
						            g_LoginPhoneCtrl:ResetAllData()
						            CLoginPhoneView:ShowView(function (oView)
						                oView:RefreshUI()
						            end)
						        else
						            if g_LoginPhoneCtrl.m_IsQrPC then
						                g_LoginPhoneCtrl:ResetAllData()
						                CLoginPhoneView:ShowView(function (oView)
						                    oView:RefreshUI()
						                end)
						            else
						                g_SdkCtrl:Logout()
						            end
						        end
							end			
							self.m_InternalCloseCallback = close
							self:OnReturnBtnClick()
						elseif tResult.errcode == 503 then
							local function close()
								g_NotifyCtrl:FloatMsg("PC端二维码已过期,请重刷二维码")
							end			
							self.m_InternalCloseCallback = close
							self:OnReturnBtnClick()
						else
							local function close()
								g_NotifyCtrl:FloatMsg("扫码失败，请把取景框对准PC端二维码")
							end			
							self.m_InternalCloseCallback = close
							self:OnReturnBtnClick()
						end
					end)
					return true
				end

				--处理商品的扫描
				--待添加

				local function close()
					g_NotifyCtrl:FloatMsg("该二维码无效,请重刷二维码")
				end			
				self.m_InternalCloseCallback = close
				self:OnReturnBtnClick()
			else
				printc("扫码没有获得字符串")
			end
		end
	end
	return true
end

function CQRCodeScanView.OnShowView(self)
	local oView = CNotifyView:GetView()
	if oView then oView:SetActive(false) end
end

function CQRCodeScanView.OnHideView(self)
	local oView = CNotifyView:GetView()
	if oView then oView:SetActive(true) end
end

function CQRCodeScanView.Destroy(self)
	if self.m_CheckTimer then
		Utils.DelTimer(self.m_CheckTimer)
		self.m_CheckTimer = nil
	end
	CViewBase.Destroy(self)
end

return CQRCodeScanView