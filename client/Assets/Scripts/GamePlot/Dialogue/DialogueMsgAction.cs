using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace GamePlot
{
	public class DialogueMsgAction:PlotAction
	{
        //使用玩家模型
        public bool isHero;
		public int modelId;
		public string content;
        public bool isRight = true;
        public string sName = "";

#if UNITY_EDITOR
		public override string GetOptionName(){
			return "对话";
		}

        public override bool IsPoint()
        {
            return true;
        }

		protected override void DrawProperty(){
			base.DrawProperty();
            this.isHero = EditorGUILayout.Toggle("使用玩家模型：", this.isHero, GUILayout.Width(100f));
            EditorGUI.BeginDisabledGroup(this.isHero);
			this.modelId = EditorGUILayout.IntField("模型id：",this.modelId);
            this.sName = EditorGUILayout.TextField("模型名字：", this.sName);
            EditorGUI.EndDisabledGroup();
            this.isRight = EditorGUILayout.Toggle("是否在右边：", this.isRight, GUILayout.Width(100f));
			EditorGUILayout.PrefixLabel("内容：");
			this.content = EditorGUILayout.TextArea(this.content);
		}
#endif
	}
}