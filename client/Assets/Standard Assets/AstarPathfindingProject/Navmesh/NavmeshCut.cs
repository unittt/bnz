﻿
using UnityEngine;
using System.Collections.Generic;

namespace Pathfinding {
	/** Navmesh cutting is used for fast recast graph updates.
	 *
	 * Navmesh cutting is used to cut holes into an existing navmesh generated by a recast graph.
	 * Recast graphs usually only allow either just changing parameters on existing nodes (e.g make a whole triangle unwalkable) which is not very flexible or recalculate a whole tile which is pretty slow.
	 * With navmesh cutting you can remove (cut) parts of the navmesh that is blocked by obstacles such as a new building in an RTS game however you cannot add anything new to the navmesh or change
	 * the positions of the nodes.
	 *
	 * \htmlonly
	 * <iframe width="640" height="480" src="//www.youtube.com/embed/qXi5qhhGNIw" frameborder="0" allowfullscreen>
	 * </iframe>
	 * \endhtmlonly
	 *
	 * The NavmeshCut component uses a 2D shape to cut the navmesh with. A rectangle and circle shape is built in, but you can also specify a custom mesh to use.
	 * The custom mesh should be a flat 2D shape like in the image below. The script will then find the contour of that mesh and use that shape as the cut.
	 * Make sure that all normals are smooth and that the mesh contains no UV information. Otherwise Unity might split a vertex and then the script will not
	 * find the correct contour. You should not use a very high polygon mesh since that will create a lot of nodes in the navmesh graph and slow
	 * down pathfinding because of that. For very high polygon meshes it might even cause more suboptimal paths to be generated if it causes many
	 * thin triangles to be added to the navmesh.
	 * \shadowimage{navmeshcut_mesh.png}
	 *
	 * Note that the shape is not 3D so if you rotate the cut you will see that the 2D shape will be rotated and then just projected down on the XZ plane.
	 *
	 * To use a navmesh cut in your scene you need to have a TileHandlerHelper script somewhere in your scene. You should only have one though.
	 * That script will take care of checking all the NavmeshCut components to see if they need to update the navmesh.
	 *
	 * In the scene view the NavmeshCut looks like an extruded 2D shape because a navmesh cut also has a height. It will only cut the part of the
	 * navmesh which it touches. For performance it only checks the bounding boxes of the triangles in the navmesh, so it may cut triangles
	 * whoose bounding boxes it intersects even if the triangle does not intersect the extructed shape. However in most cases this does not make a large difference.
	 *
	 * It is also possible to set the navmesh cut to dual mode by setting the #isDual field to true. This will prevent it from cutting a hole in the navmesh
	 * and it will instead just split the navmesh along the border but keep both the interior and the exterior. This can be useful if you for example
	 * want to change the penalty of some region which does not neatly line up with the navmesh triangles. It is often combined with the GraphUpdateScene component
	 * (however note that the GraphUpdateScene component will not automatically reapply the penalty if the graph is updated again).
	 *
	 * By default the navmesh cut does not take rotation or scaling into account. If you want to do that, you can set the #useRotation field to true.
	 * This is a bit slower, but it is not a very large difference.
	 *
	 * \astarpro
	 * \see http://www.arongranberg.com/2013/08/navmesh-cutting/
	 */
	[AddComponentMenu("Pathfinding/Navmesh/Navmesh Cut")]
    /*[HelpURL("http://arongranberg.com/astar/docs/class_pathfinding_1_1_navmesh_cut.php")]*/
    public class NavmeshCut : MonoBehaviour {
		public enum MeshType {
			Rectangle,
			Circle,
			CustomMesh
		}

		private static List<NavmeshCut> allCuts = new List<NavmeshCut>();

		/** Called every time a NavmeshCut component is destroyed. */
		public static event System.Action<NavmeshCut> OnDestroyCallback;

		private static void AddCut (NavmeshCut obj) {
			allCuts.Add(obj);
		}

		private static void RemoveCut (NavmeshCut obj) {
			allCuts.Remove(obj);
		}

