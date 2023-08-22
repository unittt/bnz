using System;
using System.Collections.Generic;
using Pathfinding;
using LuaInterface;
using UnityEngine;


public class Map2DWalker : MonoBehaviour
{
    public Map2DWalker followWalker;
    private Seeker pathSeeker;
    private Path abPath;
    private int pathIndex;
    private bool isPathing;
    private bool isFollowing;
    private float followDis;
    private float followRate = 1.0f;
    private List<Vector3> linePath = new List<Vector3>();
    public List<Material> alphaMaterialList = new List<Material>();
    public int onMapID = 0;

    public Transform moveTransform;
    public Transform rotateTransform;
    public bool moveable = true;
    public float moveSpeed = 3.0f;
    public float rotateSpeed = 10.0f;
    private float moveNextDist = 0.5f;
    private float alpha = 1.0f;
	public float curAlpha = -1;
	private bool isIgnoreTransparent = false;
	private bool isStraightWalk = false;
	private float flyOffset;

	private Vector3 followPos = Vector3.zero;
	private int[] posRecord = new int[4];

	public Renderer[] renderArray;

    public float modelAlpha
    {
        get
        {
            return alpha;
        }
        set
        {
         //   SetTransparent(value);
        }
    }

    private LuaFunction luaEndCallback;
    private LuaFunction luaStartCallback;

    public void Awake()
    {

        pathSeeker = gameObject.AddComponent<Seeker>();
        SimpleSmoothModifier simpleModifier = gameObject.AddComponent<SimpleSmoothModifier>();
        simpleModifier.maxSegmentLength = 0.7f;
        simpleModifier.iterations = 2;
        simpleModifier.smoothType = SimpleSmoothModifier.SmoothType.OffsetSimple;
        SetPathMode(0);


    }

    public void OnDestroy()
    {
        moveTransform = null;
        rotateTransform = null;
        followWalker = null;
        if (isFollowing)
        {
            isFollowing = false;
            StopAllCoroutines();
        }
        if (luaEndCallback != null)
        {
            luaEndCallback.Dispose();
            luaEndCallback = null;
        }
        if (luaStartCallback != null)
        {
            luaStartCallback.Dispose();
            luaStartCallback = null;
        }
    }

    public void OnEnable()
    {
        pathSeeker.pathCallback = OnAstarPathCallback;
    }

    public void OnDisable()
    {
        ClearPath();
        pathSeeker.pathCallback = null;

    }

	public void Reset()
	{
		curAlpha = -1;
        if (renderArray == null)
            return;
		foreach (var r in renderArray) {
			if (r != null) {
				if (r.material.HasProperty (Alpha)) {
					r.material.SetColor(Alpha, Color.white);
				}
			}	

		}
		renderArray = null;
		ClearPath();

	}

    public void Update()
    {
        if (!moveable)
        {
            return;
        }

        if (isPathing)
        {
            Vector3 pos = GetNextPos(Time.deltaTime);
            if (pos != Vector3.zero)
            {
                Translate(pos);
            }
            else
            {	
                isPathing = false;
                if (luaEndCallback != null)
                {
                    luaEndCallback.Call();
                }
                ClearPath();
            }
        }

        UpdateZ();
        UpdateTransparent();
    }

    public void SetPathMode(int mode)
    {
        if (mode == 0)
        {
            pathSeeker.traversableTags = 1 << AstarPathManager.LayerGround;
        }
        else if (mode == 1)
        {
            pathSeeker.traversableTags = 1 << AstarPathManager.LayerGround | 1 << AstarPathManager.LayerSky;
        }
    }


    public void SetMapID(int mapid)
    {
        onMapID = mapid;
       // UpdateTransparent();
    }

    private void UpdateTransparent()
    {
        if (Map2D.CurrentMap != null && Map2D.CurrentMap.mapId == onMapID)
        {
			if (Map2D.CurrentMap.IsTransparent(moveTransform.position.x, moveTransform.position.y) && (!isIgnoreTransparent))
            {
                SetTransparent(0.5f);
            }
            else
            {
                SetTransparent(1f);
            }
        }
    }

    private Vector3 GetNextPos(float time)
    {
        List<Vector3> path = GetPath();
        if (path == null || path.Count == 0)
        {
            return Vector3.zero;
        }
        if (pathIndex >= path.Count)
        {
            pathIndex = path.Count - 1;
        }
        if (pathIndex < 0)
        {
            pathIndex = 0;
        }

        float movement = moveSpeed * time;
        if (followWalker != null)
        {
            movement = movement * followRate;
        }

        Vector3 curPos = moveTransform.position;
        curPos.z = 0;
        Vector3 dir = Vector3.zero;
        Vector3 waypoint = path[pathIndex];
        if (pathIndex == path.Count - 1)
        {
            dir = waypoint - curPos;
            float magn = dir.magnitude;
            float newmagn = 0;
            if (magn > 0.01)
            {
                newmagn = Mathf.Min(magn, movement);
                dir *= newmagn / magn;
                return dir;
            }
            else
            {
                return Vector3.zero;
            }
        }
        else
        {
            while (pathIndex != path.Count - 1 && (curPos - waypoint).sqrMagnitude < moveNextDist * moveNextDist)
            {
                pathIndex++;
                waypoint = path[pathIndex];
            }

            dir = waypoint - curPos;
            float magn = dir.magnitude;
            float newmagn = 0;
            if (magn > 0)
            {
                newmagn = Mathf.Min(magn, movement);
                dir *= newmagn / magn;
            }
            return dir;
        }
    }

