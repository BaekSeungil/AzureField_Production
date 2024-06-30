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

            public NativeArray<Vector3> vertices;

            public void Execute(int vi)
            {
                var pos = defaultLineLocalPosition[vi];
                var diff = pos - massCenterLocalPosition;

                var noise = Mathf.PerlinNoise(time, vi);
                var nextPos = pos + diff.normalized * Mathf.Pow(diff.magnitude, 0.12f) * noise * 0.1f;


                vertices[vi] = nextPos;
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
                massCenterLocalPosition = Vector3.zero,
                time = Time.time,
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
        private LineRenderer lineRenderer;
        [SerializeField]
        private float runtime = 2f;
        [SerializeField]
        private Gradient gradient;

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
            lineRenderer.endColor = gradient.Evaluate(normalizedTime);

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
            isScheduled = false;
            OnEarlyUpdate -= JobSchedule;
            gameObject.SetActive(false);
        }

#if UNITY_EDITOR

        [Sirenix.OdinInspector.Button]
        private void RunTest()
        {
            Purge();
        }
#endif

        private void OnDisable()
        {
            OnEarlyUpdate -= JobSchedule;
            //reuse
            positionList.CopyFrom(defaultPositionList);
            lineRenderer.SetPositions(defaultPositionList);
        }

        private void OnDestroy()
        {
            OnEarlyUpdate -= JobSchedule;
            positionList.Dispose();
        }
    }

}