		/** Get all active instances which intersect the bounds */
		public static List<NavmeshCut> GetAllInRange (Bounds b) {
			List<NavmeshCut> cuts = Pathfinding.Util.ListPool<NavmeshCut>.Claim();
			for (int i = 0; i < allCuts.Count; i++) {
				if (allCuts[i].enabled && Intersects(b, allCuts[i].GetBounds())) {
					cuts.Add(allCuts[i]);
				}
			}
			return cuts;
		}

		/** True if \a b1 and \a b2 intersects.
		 *
		 * \note Faster than Unity's built in version. See http://forum.unity3d.com/threads/204243-Slow-Unity-Math-Please-Unity-Tech-keep-core-math-fast?p=1404070#post1404070
		 */
		private static bool Intersects (Bounds b1, Bounds b2) {
			Vector3 min1 = b1.min;
			Vector3 max1 = b1.max;
			Vector3 min2 = b2.min;
			Vector3 max2 = b2.max;

			return min1.x <= max2.x && max1.x >= min2.x && min1.y <= max2.y && max1.y >= min2.y && min1.z <= max2.z && max1.z >= min2.z;
		}

		/** Returns a list with all NavmeshCut components in the scene.
		 * \warning Do not modify this array
		 */
		public static List<NavmeshCut> GetAll () {
			return allCuts;
		}

		public MeshType type;

		/** Custom mesh to use.
		 * The contour(s) of the mesh will be extracted.
		 * If you get the "max perturbations" error when cutting with this, check the normals on the mesh.
		 * They should all point in the same direction. Try flipping them if that does not help.
		 */
		public Mesh mesh;

		/** Size of the rectangle */
		public Vector2 rectangleSize = new Vector2(1, 1);

		/** Radius of the circle */
		public float circleRadius = 1;

		/** Number of vertices on the circle */
		public int circleResolution = 6;
		public float height = 1;

		/** Scale of the custom mesh, if used */
		public float meshScale = 1;

		public Vector3 center;

		/** Distance between positions to require an update of the navmesh.
		 * A smaller distance gives better accuracy, but requires more updates when moving the object over time,
		 * so it is often slower.
		 *
		 * \note Dynamic updating requires a TileHandlerHelper somewhere in the scene.
		 */
		public float updateDistance = 0.4f;

		/** Only makes a split in the navmesh, but does not remove the geometry to make a hole.
		 * This is slower than a normal cut
		 */
		public bool isDual;

		/** Cuts geometry added by a NavmeshAdd component.
		 * You rarely need to change this
		 */
		public bool cutsAddedGeom = true;

		/** How many degrees rotation that is required for an update to the navmesh.
		 * Should be between 0 and 180.
		 *
		 * \note Dynamic updating requires a Tile Handler Helper somewhere in the scene.
		 */
		public float updateRotationDistance = 10;

		/** Includes rotation in calculations.
		 * This is slower since a lot more matrix multiplications are needed but gives more flexibility.
		 */
		public bool useRotation;

		Vector3[][] contours;

		/** cached transform component */
		protected Transform tr;
		Mesh lastMesh;
		Vector3 lastPosition;
		Quaternion lastRotation;
		bool wasEnabled;
		Bounds lastBounds;

		public Bounds LastBounds {
			get {
				return lastBounds;
			}
		}

		public void Awake () {
			AddCut(this);
		}

		public void OnEnable () {
			tr = transform;
			lastPosition = new Vector3(float.PositiveInfinity, float.PositiveInfinity, float.PositiveInfinity);
			lastRotation = tr.rotation;
		}

		public void OnDestroy () {
			if (OnDestroyCallback != null) OnDestroyCallback(this);
			RemoveCut(this);
		}

		/** Cached variable, to avoid allocations */
		static readonly Dictionary<Int2, int> edges = new Dictionary<Int2, int>();
		/** Cached variable, to avoid allocations */
		static readonly Dictionary<int, int> pointers = new Dictionary<int, int>();

		/** Forces this navmesh cut to update the navmesh.
		 *
		 * \note Dynamic updating requires a Tile Handler Helper somewhere in the scene.
		 * This update is not instant, it is done the next time the TileHandlerHelper checks this instance for
		 * if it needs updating.
		 *
		 * \see TileHandlerHelper.ForceUpdate()
		 */
		public void ForceUpdate () {
			lastPosition = new Vector3(float.PositiveInfinity, float.PositiveInfinity, float.PositiveInfinity);
		}