	public void WalkTo(float x, float y, bool useStraight = true)
    {
		posRecord[0] = (int)x;
		posRecord[1] = (int)y;
		posRecord[2] = (int)moveTransform.position.x;
		posRecord[3] = (int)moveTransform.position.y;
        WalkTo(new Vector3(x, y, 0), useStraight);
    }

    public void WalkTo2(float x, float y)
    {
        WalkTo2(new Vector3(x, y, 0));
    }

    public void WalkTo3(float x, float y)
    {
        WalkTo3(new Vector3(x, y, 0));
    }

    public void StopWalk()
    {
        ClearPath();
    }
    
    
    public List<Vector3> GetPath()
    {
		if (linePath != null && linePath.Count != 0)
			
            return linePath;

        List<Vector3> path = Map2D.CurrentMap.GetCachePath(posRecord);
        if (path != null && path.Count != 0)
            return path;

        if (abPath != null)
            return abPath.vectorPath;

        return null;
    }

    private void WalkTo3(Vector3 pos)
    {
        ClearPath();
        Vector3 startPos = moveTransform.position;
        startPos.z = 0;
        if (GetLinePath3(startPos, pos))
        {
            OnLinePathCallback();
        }
    }

    private void WalkTo2(Vector3 pos)
    {
        ClearPath();
        Vector3 startPos = moveTransform.position;
        startPos.z = 0;
        if (GetLinePath2(startPos, pos))
        {
            OnLinePathCallback();
        }
    }

    private void WalkTo(Vector3 pos, bool useLine)
    {
        ClearPath();
        Vector3 startPos = moveTransform.position;
        startPos.z = 0; 

       if (useLine && GetLinePath(startPos, pos))
        {
            OnLinePathCallback();
			return;
        }
		List<Vector3> path = Map2D.CurrentMap.GetCachePath(posRecord);
		if (path != null)
		{
			// Debug.Log ("use cache path "+path.Count);
			OnLinePathCallback();
		}
        else
        {
            pathSeeker.StartPath(startPos, pos);
        }
    }

    private bool GetLinePath3(Vector3 startPos, Vector3 endPos)
    {
        linePath.Clear();
        if (Map2D.CurrentMap != null && Map2D.CurrentMap.mapId == onMapID)
        {
            linePath.Add(endPos);
            return true;
        }
        return false;
    }

    private bool GetLinePath2(Vector3 startPos, Vector3 endPos)
    {
        linePath.Clear();
        if (Map2D.CurrentMap != null && Map2D.CurrentMap.mapId == onMapID && Map2D.CurrentMap.IsInMapArea(startPos.x, startPos.y) && Map2D.CurrentMap.IsInMapArea(endPos.x, endPos.y))
        {
            linePath.Add(endPos);
            return true;
        }
        return false;
    }

    private bool GetLinePath(Vector3 startPos, Vector3 endPos)
    {
        linePath.Clear();
        if (Map2D.CurrentMap != null && Map2D.CurrentMap.mapId == onMapID && Map2D.CurrentMap.IsLinePath(startPos, endPos))
        {
            linePath.Add(endPos);
            return true;
        }
        return false;
    }

    private void OnLinePathCallback()
    {
        pathIndex = 0;
        isPathing = true;
        if (luaStartCallback != null)
        {
            luaStartCallback.Call();
        }
    }

    private void OnAstarPathCallback(Path p)
    {
        ABPath path = p as ABPath;
        if (path == null)
        {
            return;
        }
        path.Claim(this);
        if (path.error)
        {
            path.Release(this);
            return;
        }
        abPath = path;
        pathIndex = 0;
        isPathing = true;
        if (luaStartCallback != null)
        {
            luaStartCallback.Call();
        }

        // Debug.Log("OnAstarPathCallback");
        // List<Vector3> lst = GetPath();
        // for (int i = 0; i < lst.Count; i++)
        // {
        //    Debug.Log(i + " " + lst[i]);
        // }
		Map2D.CurrentMap.AddSeekRecord (posRecord, abPath.vectorPath);
    }

    //private void CancelPath()
    //{
    //    if (pathSeeker != null && !pathSeeker.IsDone())
    //    {
    //        pathSeeker.GetCurrentPath().Error();
    //    }
    //}

    private void ClearPath()
    {
        if (abPath != null)
        {
            abPath.Release(this);
            abPath = null;
        }
        pathIndex = 0;
        isPathing = false;
        linePath.Clear();
    }
    
