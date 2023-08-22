--游戏配置
module(...)

Net = {
	-- 重要（指定服务器协议混淆，与服务器值不对应会无法登陆，另外一个作用是加密协议，lua中可热更或补丁形势变换，抬高被破解门槛）
	SecreKey = "0xe07aea3911363aa9"
}

Version = {
	-- 重要（指定服务器版本，与服务器版本不对应会无法登陆）
	AppVer = 26,
	-- 重要（指定当前显示给玩家的版本号,type:string）
	ShowVer = "1.10.0",
}

Debug = {
	-- 是否客户端GM(客户端gm下默认开启日志打印)
	ClientGM = true,
	-- 日志输出
	DebugConsole = true,
	-- 是否显示更多战斗打印信息
	WarConsole = false,
	-- 是否显示战斗单位详细信息
	Warriordetail = false,
	-- 客户端人员开关
	ClientDebug = false,
}

Issue = {
	-- 发行的版本(对外 true， 对内 false)
	Releases = false,
	-- 暂时屏蔽的
	Shiedle = true,
	-- Url是否用静态文件
	UseStaticUrl = true,
}

Model = {
	-- 云测模式
	YunceModel = false,
}