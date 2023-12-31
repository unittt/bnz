module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[attack1]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.1,
		},
		[3]={
			args={
				excutor=[[atkobj]],
				face_to=[[look_at]],
				pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				time=0.5,
			},
			func_name=[[FaceTo]],
			start_time=0.45,
		},
		[4]={
			args={sound_path={soundpath=[[Audio/Sound/War/flz2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.55,
		},
		[5]={
			args={
				alive_time=2.75,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_144_hit/Prefabs/skill_eff_144_hit.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=0.65,
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
			start_time=1.25,
		},
		[7]={
			args={excutor=[[atkobj]],face_to=[[default]],time=0.3,},
			func_name=[[FaceTo]],
			start_time=1.25,
		},
		[8]={args={},func_name=[[End]],start_time=1.5,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
