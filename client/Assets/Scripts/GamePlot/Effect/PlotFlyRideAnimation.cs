// using System;
// using System.Collections;
// using System.Collections.Generic;
// using UnityEngine;
// using AppDto;
// using AppServices;

// namespace GamePlot
// {
//     //用于播放骑乘或骑下飞行坐骑时播放的动画效果
//     public class PlotFlyRideAnimation
//     {
//         #region 动画效果数值

//         private const int landWidth = 1024;
//         private const int landHeight = 768;

//         public static float upDisappearTime = 0.1f; //上升时玩家在什么时候消失
//         public static float downShowTime = 0.3f; //下降时玩家什么时候出现

//         public static int skyWidth = 1300; //在天上时屏幕宽度， 这个值越大， 地下的模型就越小

//         public static int skyHeight //在天上时屏幕的高度
//         {
//             get { return (int) ((float) skyWidth/landWidth*landHeight); }
//         }

//         public static float skyScale = 1.2f; //模型在天上时的缩放大小
//         public static float flyRidePerSecondScalpSpeed = 5f; //飞行坐骑大小改变的速度， 已每秒改变的数值为准

//         public static int widthPerSeconeSpeed = 1000; //摄像机改变的速度
//         public static int heightSeconeSpeed = 1000; //摄像机改变的速度

//         #endregion

//         private List<Coroutine> mCoroutineList = new List<Coroutine>();
//         private bool mIsPlayAnimation = false;

//         public bool IsPlayAnimation
//         {
//             get { return mIsPlayAnimation; }
//         }

//         private PlotCharacterController mReferPlayerView; //动画播放中， 参照的PlotCharacterController

//         public enum AnimationState
//         {
//             Begin = 0,
//             End = 1,
//         };

//         private static List<PlotFlyRideAnimation> mFlyRideAnimationList = new List<PlotFlyRideAnimation>();

//         public static PlotFlyRideAnimation Crate(PlotCharacterController pPlayerView)
//         {
//             if (pPlayerView == null) return null;

//             PlotFlyRideAnimation tFlyRideAnimation = new PlotFlyRideAnimation();
//             tFlyRideAnimation.mReferPlayerView = pPlayerView;

//             mFlyRideAnimationList.Add(tFlyRideAnimation);

//             return tFlyRideAnimation;
//         }

//         //播放骑上或骑下飞行坐骑的动画效果

//         public void PlayRideAnimation()
//         {
//             mIsPlayAnimation = true;

//             mCoroutineList.Add(JSTimer.Instance.StartCoroutine(PlayRideAnimationCoroutine()));
//         }

//         private IEnumerator PlayRideAnimationCoroutine()
//         {
//             bool tUp = mReferPlayerView.GetDetailRideStatus(false) == PlayerView.DetailRideStatus.RideFlyMount;

//             float tEffectScale = tUp ? 1f : skyScale;
//             float tPlayTime = 1f;
//             PlayEffect("game_eff_1002", tPlayTime, tEffectScale);

//             yield return new WaitForSeconds(upDisappearTime);

//             mReferPlayerView.SetModelActive(false);
//             mReferPlayerView.UpdateModel();

//             //改变相机分辨率
//             Coroutine tCoroutine = JSTimer.Instance.StartCoroutine(ChangeCameraResolutionCoroutine(tUp));
//             mCoroutineList.Add(tCoroutine);
//             yield return tCoroutine;

//             if (IsContainHeroView() == true)
//                 SkyCloudEffectController.Instance.SetSkyActive(tUp);


//             //等待模型加载完成
//             while (mReferPlayerView.IsLoadingModel() == true)
//             {
//                 //       Debug.LogError("飞行坐骑动画： 等待模型加载完毕");
//                 yield return null;
//             }

//             mReferPlayerView.SetModelActive(true);
//             mReferPlayerView.SetPersonActive(false);
//             mReferPlayerView.SetModelScale(0f);

//             //缩放坐骑大小
//             tCoroutine = JSTimer.Instance.StartCoroutine(ChangeRideScale(tUp));
//             mCoroutineList.Add(tCoroutine);
//             yield return tCoroutine;

//             //Debug.LogError("飞行坐骑动画： 播放下降特效");
//             tEffectScale = tUp ? skyScale : 1f;
//             PlayEffect("game_eff_1003", tPlayTime, tEffectScale);

//             yield return new WaitForSeconds(downShowTime);

//             //Debug.LogError("飞行坐骑动画： 显示人物模型");
//             mReferPlayerView.SetPersonActive(true);