    private void UpdateZ()
    {
        if (onMapID != 0 && Map2D.CurrentMap != null && Map2D.CurrentMap.mapId == onMapID)
        {
            //Debug.Log("CalcZ " + y + "  " + Map2D.CurrentMap.height + "  " + y / Map2D.CurrentMap.height * 100f);
            Vector3 pos = moveTransform.position;
			pos.z = pos.y * 1.7320508075689f - flyOffset;
            moveTransform.position = pos;
        }
    }

    private void Translate(Vector3 pos)
    {
        //位置
        moveTransform.Translate(pos, Space.World);

        //方向
        pos = new Vector3(pos.x, 0, pos.y);
        Quaternion oldRotation = rotateTransform.localRotation;
        if (pos.sqrMagnitude < 0.00001)
            return;

        Quaternion newRotation = Quaternion.LookRotation(pos);
        Vector3 angle = Quaternion.Slerp(oldRotation, newRotation, rotateSpeed * Time.deltaTime).eulerAngles;
        angle.x = 0f;
        angle.z = 0f;
		rotateTransform.localEulerAngles = angle;
    }

    public Vector3 GetWayPoint()
    {
        List<Vector3> path = GetPath();
        if (path != null)
        {
            if(pathIndex >= 0 && pathIndex < path.Count)
            {
                return path[pathIndex];
            }
        }
        return Vector3.zero;
    }

    public int GetWayPointIndex()
    {
        return pathIndex;
    }

	public void SetFlyOffset(float offset)
	{
		flyOffset = offset;
	}

    public void Follow(Map2DWalker walker, float distance)
    {
        if (followWalker != null)
            ClearPath();

        followWalker = walker;
        followDis = distance;
        if (followWalker == null)
        {
            isFollowing = false;
            StopAllCoroutines();
        }
        else if (!isFollowing)
        {
            isFollowing = true;
            StartCoroutine(UpdateFollowWalker(0.1f));
        }
    }

	public void SetFollowDis(float distance)
	{	
		followDis = distance;
	}

    private System.Collections.IEnumerator UpdateFollowWalker(float intervalTime)
    {
        while (isFollowing)
        {
            yield return new WaitForSeconds(intervalTime);
            if (followWalker == null)
            {
                continue;
            }
            Vector3 selfPos = moveTransform.position;
            selfPos.z = 0;
            Vector3 targetPos = followWalker.moveTransform.position;
            targetPos.z = 0;
            Vector3 pos = targetPos - followWalker.rotateTransform.forward * followDis;
            pos.z = 0;
            float distance = Vector3.Distance(selfPos, targetPos);
            if (distance <= followDis)
            {
                continue;
            }
			if (Vector3.Distance(selfPos, pos) < 0.1)
            {
                continue;
            }
            followRate = 0.5f + Mathf.Lerp(0f, 0.8f, (distance - followDis) / followDis);
            FollowTo(pos);
        }
    }



    public void FollowTo(Vector3 endPos)
    {
		if (Vector3.Distance(followPos,endPos) < 0.01f)
		{
			return;
		}
		followPos = endPos;
        //linePath.Clear();
        //linePath.Add(endPos);
        //OnLinePathCallback();
		if (isStraightWalk) {
			WalkTo2(endPos.x, endPos.y);
		} else {
			WalkTo(endPos.x, endPos.y);
		}
        
    }

	public void SetStraightWalk(bool isStraight)
	{
		isStraightWalk = isStraight;
	}

    public void SetWalkEndCallback(LuaFunction callback)
    {
        if (this.luaEndCallback != null)
        {
            this.luaEndCallback.Dispose();
            this.luaEndCallback = null;
        }
        this.luaEndCallback = callback;
    }

    public void SetWalkStartCallback(LuaFunction callback)
    {
        if (this.luaStartCallback != null)
        {
            this.luaStartCallback.Dispose();
            this.luaStartCallback = null;
        }
        this.luaStartCallback = callback;
    }

   
    private static int Alpha
    {
        get
        {
            int alpha = Shader.PropertyToID("_Alpha");
            return alpha;
        }
    }
    
    public void AddAlphaMaterial(Material r)
    {
		if (!alphaMaterialList.Contains(r))
		{
			alphaMaterialList.Add(r);
		}
    }

    public void DelAlphaMaterial(Material r)
    {
        if (alphaMaterialList.Contains(r))
        {
            alphaMaterialList.Remove(r);
        }
    }

    public void ClearAlphaMaterial()
    {
        alphaMaterialList.Clear();
    }

	public void ModelDoneFinish()
	{
		renderArray = gameObject.transform.GetComponentsInChildren<Renderer> (true);
		curAlpha = -1;

	}

	public void IgnoreTransparent(bool state)
	{
		isIgnoreTransparent = state;
	}


    public void SetTransparent(float alpha)
    {

		if (renderArray == null)
			return;

		if (curAlpha == alpha) 
			return;

		curAlpha = alpha;
	
		foreach (var r in renderArray) {
			if (r != null) {
				if (r.material.HasProperty (Alpha)) {
					r.material.SetColor(Alpha, new Color(1f, 1f, 1f, alpha));
				}
			}	

		}
			
    }

    public void SetTraversableTags(int tags)
    {
        if(pathSeeker != null)
        {
            pathSeeker.traversableTags = tags;
        }
    }

}
