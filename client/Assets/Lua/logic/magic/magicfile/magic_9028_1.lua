module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.3,
		},
		[3]={
			args={
				alive_time=3.21,
				effect={
					is_cached=true,
					path=[[Effect/Magic/Skill_eff_188_hit/Prefabs/Skill_eff_188_hit.prefab]],
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.5,
		},
		[4]={
			args={sound_path={soundpath=[[Audio/Sound/War/shuizhu.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.8,
		},
		[5]={
			args={
				alive_time=1.25,
				ease_hide_time=0.5,
				ease_show_time=1,
				excutor=[[vicobj]],
				mat_path=[[Material/effect_Fresnel_blue01.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=1.2,
		},
		[6]={args={},func_name=[[End]],start_time=2.8,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=false,
}