		/** Returns true if this object has moved so much that it requires an update.
		 * When an update to the navmesh has been done, call NotifyUpdated to be able to get
		 * relavant output from this method again.
		 */
		public bool RequiresUpdate () {
			return wasEnabled != enabled || (wasEnabled && ((tr.position-lastPosition).sqrMagnitude > updateDistance*updateDistance || (useRotation && (Quaternion.Angle(lastRotation, tr.rotation) > updateRotationDistance))));
		}

		/**
		 * Called whenever this navmesh cut is used to update the navmesh.
		 * Called once for each tile the navmesh cut is in.
		 * You can override this method to execute custom actions whenever this happens.
		 */
		public virtual void UsedForCut () {
		}

		/** Internal method to notify the NavmeshCut that it has just been used to update the navmesh */
		public void NotifyUpdated () {
			wasEnabled = enabled;

			if (wasEnabled) {
				lastPosition = tr.position;
				lastBounds = GetBounds();

				if (useRotation) {
					lastRotation = tr.rotation;
				}
			}
		}

		void CalculateMeshContour () {
			if (mesh == null) return;

			edges.Clear();
			pointers.Clear();

			Vector3[] verts = mesh.vertices;
			int[] tris = mesh.triangles;
			for (int i = 0; i < tris.Length; i += 3) {
				// Make sure it is clockwise
				if (VectorMath.IsClockwiseXZ(verts[tris[i+0]], verts[tris[i+1]], verts[tris[i+2]])) {
					int tmp = tris[i+0];
					tris[i+0] = tris[i+2];
					tris[i+2] = tmp;
				}

				edges[new Int2(tris[i+0], tris[i+1])] = i;
				edges[new Int2(tris[i+1], tris[i+2])] = i;
				edges[new Int2(tris[i+2], tris[i+0])] = i;
			}

			// Construct a list of pointers along all edges
			for (int i = 0; i < tris.Length; i += 3) {
				for (int j = 0; j < 3; j++) {
					if (!edges.ContainsKey(new Int2(tris[i+((j+1)%3)], tris[i+((j+0)%3)]))) {
						pointers[tris[i+((j+0)%3)]] = tris[i+((j+1)%3)];
					}
				}
			}

			var contourBuffer = new List<Vector3[]>();

			List<Vector3> buffer = Pathfinding.Util.ListPool<Vector3>.Claim();

			// Follow edge pointers to generate the contours
			for (int i = 0; i < verts.Length; i++) {
				if (pointers.ContainsKey(i)) {
					buffer.Clear();

					int s = i;
					do {
						int tmp = pointers[s];

						//This path has been taken before
						if (tmp == -1) break;

						pointers[s] = -1;
						buffer.Add(verts[s]);
						s = tmp;

						if (s == -1) {
							Debug.LogError("Invalid Mesh '"  + mesh.name + " in " + gameObject.name);
							break;
						}
					} while (s != i);

					if (buffer.Count > 0) contourBuffer.Add(buffer.ToArray());
				}
			}

			// Return lists to the pool
			Pathfinding.Util.ListPool<Vector3>.Release(buffer);

			contours = contourBuffer.ToArray();
		}

