module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.05,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/feng.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.2,
		},
		[4]={
			args={
				alive_time=0.7,
				begin_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=-0.8,},
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_110_hit/Prefabs/Skill_eff_110_fly.prefab]],
				},
				end_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
				move_time=0.6,
			},
			func_name=[[ShootEffect]],
			start_time=0.6,
		},
		[5]={
			args={face_atk=true,hurt_delta=0,play_anim=true,},
			func_name=[[VicHitInfo]],
			start_time=1.1,
		},
		[6]={
			args={
				alive_time=0.2,
				excutor=[[vicobjs]],
				mat_path=[[Material/effect_Fresnel_Green01.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=1.1,
		},
		[7]={
			args={
				alive_time=1,
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_110_hit/Prefabs/Skill_eff_110_hit02.prefab]],
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0.8,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=1.2,
		},
		[8]={args={},func_name=[[End]],start_time=1.8,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
