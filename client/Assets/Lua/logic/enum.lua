--Unity和C#定义的枚举或者常量

module(...)

TcpEvent = {
    ConnnectSuccess = 1,
    ConnnectFail = 2,
    SendSuccess = 4,
    ReceiveSuccess = 5,
    Exception = 6,
    Disconnect = 7,
    SendFail = 8,
    ReceiveFail = 9,
    ReceiveMessage = 255,
}

DOTween ={
	LoopType ={
        Restart = 0,
        Yoyo = 1,
        Incremental = 2,
	},
	RotateMode ={
		Fast = 0,
		FastBeyond360 = 1,
		WorldAxisAdd = 2,
		LocalAxisAdd = 3,
	},
	Ease = 
	{
		Unset = 0,
		Linear = 1,
		InSine = 2,
		OutSine = 3,
		InOutSine = 4,
		InQuad = 5,
		OutQuad = 6,
		InOutQuad = 7,
		InCubic = 8,
		OutCubic = 9,
		InOutCubic = 10,
		InQuart = 11,
		OutQuart = 12,
		InOutQuart = 13,
		InQuint = 14,
		OutQuint = 15,
		InOutQuint = 16,
		InExpo = 17,
		OutExpo = 18,
		InOutExpo = 19,
		InCirc = 20,
		OutCirc = 21,
		InOutCirc = 22,
		InElastic = 23,
		OutElastic = 24,
		InOutElastic = 25,
		InBack = 26,
		OutBack = 27,
		InOutBack = 28,
		InBounce = 29,
		OutBounce = 30,
		InOutBounce = 31,
		Flash = 32,
		InFlash = 33,
		OutFlash = 34,
		InOutFlash = 35,
	},
	PathType =
	{
		Linear = 0,
		CatmullRom = 1,
	}
}

UILabel ={
	Overflow= {
		ShrinkContent = 0,
		ClampContent = 1,
		ResizeFreely = 2,
		ResizeHeight = 3,
	}
}

UIAnchor = {
	Side = {
		BottomLeft = 0,
		Left = 1,
		TopLeft = 2,
		Top = 3,
		TopRight = 4,
		Right = 5,
		BottomRight = 6,
		Bottom = 7,
		Center = 8,
	}
}

UIWidget = {
	Pivot = {
		TopLeft =0,
		Top =1,
		TopRight =2,
		Left = 3,
		Center = 4,
		Right = 5,
		BottomLeft = 6,
		Bottom = 7,
		BottomRight = 8,
	},
}

UIScrollView =
{
	Movement =
	{
		Horizontal = 0,
		Vertical = 1,
		Unrestricted = 2,
		Custom = 3,
	}
}


UIEvent = {
	submit = 1,
	click = 2,
	doubleclick = 3,
	hover = 4,
	press = 5, 
	select = 6,
	scroll = 7,
	change = 8,
	focuschange = 9,

	dragstart = 11,
	drag = 12,
	dragout = 13,
	dragover = 14,
	dragend = 15,

	scrolldragstarted = 21,
	scrolldragfinished = 22,
	scrollmomentummove = 23,
	scrollstoppedmoving = 24,
	onenable = 30,

    	UICenterOnChildOnCenter = 31,
    	UIPanelOnClipMove = 41,
    	UIInputOnValidate = 51,

	longpress = 101,
	repeatpress = 102,
}

UISprite = 
{
	Flip = 
	{
		Nothing = 0,
		Horizontally = 1,
		Vertically = 2,
		Both = 3,
	}	
}

Space = {
	World = 0,
	Self = 1,
}

Task = {
	NpcMark = {
		Nothing = 0,
		Ace = 1,--"task_npcaccept",
		Pro = 2,--"task_npcfinishnot",
		End = 3,--"task_npcfinish",
		Main = 4,--"task_npcthread",
		War = 5,--"task_npcbattle",
	}
}

Seeker = {
	TraversableTag ={
		BasicGround = 1,
		Sky = 2,
		GroundAndSky = 3,
	}
}

QiniuType = {
	None = 0,
	Image = 1,
	Audio = 2,
}

AudioRecordError = 
{
	None = 0,
	FileNotExist = 1,
	AudioNoData = 2,
	NoMicrophone = 3,
	IsRecording = 4,
	IsNotRecording = 5,
	RecordTooShort = 6,
	IsSilence = 7,
	IsToShort = 8,
}

KeyCode ={
	-- Single
	Escape = 27,
	F1 = 282,
	F2 = 283,
	F3 = 284,
	F4 = 285,
	F5 = 286,
	F6 = 287,

	-- Multi
	A = 97,
}

UIDrawCall={
	Clipping = {
		None = 0,
		TextureMask = 1,
		SoftClip = 3,
		ConstrainButDontClip = 4,
	}
}

UIBasicSprite = {
	Nothing = 0,
	Horizontally = 1,
	Vertically = 2,
	Both = 3,
}

PickImageResult = {
    Cancel = 0,
    Illegal = 1,
    Crop_succ = 2,
    Compress_succ = 3,
    NotSupported = 4,
}
