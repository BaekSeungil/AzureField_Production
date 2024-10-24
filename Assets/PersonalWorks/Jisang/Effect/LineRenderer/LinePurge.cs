using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;

namespace JJS
{

    using Sirenix.OdinInspector;
    using System;
    using System.Diagnostics.CodeAnalysis;
    using Unity.Collections;
    using Unity.Jobs;
    using UnityEngine.LowLevel;

    using ReadOnly = Unity.Collections.ReadOnlyAttribute;


    //static, PlayerLoop
    public partial class LinePurge : MonoBehaviour
    {
        private static event Action OnEarlyUpdate;

        [RuntimeInitializeOnLoadMethod]
        private static void InitializePlayerLoop()
        {
            PlayerLoopSystem playerLoop = PlayerLoop.GetCurrentPlayerLoop();

            for (int i = 0; i < playerLoop.subSystemList.Length; i++)
            {
                var subsystem = playerLoop.subSystemList[i];
                if (subsystem.type == typeof(UnityEngine.PlayerLoop.EarlyUpdate))
                {
                    var earlyUpdateList = new List<PlayerLoopSystem>(subsystem.subSystemList);
                    var customEarlyUpdate = new PlayerLoopSystem
                    {
                        type = typeof(LinePurge),
                        updateDelegate = EarlyUpdate
                    };
                    earlyUpdateList.Insert(0, customEarlyUpdate);
                    subsystem.subSystemList = earlyUpdateList.ToArray();
                    playerLoop.subSystemList[i] = subsystem;
                    break;
                }
            }

            PlayerLoop.SetPlayerLoop(playerLoop);
        }

        private static void EarlyUpdate()
        {
            OnEarlyUpdate?.Invoke();
        }
    }


    //Job
    public partial class LinePurge : MonoBehaviour
    {
        private JobHandle handle;
        private UpdateLinePositionJob updateJob;

        private struct UpdateLinePositionJob : IJobParallelFor
        {
            [ReadOnly] public NativeArray<Vector3> defaultLineLocalPosition;
            [ReadOnly] public Vector3 massCenterLocalPosition;
            [ReadOnly] public float time;
            [ReadOnly] public float normalizedRuntime;

            public NativeArray<Vector3> vertices;
            private const float NoiseFactor = 12f;
            private const float RunSpeed = 0.5f;

            public void Execute(int vi)
            {
                var pos = defaultLineLocalPosition[vi];
                var targetpos = defaultLineLocalPosition[Mathf.Max(0, vi - 1)];
                var runtimeSpeedFactor = -((1 - (2 * normalizedRuntime)) * (1 - (2 * normalizedRuntime))) + 1f;

                if (vi == 0) //head
                {
                    var rand = new Random();
                    var targetDirection = pos - defaultLineLocalPosition[vi + 1];

                    var noiseVector = new Vector3((float)rand.NextDouble() - 0.5f, (float)rand.NextDouble() - 0.5f, (float)rand.NextDouble() - 0.5f);

                    var rotation = Quaternion.Euler(noiseVector * 270 * runtimeSpeedFactor);

                    var forward = Vector3.Lerp(rotation * targetDirection.normalized, (pos - massCenterLocalPosition).normalized, 0.2f);

                    var nextPos = pos + forward * 0.5f * RunSpeed * runtimeSpeedFactor * 1.2f;

                    vertices[vi] = nextPos;
                }
                else //body
                {
                    var targetpos2 = defaultLineLocalPosition[Mathf.Max(0, vi - 2)];

                    var cubicInterpolation = Vector3.Lerp(Vector3.Lerp(pos, targetpos, 0.5f), Vector3.Lerp(targetpos, targetpos2, 0.5f), 0.5f);

                    var diff = cubicInterpolation - pos;

                    var diffVector = diff.normalized * /*normalizedRuntime **/ 0.5f;

                    var nextPos = pos + (diffVector) * RunSpeed * runtimeSpeedFactor;
                    vertices[vi] = nextPos;
                }
            }
        }

        public void JobSchedule()
        {
            handle.Complete();

            //get data
            lineRenderer.GetPositions(positionList);

            //makeJob;
            updateJob = new UpdateLinePositionJob
            {
                defaultLineLocalPosition = positionList,
                massCenterLocalPosition = transform.InverseTransformPoint(Root.transform.position),
                time = Time.time,
                normalizedRuntime = curve.Evaluate(t / runtime),
                vertices = new NativeArray<Vector3>(positionList.ToArray(), Allocator.Persistent)
            };

            //schedule
            handle = updateJob.Schedule(lineRenderer.positionCount, 64);
            JobHandle.ScheduleBatchedJobs();
        }

        public void JobComplete()
        {
            //isComplete is not working
            handle.Complete();

            //update data
            lineRenderer.SetPositions(updateJob.vertices);
            updateJob.vertices.Dispose();
        }
    }

    public partial class LinePurge : MonoBehaviour
    {
        [SerializeField]
        private Transform Root;
        [SerializeField]
        private LineRenderer lineRenderer;
        [SerializeField]
        private float runtime = 2f;
        [SerializeField]
        private Gradient gradient;

        [SerializeField]
        private AnimationCurve curve;


#if UNITY_EDITOR

        [Sirenix.OdinInspector.Button]
        private void RunTest() 
        {
            foreach (var actor in LinkedActor)
            {
                actor.gameObject.SetActive(true);
                actor.Purge();
            }
        }
#endif

        [Header("Linked")]
        [SerializeField]
        private List<LinePurge> LinkedActor = new List<LinePurge>();

        private Vector3[] defaultPositionList;
        private NativeArray<Vector3> positionList;

        private bool isScheduled;
        private float t = 0;

        private void Awake()
        {
            defaultPositionList = new Vector3[lineRenderer.positionCount];
            lineRenderer.GetPositions(defaultPositionList);

            positionList = new NativeArray<Vector3>(defaultPositionList, Allocator.Persistent);
            isScheduled = false;
        }

        private void Purge()
        {
            if (lineRenderer == null)
                return;

            isScheduled = true;
            t = 0;
            OnEarlyUpdate += UpdatePurge;
        }

        private void UpdatePurge()
        {
            if (runtime < t)
            {
                CompletePurge();
                return;
            }

            //position job
            JobSchedule();

            t += Time.deltaTime;
            var normalizedTime = t / runtime;

            //color
            lineRenderer.startColor = gradient.Evaluate(normalizedTime);

            var endColor = gradient.Evaluate(normalizedTime);
            endColor.a *= 0.7f;
            lineRenderer.endColor = endColor;

            //width
            lineRenderer.widthMultiplier = Mathf.Lerp(0.1f, 0f, normalizedTime);
        }

        private void LateUpdate()
        {
            if (!isScheduled)
                return;

            JobComplete();
        }

        private void CompletePurge()
        {
            t = 0;
            isScheduled = false;
            OnEarlyUpdate -= UpdatePurge;
            gameObject.SetActive(false);

            lineRenderer.startColor = gradient.Evaluate(0);
            lineRenderer.endColor = gradient.Evaluate(0);
            lineRenderer.widthMultiplier = Mathf.Lerp(0.1f, 0f, 0);

            positionList.CopyFrom(defaultPositionList);
            lineRenderer.SetPositions(defaultPositionList);
        }

        private void OnDisable()
        {
            CompletePurge();
        }

        private void OnDestroy()
        {
            OnEarlyUpdate -= UpdatePurge;
            positionList.Dispose();
        }
    }

}