using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace GamePlot
{
	//场景特效实体
	public class SceneEffectEntity:PlotEntity
	{
		public string folderName;
		public string effPath;
        public string remark;
        public Vector3 originPos;
	    public bool loop;
	    public bool rotate = true;
	    public Vector3 rotateValue = new Vector3(45, 0, 0);
	   	public bool move;
	    public Vector3 movePos;
        public bool showMask;
        public float scale = 1;


#if UNITY_EDITOR
		public override string GetOptionName(){
			return string.Format("场景特效:{0}",this.effPath);
		}

		protected override void DrawProperty(){
			base.DrawProperty();
			this.folderName = EditorGUILayout.TextField("目录名：",this.folderName);
			this.effPath = EditorGUILayout.TextField("特效名：",this.effPath);
            this.remark = EditorGUILayout.TextField("备注：", this.remark);
            this.originPos = PlotEntity.Vector3Field("起始位置：",this.originPos,0);
            this.loop =  EditorGUILayout.Toggle("是否循环：", this.loop, GUILayout.Width(100f));
            this.rotate = EditorGUILayout.Toggle("旋转：", this.rotate, GUILayout.Width(100f));

            EditorGUI.BeginDisabledGroup(!this.rotate);
            this.rotateValue = EditorGUILayout.Vector3Field("旋转：", this.rotateValue);
            EditorGUI.EndDisabledGroup();
            
            this.scale = EditorGUILayout.FloatField("缩放(部分支持)：", this.scale, GUILayout.Width(200f));

            // EditorGUI.BeginDisabledGroup(this.loop);
            this.move = EditorGUILayout.Toggle("是否移动：", this.move, GUILayout.Width(100f)); //&& !this.loop;
            // EditorGUI.EndDisabledGroup();

            EditorGUI.BeginDisabledGroup(!this.move);
            this.movePos = PlotEntity.Vector3Field("移动位置：",this.movePos,0);
            EditorGUI.EndDisabledGroup();

            this.showMask = EditorGUILayout.Toggle("显示黑底：", this.showMask, GUILayout.Width(100f));
        }
#endif
	}
}