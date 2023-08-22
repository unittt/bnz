using UnityEngine;
using System.Collections.Generic;
using DG.Tweening.Plugins.Options;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace GamePlot
{
    //剧情角色实体
    public class CharacterEntity : PlotEntity
    {
        public string name = "无";
        //使用玩家模型
        public bool isHero;

        //角色外观参数
        public int modelId;
        public int mutateTexture = 0;
        public string mutateColor = "";
        public int wpModel = 0;
        public int hallowSpriteId = 0;    //待定：H7暂无器灵概念，可以删除
        public float scale = 1f;
        public int ornamentId = 0;       //待定：未知成员变量

        //位置朝向参数
        public Vector3 originPos;
        //public float rotateY;
        public Orientation orient;
        public string defaultAnim;

        //npcId 暂时用于结婚剧情 固定死 1 新郎 2 新娘 默认为0
        public int npcId;

        //摄像机跟随
        public bool cameraFollow;
        //是否在QTE界面增加一个根据人物位置的显示坐标
        public bool qteOpen;

        public List<PlotAnimationAction> animationActionList = new List<PlotAnimationAction>();
        public List<PlotTransformAction> tweenActionList = new List<PlotTransformAction>();
        public List<PlotTalkAction> talkActionList = new List<PlotTalkAction>();
        public List<PlotFollowEffectAction> followEffectList = new List<PlotFollowEffectAction>();

#if UNITY_EDITOR
        public override string GetOptionName()
        {
            return string.Format("角色:{0}", this.name);
        }

        protected override void DrawProperty()
        {
            base.DrawProperty();
            this.isHero = EditorGUILayout.Toggle("使用玩家模型：", this.isHero, GUILayout.Width(100f));
            EditorGUI.BeginDisabledGroup(this.isHero);
            this.name = EditorGUILayout.TextField("名称：", this.name);
            this.modelId = EditorGUILayout.IntField("modelId:", this.modelId);
            this.mutateTexture = EditorGUILayout.IntField("变异贴图ID:", this.mutateTexture);
            this.mutateColor = EditorGUILayout.TextField("变色参数：", this.mutateColor);
            this.wpModel = EditorGUILayout.IntField("武器ID:", this.wpModel);
            this.hallowSpriteId = EditorGUILayout.IntField("器灵ID:", this.hallowSpriteId);
            EditorGUI.EndDisabledGroup();
            this.scale = EditorGUILayout.FloatField("缩放：", this.scale);
            this.npcId = EditorGUILayout.IntField("新郎1新娘2", this.npcId);

            EditorGUILayout.Space();

            this.cameraFollow = EditorGUILayout.Toggle("摄像机跟随：", this.cameraFollow, GUILayout.Width(100f));
            this.qteOpen = EditorGUILayout.Toggle("开启小游戏显示：", this.qteOpen, GUILayout.Width(100f));

            this.originPos = PlotEntity.Vector3Field("起始位置：", this.originPos, 0);
            //this.rotateY = PlotEntity.OrientationField("朝向：", this.rotateY);
            this.orient = PlotEntity.OrientationField("朝向：", this.orient);
            this.defaultAnim = EditorGUILayout.TextField("默认动作：", this.defaultAnim);

            if (GUILayout.Button("添加动画指令", GUILayout.Width(100f), GUILayout.Height(40f)))
            {
                var action = new PlotAnimationAction();
                allActionList.Add(action);
            }

            if (GUILayout.Button("添加(平移●旋转●缩放)指令", GUILayout.Width(100f), GUILayout.Height(40f)))
            {
                var action = new PlotTransformAction();
                allActionList.Add(action);
            }

            if (GUILayout.Button("添加坐骑指令", GUILayout.Width(100f), GUILayout.Height(40f)))
            {
                var action = new PlotTransformAction(PlotTransformAction.TweenType.Mount);
                allActionList.Add(action);
            }

            if (GUILayout.Button("添加对话指令", GUILayout.Width(100f), GUILayout.Height(40f)))
            {
                var action = new PlotTalkAction();
                allActionList.Add(action);
            }

            if (GUILayout.Button("添加特效指令", GUILayout.Width(100f), GUILayout.Height(40f)))
            {
                var action = new PlotFollowEffectAction();
                allActionList.Add(action);
            }
        }

        public override void RebuildActionList()
        {
            this.animationActionList.Clear();
            this.tweenActionList.Clear();
            this.talkActionList.Clear();
            this.followEffectList.Clear();

            for (int i = 0, imax = this.allActionList.Count; i < imax; ++i)
            {
                PlotAction action = this.allActionList[i];
                if (action is PlotAnimationAction)
                    this.animationActionList.Add(action as PlotAnimationAction);
                else if (action is PlotTransformAction)
                    this.tweenActionList.Add(action as PlotTransformAction);
                else if (action is PlotTalkAction)
                    this.talkActionList.Add(action as PlotTalkAction);
                else if (action is PlotFollowEffectAction)
                    this.followEffectList.Add(action as PlotFollowEffectAction);
            }
        }
#endif
    }
}
