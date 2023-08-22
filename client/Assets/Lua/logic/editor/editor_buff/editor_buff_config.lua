config = {}

config.select =
{
	body_type = {
		{"head", "头部"},
		{"waist", "腰部"},
		{"foot", "脚部"},
	},
}
config.arg = {}

config.arg.template ={	
	path = {
		name = "资源路径",
		key = "path",
		select = function() 
				local list = IOTools.GetFiles(IOTools.GetGameResPath("/Effect/Buff"), "*.prefab", true)
				local newList = {""}
				for i, sPath in ipairs(list) do
					local idx = string.find(sPath, "Effect/Buff")
					if idx then
						table.insert(newList, string.sub(sPath, idx, string.len(sPath)))
					end
					
				end
				return newList
			end,
		wrap = function(s) return IOTools.GetFileName(s, true) end,
		format = "string_type",
		input_width = 150,
	},
	height = {
		name = "高度",
		key = "height",
		format = "number_type",
		default = 0,
	},
	pos = {
		name = "位置",
		key = "pos",
		select_type = "body_type",
		default = "waist",
		input_width = 150,
	},
	node = {
		name = "节点(?)",
		key = "node",
		format = "number_type",
		default = "",
	},
	buff_id = {
		name = "ID",
		key = "buff_id",
		format = "number_type",
		default = 0,
	},
	add_cnt = {
		name = "叠加个数",
		key = "add_cnt",
		format = "number_type",
		default = 1,
	},
	mat_path = {
		name = "材质球",
		key = "mat_path",
		select = function() 
				local list = IOTools.GetFiles(IOTools.GetGameResPath("/Material"), "*.mat", true)
				local newList = {""}
				for i, sPath in ipairs(list) do
					local idx = string.find(sPath, "Material")
					if idx then
						table.insert(newList, string.sub(sPath, idx, string.len(sPath)))
					end
				end
				return newList
			end,
		wrap = function(s) return IOTools.GetFileName(s, true) end,
		format = "string_type",
		input_width = 150,
	}
}
return config