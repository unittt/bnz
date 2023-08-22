using UnityEngine;
using System.Collections;

public class UIEffectRenderQueue : MonoBehaviour
{
    private UIWidget _widget;
	private Renderer[] _rendererList;
	public int renderQ = 0;
	public bool needClip = false;
    private GameObject mAttach;
	private UIPanel _panel;

    public GameObject attachGameObject
    {
        get
        {
            return mAttach;
        }
        set
        {
            mAttach = value;
            if (_rendererList == null)
                _rendererList = this.GetComponentsInChildren<Renderer>(true);

            if (_rendererList != null)
            {
                UIWidget w = mAttach.GetComponent<UIWidget>();
                if (w != null)
                {
                    if (w is UIBasicSprite || w is UILabel)
                    {
                        _widget = w;
                        RecaluatePanelDepth();
                        RecalculateEffectRegion();
                        _widget.onRender = OnRenderWidget;
                    }
                }

            }
        }
    }

    public void RecaluatePanelDepth()
    {
        if (_widget == null)
        {
            return;
        }
        _panel = gameObject.GetComponent<UIPanel>();
        if (_panel == null)
        {
            _panel = gameObject.AddComponent<UIPanel>();
        }
        UIPanel parent = NGUITools.FindInParents<UIPanel>(_widget.gameObject);
        if (parent != null)
        {
            _panel.depth = parent.depth + 1;
        }
    }

	public void RecalculateEffectRegion ()
	{
        if (_widget == null)
            return;
        if (_rendererList == null)
			return;
		if (needClip) {
            UIPanel panel = NGUITools.FindInParents<UIPanel>(_widget.gameObject);
            if (panel == null)
            {
                return;
            }
            Vector3[] worldCorners = panel.worldCorners;
            Camera uiCam = NGUITools.FindCameraForLayer(panel.cachedGameObject.layer);
			if (uiCam == null)
			{
				return;
			}
            Vector3 bottomLeft = uiCam.WorldToViewportPoint (worldCorners [0]);
			Vector3 topRight = uiCam.WorldToViewportPoint (worldCorners [2]);

			//因为WorldToViewportPoint取得的视口参数是bottomLeft为(0,0)，topRight为(1,1)
			//需要但Shader中的视口区间为bottomLeft为(-1,-1)，topRight为(1,1),故需要做区域映射的运算
			Vector4 cr = new Vector4 (2 * bottomLeft.x - 1f, 2 * bottomLeft.y - 1f, 2 * topRight.x - 1f, 2 * topRight.y - 1f);

			for (int i = 0; i < _rendererList.Length; ++i) {
				Material mat = _rendererList [i].material;
                if(mat != null)
					mat.SetVector ("_ClipRange", cr);
			}
		} else {
			for (int i = 0; i < _rendererList.Length; ++i) {
				Material mat = _rendererList [i].material;
                if (mat != null)
                    mat.SetVector ("_ClipRange", new Vector4 (-1f, -1f, 1f, 1f));
			}
		}
	}

	void OnEnable ()
	{
        if (_widget != null)
        {
            _widget.onRender = OnRenderWidget;
        }
	}

	void OnDisable ()
	{
		if (_widget != null) {
			_widget.onRender = null;
		}
	}

	void OnRenderWidget (Material mat)
	{
        UpdateRenderQ(_panel.startingRenderQueue);
	}

	public void UpdateRenderQ (int newRenderQ)
	{
		renderQ = newRenderQ;
		for (int i = 0; i < _rendererList.Length; ++i) {
			if (_rendererList [i] != null)
				_rendererList [i].material.renderQueue = newRenderQ;
		}
	}

	//销毁时清除clone出来的材质球
	void OnDestroy ()
	{
		if (_rendererList != null) {
			for (int i = 0; i < _rendererList.Length; ++i) {
				if (_rendererList [i] != null && _rendererList [i].material != null) {
					DestroyImmediate (_rendererList [i].material);
				}
			}
		}
	}
}