		/** World space bounds of this cut */
		public Bounds GetBounds () {
			var bounds = new Bounds();

			switch (type) {
			case MeshType.Rectangle:
				if (useRotation) {
					Matrix4x4 m = tr.localToWorldMatrix;
					// Calculate the bounds by encapsulating each of the 8 corners in a bounds object
					bounds = new Bounds(m.MultiplyPoint3x4(center + new Vector3(-rectangleSize.x, -height, -rectangleSize.y)*0.5f), Vector3.zero);
					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(rectangleSize.x, -height, -rectangleSize.y)*0.5f));
					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(rectangleSize.x, -height, rectangleSize.y)*0.5f));
					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(-rectangleSize.x, -height, rectangleSize.y)*0.5f));

					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(-rectangleSize.x, height, -rectangleSize.y)*0.5f));
					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(rectangleSize.x, height, -rectangleSize.y)*0.5f));
					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(rectangleSize.x, height, rectangleSize.y)*0.5f));
					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(-rectangleSize.x, height, rectangleSize.y)*0.5f));
				} else {
					bounds = new Bounds(tr.position+center, new Vector3(rectangleSize.x, height, rectangleSize.y));
				}
				break;
			case MeshType.Circle:
				if (useRotation) {
					Matrix4x4 m = tr.localToWorldMatrix;
					bounds = new Bounds(m.MultiplyPoint3x4(center), new Vector3(circleRadius*2, height, circleRadius*2));
				} else {
					bounds = new Bounds(transform.position+center, new Vector3(circleRadius*2, height, circleRadius*2));
				}
				break;
			case MeshType.CustomMesh:
				if (mesh == null) break;

				Bounds b = mesh.bounds;
				if (useRotation) {
					Matrix4x4 m = tr.localToWorldMatrix;
					b.center *= meshScale;
					b.size *= meshScale;

					bounds = new Bounds(m.MultiplyPoint3x4(center + b.center), Vector3.zero);

					Vector3 mx = b.max;
					Vector3 mn = b.min;

					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(mx.x, mx.y, mx.z)));
					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(mn.x, mx.y, mx.z)));
					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(mn.x, mx.y, mn.z)));
					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(mx.x, mx.y, mn.z)));

					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(mx.x, mn.y, mx.z)));
					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(mn.x, mn.y, mx.z)));
					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(mn.x, mn.y, mn.z)));
					bounds.Encapsulate(m.MultiplyPoint3x4(center + new Vector3(mx.x, mn.y, mn.z)));

					Vector3 size = bounds.size;
					size.y = Mathf.Max(size.y, height * tr.lossyScale.y);
					bounds.size = size;
				} else {
					Vector3 size = b.size*meshScale;
					size.y = Mathf.Max(size.y, height);
					bounds = new Bounds(transform.position+center+b.center*meshScale, size);
				}
				break;
			default:
				throw new System.Exception("Invalid mesh type");
			}
			return bounds;
		}

		/**
		 * World space contour of the navmesh cut.
		 * Fills the specified buffer with all contours.
		 * The cut may contain several contours which is why the buffer is a list of lists.
		 */
		public void GetContour (List<List<Pathfinding.ClipperLib.IntPoint> > buffer) {
			if (circleResolution < 3) circleResolution = 3;

			Vector3 woffset = tr.position;
			switch (type) {
			case MeshType.Rectangle:
				List<Pathfinding.ClipperLib.IntPoint> buffer0 = Pathfinding.Util.ListPool<Pathfinding.ClipperLib.IntPoint>.Claim();
				if (useRotation) {
					Matrix4x4 m = tr.localToWorldMatrix;
					buffer0.Add(V3ToIntPoint(m.MultiplyPoint3x4(center + new Vector3(-rectangleSize.x, 0, -rectangleSize.y)*0.5f)));
					buffer0.Add(V3ToIntPoint(m.MultiplyPoint3x4(center + new Vector3(rectangleSize.x, 0, -rectangleSize.y)*0.5f)));
					buffer0.Add(V3ToIntPoint(m.MultiplyPoint3x4(center + new Vector3(rectangleSize.x, 0, rectangleSize.y)*0.5f)));
					buffer0.Add(V3ToIntPoint(m.MultiplyPoint3x4(center + new Vector3(-rectangleSize.x, 0, rectangleSize.y)*0.5f)));
				} else {
					woffset += center;
					buffer0.Add(V3ToIntPoint(woffset + new Vector3(-rectangleSize.x, 0, -rectangleSize.y)*0.5f));
					buffer0.Add(V3ToIntPoint(woffset + new Vector3(rectangleSize.x, 0, -rectangleSize.y)*0.5f));
					buffer0.Add(V3ToIntPoint(woffset + new Vector3(rectangleSize.x, 0, rectangleSize.y)*0.5f));
					buffer0.Add(V3ToIntPoint(woffset + new Vector3(-rectangleSize.x, 0, rectangleSize.y)*0.5f));
				}
				buffer.Add(buffer0);
				break;
			case MeshType.Circle:
				buffer0 = Pathfinding.Util.ListPool<Pathfinding.ClipperLib.IntPoint>.Claim(circleResolution);
				if (useRotation) {
					Matrix4x4 m = tr.localToWorldMatrix;
					for (int i = 0; i < circleResolution; i++) {
						buffer0.Add(V3ToIntPoint(m.MultiplyPoint3x4(center + new Vector3(Mathf.Cos((i*2*Mathf.PI)/circleResolution), 0, Mathf.Sin((i*2*Mathf.PI)/circleResolution))*circleRadius)));
					}
				} else {
					woffset += center;
					for (int i = 0; i < circleResolution; i++) {
						buffer0.Add(V3ToIntPoint(woffset + new Vector3(Mathf.Cos((i*2*Mathf.PI)/circleResolution), 0, Mathf.Sin((i*2*Mathf.PI)/circleResolution))*circleRadius));
					}
				}
				buffer.Add(buffer0);
				break;
			case MeshType.CustomMesh:
				if (mesh != lastMesh || contours == null) {
					CalculateMeshContour();
					lastMesh = mesh;
				}

				if (contours != null) {
					woffset += center;

					bool reverse = Vector3.Dot(tr.up, Vector3.up) < 0;

					for (int i = 0; i < contours.Length; i++) {
						Vector3[] contour = contours[i];

						buffer0 = Pathfinding.Util.ListPool<Pathfinding.ClipperLib.IntPoint>.Claim(contour.Length);
						if (useRotation) {
							Matrix4x4 m = tr.localToWorldMatrix;
							for (int x = 0; x < contour.Length; x++) {
								buffer0.Add(V3ToIntPoint(m.MultiplyPoint3x4(center + contour[x]*meshScale)));
							}
						} else {
							for (int x = 0; x < contour.Length; x++) {
								buffer0.Add(V3ToIntPoint(woffset + contour[x]*meshScale));
							}
						}

						if (reverse) buffer0.Reverse();

						buffer.Add(buffer0);
					}
				}
				break;
			}
		}

		/** Converts a Vector3 to an IntPoint.
		 * This is a lossy conversion.
		 */
		public static Pathfinding.ClipperLib.IntPoint V3ToIntPoint (Vector3 p) {
			var ip = (Int3)p;

			return new Pathfinding.ClipperLib.IntPoint(ip.x, ip.z);
		}

		/** Converts an IntPoint to a Vector3.
		 * This is a lossy conversion.
		 */
		public static Vector3 IntPointToV3 (Pathfinding.ClipperLib.IntPoint p) {
			var ip = new Int3((int)p.X, 0, (int)p.Y);

			return (Vector3)ip;
		}

		public static readonly Color GizmoColor = new Color(37.0f/255, 184.0f/255, 239.0f/255);

		public void OnDrawGizmos () {
			if (tr == null) tr = transform;

			var buffer = Pathfinding.Util.ListPool<List<Pathfinding.ClipperLib.IntPoint> >.Claim();
			GetContour(buffer);
			Gizmos.color = GizmoColor;
			var bounds = GetBounds();
			var ymin = bounds.min.y;
			var yoffset = Vector3.up * (bounds.max.y - ymin);

			// Draw all contours
			for (int i = 0; i < buffer.Count; i++) {
				List<Pathfinding.ClipperLib.IntPoint> cont = buffer[i];
				for (int j = 0; j < cont.Count; j++) {
					Vector3 p1 = IntPointToV3(cont[j]);
					p1.y = ymin;
					Vector3 p2 = IntPointToV3(cont[(j+1) % cont.Count]);
					p2.y = ymin;
					Gizmos.DrawLine(p1, p2);
					Gizmos.DrawLine(p1+yoffset, p2+yoffset);
					Gizmos.DrawLine(p1, p1+yoffset);
					Gizmos.DrawLine(p2, p2+yoffset);
				}
			}

			Pathfinding.Util.ListPool<List<Pathfinding.ClipperLib.IntPoint> >.Release(buffer);
		}

		public void OnDrawGizmosSelected () {
			Gizmos.color = Color.Lerp(GizmoColor, new Color(1, 1, 1, 0.2f), 0.9f);

			Bounds b = GetBounds();
			Gizmos.DrawCube(b.center, b.size);
			Gizmos.DrawWireCube(b.center, b.size);
		}
	}
}
