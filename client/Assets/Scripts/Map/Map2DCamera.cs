using System.Collections;
using UnityEngine;
using DG.Tweening;


public class Map2DCamera : MonoBehaviour
{
    public static Map2DCamera Instance
    {
        get;
        protected set;
    }


    public Transform target;
    public bool followTarget = false;

    public bool isSmooth = true;
    public float damping = 30f;

    public float xMin;
    public float xMax = 999f;
    public float yMin;
    public float yMax = 999f;

	public Vector3 offset = Vector3.zero;

    private Transform mTrans;
    public Transform cacheTrans
    {
        get { return mTrans; }
    }

    public Map2D curMap;
    private Camera camera;
    public Vector3 lastCachePos;

    void Awake()
    {
        Instance = this;
        mTrans = this.transform;
        lastCachePos = mTrans.localPosition;
        camera = GetComponent<Camera>();
    }

    public void Follow(Transform t)
    {
        target = t;
        followTarget = true;
        SyncTargetPos();
    }

    public void SyncTargetPos()
    {
        if (target != null && mTrans != null)
        {
            lastCachePos = mTrans.localPosition;

			var end = target.position + offset;
            end.x = Mathf.Clamp(end.x, xMin, xMax);
            end.y = Mathf.Clamp(end.y, yMin, yMax);
            end.z = mTrans.position.z;
            mTrans.position = end;

            if (curMap != null && !curMap.isReleased)
            {
                curMap.CallLateUpdate(end, true);
            }
        }
    }

    //public void UpdateViewRange(float xMin, float xMax, float yMin, float yMax)
    //{
    //    this.xMin = xMin;
    //    this.xMax = xMax;
    //    this.yMin = yMin;
    //    this.yMax = yMax;
    //    SyncTargetPos();
    //}

    private float passTime = 0f;
    private bool isMoving = false;
    public float speedUpTime = 0.3f;

    public void CallLateUpdate()
    {
		
        if (target == null || !followTarget)
            return;

		var pos = target.position + offset;
        
        float followRate = 1f;
        if (!isMoving)
        {
            isMoving = true;
        }
        else
        {
            passTime += Time.deltaTime;
            followRate = Mathf.Min(passTime / speedUpTime, 1f);
			if(Vector2.SqrMagnitude(mTrans.localPosition - pos) < 0.01)
            {
                isMoving = false;
                followRate = 0;
                passTime = 0;
            }
        }

        if (!isMoving)
            return;

        lastCachePos = mTrans.localPosition;
        Vector3 start = mTrans.position;
		Vector3 end = new Vector3(pos.x, pos.y, 0);
        Vector3 movePos = isSmooth ? Vector3.MoveTowards(start, end, Time.deltaTime * damping * followRate) : end;

        movePos.x = Mathf.Clamp(movePos.x, xMin, xMax);
        movePos.y = Mathf.Clamp(movePos.y, yMin, yMax);
        movePos.z = start.z;
        mTrans.position = movePos;

        if (curMap != null && !curMap.isReleased)
        {
            curMap.CallLateUpdate(movePos, false);
        }
    }

    public void SetCurMap(Map2D map2D)
    {
        curMap = map2D;
		UpdateCameraSize();
    }
		
	public void SetCameraOffsetY(float y, bool isAni, float t = 0.6f)
	{
		if (isAni) {
			var v3 = new Vector3 (0, y, 0);
			var tween = DOTween.To(() => offset, v => offset = v, v3, t).SetEase(Ease.InSine).OnUpdate(
				() => {
					UpdateCameraSize();
				}
			);	
		} else {
			offset = new Vector3 (0, y, 0);
		}
	
	}
		
	public void UpdateCameraSize()
	{
		float halfHeight = camera.orthographicSize;
		float halfWidth = camera.orthographicSize * camera.aspect;
		this.xMin = halfWidth;
		this.xMax = curMap.width - halfWidth;
		this.yMin = halfHeight;
		this.yMax = curMap.height - halfHeight;
		Map2D.cameraHalfHeight = halfHeight;
		Map2D.cameraHalfWidth = halfWidth;
		SyncTargetPos();
	}

    public void Reset()
    {
        if (mTrans != null)
        {
            SyncTargetPos();
            /*
            Vector3 finlEndPoint = new Vector3(0, 0, mTrans.localPosition.z);
            finlEndPoint.x = Mathf.Clamp(finlEndPoint.x, xMin, xMax);
            finlEndPoint.y = Mathf.Clamp(finlEndPoint.y, yMin, yMax);
            mTrans.localPosition = finlEndPoint;
            */
        }

        target = null;
        followTarget = false;
    }
}
