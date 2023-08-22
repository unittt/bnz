module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={sound_path={soundpath=[[Audio/Sound/War/xqgd1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.3,
		},
		[3]={
			args={action_name=[[attack2]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.35,
		},
		[4]={
			args={sound_path={soundpath=[[Audio/Sound/War/jplt2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.8,
		},
		[5]={
			args={
				alive_time=3.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_139_hit/Prefabs/skill_eff_139_hit.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.8,
		},
		[6]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=false,
				hurt_delta=0,
				play_anim=false,
			},
			func_name=[[VicHitInfo]],
			start_time=1,
		},
		[7]={args={},func_name=[[End]],start_time=2.1,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