//             //特殊处理： 飞行坐骑的播放都只有一个idle动作， 但人物有多个， 在下降的时候， 如果玩家在移动， 可能造成在idle的情况下人物位置移动（因为gameobject在禁用掉之后， 
//             //           animator的动画状态也没有了，重新启用GameObject，Animator用的是默认动作， 造成PlotCharacterController中记录的动作状态跟实际播放的不符，
//             //           所以需要调用PlotCharacterController.InitPlayerAnimation来强行设置动画状态
//             if (tUp == false)
//             {
//                 mReferPlayerView.InitPlayerAnimation();
//             }


//             mFlyRideAnimationList.Remove(this);
//             mCoroutineList.Clear();
//             mIsPlayAnimation = false;
//         }

//         //以协程的方式一点一点地改变相机的分辨率
//         IEnumerator ChangeCameraResolutionCoroutine(bool pUp)
//         {
//             if (IsContainHeroView() == false)
//                 yield break;

//             int tTargetWidth = pUp == true ? skyWidth : landWidth;
//             int tTargetHeight = pUp == true ? skyHeight : landHeight;

//             int perSecondMoveWidth = widthPerSeconeSpeed*(pUp ? 1 : -1);
//             int perSecondMoveHeight = heightSeconeSpeed*(pUp ? 1 : -1);

//             while (Camera2DController.Instance.ResolutionHeight != tTargetHeight ||
//                    Camera2DController.Instance.ResolutionWidth != tTargetWidth)
//             {
//                 //Debug.LogError("飞行坐骑动画： 改变相机分辨率");
//                 int tNewHeight = Camera2DController.Instance.ResolutionHeight +
//                                  (int) (perSecondMoveHeight*Time.deltaTime);
//                 int tNewWidth = Camera2DController.Instance.ResolutionWidth + (int) (perSecondMoveWidth*Time.deltaTime);

//                 tNewHeight = pUp ? Math.Min(skyHeight, tNewHeight) : Math.Max(tNewHeight, landHeight);
//                 tNewWidth = pUp ? Math.Min(skyWidth, tNewWidth) : Math.Max(tNewWidth, landWidth);

//                 WorldMapLoader.Instance.World2dMapLoader.ChangeCameraResolution(tNewWidth, tNewHeight);

//                 yield return null;
//             }
//         }

//         //改变坐骑的缩放
//         IEnumerator ChangeRideScale(bool pUp)
//         {
//             float tTargetScale = pUp ? skyScale : 1f;
//             float tCurScale = 0f;
//             while (mReferPlayerView.GetModelScale(ref tCurScale) == true && tCurScale != tTargetScale)
//             {
//                 //      Debug.LogError("飞行坐骑动画： 坐骑模型缩放 ");
//                 float tDeltaScale = flyRidePerSecondScalpSpeed*Time.deltaTime*(pUp ? 1f : -1f);
//                 float tNewScale = tCurScale + tDeltaScale;
//                 tNewScale = pUp ? Mathf.Min(tNewScale, tTargetScale) : Mathf.Max(tNewScale, tTargetScale);

//                 mReferPlayerView.SetModelScale(tNewScale);
//                 yield return null;
//             }
//         }


//         //播放特效
//         void PlayEffect(string pName, float pEffTime, float pScale)
//         {
//             string tEffpath = GameEffectConst.GetGameEffectPath(pName);
//             OneShotSceneEffect.BeginFollowEffect(tEffpath, mReferPlayerView.transform, 1f, pScale, (pEffectGo) =>
//             {
//                 if (pEffectGo == null || pEffectGo.transform.parent == null)
//                     return;

//                 ParticleScaler scaler = pEffectGo.GetMissingComponent<ParticleScaler>();
//                 if (scaler != null)
//                 {
//                     scaler.SetScale(pScale);
//                 }

//                 //在空中播放的特效高度需调整， 看起来效果好一点
//                 if (pScale != 1)
//                 {
//                     if (pName == "game_eff_1003")
//                         pEffectGo.transform.localPosition += new Vector3(0f, 0.5f, 0f);

//                     if (pName == "game_eff_1002")
//                         pEffectGo.transform.localPosition += new Vector3(0f, 1f, 0f);
//                 }

//                 AudioManager.Instance.PlaySound("sound_skill_2711");
//             });
//         }

//         public bool IsContainHeroView()
//         {
//             return true;
//         }

//         public void CancelFlyRideAnimation()
//         {
//             mIsPlayAnimation = false;

//             //停掉协程
//             mCoroutineList.ForEach(pCoroutine =>
//             {
//                 if (pCoroutine != null)
//                     JSTimer.Instance.StopCoroutine(pCoroutine);
//             });

//             mCoroutineList.Clear();
//         }
//     }
// }