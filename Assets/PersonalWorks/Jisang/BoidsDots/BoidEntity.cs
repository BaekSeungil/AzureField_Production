using System;
using System.Collections.Generic;
using System.Linq;
using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Jobs;
using Utils;

namespace Boids
{
    public partial class BoidEntity : MonoBehaviour
    {
        [Serializable]
        public struct BoidsConfig
        {
            public int BoidObjectNum;

            [Space(20)]
            public float CohesionNeighborhoodRadius;
            public float AlignmentNeighborhoodRadius;
            public float SeparateNeighborhoodRadius;

            [Space(20)]
            public float MaxSpeed;
            public float MaxSteerForce;

            [Space(20)]
            public float CohesionWeight;
            public float AlignmentWeight;
            public float SeparateWeight;

            [Space(20)]
            public float AvoidWallWeight;
            public float AvoidBoundWeight;
            public float FavorBoundWeight;
        }

        public struct BoidData
        {
            public Vector3 velocity;
            public Vector3 position;
        };


        [BurstCompile]
        public struct BoidsJob : IJobParallelFor
        {
            [ReadOnly] public BoidsConfig config;
            [ReadOnly] public NativeArray<BoidData> boidsArray;
            [ReadOnly] public NativeArray<Vector3> forceArray;

            [ReadOnly] public Vector3 _WallCenter;
            [ReadOnly] public Vector3 _WallSize;

            [ReadOnly] public NativeArray<Bounds> avoidBounds;
            [ReadOnly] public NativeArray<Bounds> favorBounds;

            [ReadOnly] public float deltaTime;

            public NativeArray<BoidData> boidsArrayOutput;
            public NativeArray<Vector3> forceArrayOutput;


            public void Execute(int index)
            {
                ComputeForce(index);
                ComputeIntegrate(index);
            }

            void ComputeForce(int index)
            {
                Vector3 pos = boidsArray[index].position; //Owner Position
                Vector3 velocity = boidsArray[index].velocity; //Owner Velocity

                Vector3 force = Vector3.zero;

                Vector3 sepPosSum = Vector3.zero;
                int sepCount = 0;

                Vector3 aliVelSum = Vector3.zero;
                int aliCount = 0;

                Vector3 cohPosSum = Vector3.zero;
                int cohCount = 0;

                for (int i = 0; i < boidsArray.Length; ++i)
                {
                    Vector3 neighborPosition = boidsArray[i].position;
                    Vector3 neighborVelocity = boidsArray[i].velocity;

                    Vector3 diff = pos - neighborPosition;
                    float dist = diff.magnitude;

                    //Separation
                    if (dist > 0.0 && dist <= config.SeparateNeighborhoodRadius)
                    {
                        Vector3 repulse = (pos - neighborPosition).normalized;
                        repulse /= dist;
                        sepPosSum += repulse;
                        sepCount++;
                    }

                    //Alignment
                    if (dist > 0.0 && dist <= config.AlignmentNeighborhoodRadius)
                    {
                        aliVelSum += neighborVelocity;
                        aliCount++;
                    }

                    //Cohesion
                    if (dist > 0.0 && dist <= config.CohesionNeighborhoodRadius)
                    {
                        cohPosSum += neighborPosition;
                        cohCount++;
                    }
                }

                Vector3 sepSteer = Vector3.zero;
                if (sepCount > 0)
                {
                    sepSteer = sepPosSum / sepCount;
                    sepSteer = sepSteer.normalized * config.MaxSpeed;
                    sepSteer -= velocity;
                    sepSteer = Limit(sepSteer, config.MaxSteerForce);
                }

                Vector3 aliSteer = Vector3.zero;
                if (aliCount > 0)
                {
                    aliSteer = aliVelSum / aliCount;
                    aliSteer = aliSteer.normalized * config.MaxSpeed;
                    aliSteer -= velocity;
                    aliSteer = Limit(aliSteer, config.MaxSteerForce);
                }

                Vector3 cohSteer = Vector3.zero;
                if (cohCount > 0)
                {
                    cohPosSum /= cohCount;
                    cohSteer = cohPosSum - pos;
                    cohSteer = cohSteer.normalized * config.MaxSpeed;
                    cohSteer -= velocity;
                    cohSteer = Limit(cohSteer, config.MaxSteerForce);
                }

                force += aliSteer * config.AlignmentWeight;
                force += cohSteer * config.CohesionWeight;
                force += sepSteer * config.SeparateWeight;

                forceArrayOutput[index] = force;
            }


            void ComputeIntegrate(int P_ID)
            {
                BoidData b = boidsArray[P_ID];
                Vector3 force = forceArray[P_ID];

                force += (AvoidWall(b.position) * config.AvoidWallWeight);
                for (int i = 0; i < avoidBounds.Length; ++i)
                {
                    force += AvoidBounds(b.position, avoidBounds[i]) * config.AvoidBoundWeight;
                }

                for (int i = 0; i < favorBounds.Length; ++i)
                {
                    force += FavorBounds(b.position, favorBounds[i]) * config.FavorBoundWeight;
                }

                b.velocity += force * deltaTime;
                b.velocity = Limit(b.velocity, config.MaxSpeed);
                b.position += b.velocity * deltaTime;

                boidsArrayOutput[P_ID] = b;
            }

            private Vector3 AvoidWall(Vector3 position)
            {
                Vector3 wc = _WallCenter;
                Vector3 ws = _WallSize;
                Vector3 acc = Vector3.zero;

                acc.x = (position.x < wc.x - ws.x * 0.5f) ? acc.x + 1.0f : acc.x;
                acc.x = (position.x > wc.x + ws.x * 0.5f) ? acc.x - 1.0f : acc.x;

                acc.y = (position.y < wc.y - ws.y * 0.5f) ? acc.y + 1.0f : acc.y;
                acc.y = (position.y > wc.y + ws.y * 0.5f) ? acc.y - 1.0f : acc.y;

                acc.z = (position.z < wc.z - ws.z * 0.5f) ? acc.z + 1.0f : acc.z;
                acc.z = (position.z > wc.z + ws.z * 0.5f) ? acc.z - 1.0f : acc.z;

                return acc;
            }

            private Vector3 AvoidBounds(in Vector3 position, in Bounds bound)
            {
                if (!bound.Contains(position))
                    return Vector3.zero;

                var dir = (position - bound.center).normalized;
                var closestPoint = bound.ClosestPoint(bound.center + dir * 100f);

                return (closestPoint - position);
            }

            private Vector3 FavorBounds(in Vector3 position, in Bounds bound)
            {
                if (bound.Contains(position))
                    return Vector3.zero;

                var disp = bound.ClosestPoint(position) - position;

                return disp;
            }
        }

        [BurstCompile]
        struct BoidsMoveTransform : IJobParallelForTransform
        {
            public NativeArray<BoidData> boidsArray;
            public NativeArray<Vector3> force;
            public float limit;
            public float dt;

            void IJobParallelForTransform.Execute(int id, TransformAccess t)
            {
                var velocity = Limit(boidsArray[id].velocity + force[id] * dt, limit);

                t.position += velocity * dt;
                t.rotation = Quaternion.LookRotation(velocity.normalized);
                force[id] = Vector3.zero;

                var newBoidData = new BoidData()
                {
                    position = t.position,
                    velocity = velocity
                };

                boidsArray[id] = newBoidData;
            }
        }

        private static Vector3 Limit(in Vector3 vector, float maxLength)
        {
            if (vector.sqrMagnitude < maxLength * maxLength)
                return vector;

            return vector.normalized * maxLength;
        }

    }

    public partial class BoidEntity : MonoBehaviour
    {
        [SerializeField]
        private BoidsConfig config;

        [SerializeField]
        private BoxCollider WallCollider;

        [SerializeField]
        private List<Collider> AvoidColliders;
        [SerializeField]
        private List<Collider> FavorColliders;

        [SerializeField]
        private Transform Root;

        [SerializeField]
        private GameObject BoidOrigin;


        private JobHandle handle;
        private JobHandle moveHandle;
        private BoidsJob boidsJob;
        private BoidsMoveTransform moveJob;

        private TransformAccessArray transformAccessor;

        public NativeArray<BoidData> boidsArray;
        public NativeArray<Vector3> forceArray;

        public NativeArray<BoidData> boidsArrayOutput;
        public NativeArray<Vector3> forceArrayOutput;

        private NativeArray<Bounds> avoidBounds;
        private NativeArray<Bounds> favorBounds;

        private void Awake()
        {
            PlayerLoopManager.OnEarlyUpdate += EarlyUpdate;
            PlayerLoopManager.OnPostLateUpdate += PostLateUpdate;

            Initialize();
        }

        private void Initialize()
        {
            boidsArray = new NativeArray<BoidData>(config.BoidObjectNum, Allocator.Persistent);
            forceArray = new NativeArray<Vector3>(config.BoidObjectNum, Allocator.Persistent);
            boidsArrayOutput = new NativeArray<BoidData>(config.BoidObjectNum, Allocator.Persistent);
            forceArrayOutput = new NativeArray<Vector3>(config.BoidObjectNum, Allocator.Persistent);
            avoidBounds = new NativeArray<Bounds>(AvoidColliders.Select(col => col.bounds).ToArray(), Allocator.Persistent);
            favorBounds = new NativeArray<Bounds>(FavorColliders.Select(col => col.bounds).ToArray(), Allocator.Persistent);

            var list = new List<Transform>();
            for (int i = 0; i < config.BoidObjectNum; ++i)
            {
                //기본포지션
                var boidsData = new BoidData()
                {
                    velocity = UnityEngine.Random.insideUnitSphere * 0.1f,
                    position = RandomPointInBounds(WallCollider.bounds)
                };

                var instance = Instantiate(BoidOrigin);
                instance.transform.SetParent(Root);
                instance.transform.localPosition = boidsData.position;

                boidsArray[i] = boidsData;
                forceArray[i] = Vector3.zero;

                list.Add(instance.transform);
            }

            transformAccessor = new TransformAccessArray(list.ToArray());

            Vector3 RandomPointInBounds(Bounds bounds)
            {
                return new Vector3(
                    UnityEngine.Random.Range(bounds.min.x, bounds.max.x),
                    UnityEngine.Random.Range(bounds.min.y, bounds.max.y),
                    UnityEngine.Random.Range(bounds.min.z, bounds.max.z)
                );
            }
        }


        private void EarlyUpdate()
        {
            handle.Complete();
            moveHandle.Complete();

            //boids Handle
            boidsJob = new BoidsJob
            {
                config = config,

                boidsArray = this.boidsArray,
                forceArray = this.forceArray,
                avoidBounds = this.avoidBounds,
                favorBounds = this.favorBounds,

                boidsArrayOutput = this.boidsArrayOutput,
                forceArrayOutput = this.forceArrayOutput,

                _WallCenter = WallCollider.bounds.center,
                _WallSize = WallCollider.bounds.size,

                deltaTime = Time.deltaTime,
            };

            int count = config.BoidObjectNum;
            handle = boidsJob.Schedule(count, 16);

            //MoveHandle
            moveJob = new BoidsMoveTransform()
            {
                dt = Time.deltaTime,
                boidsArray = boidsArray,
                force = forceArray,
                limit = config.MaxSpeed
            };

            moveHandle = moveJob.Schedule(transformAccessor, handle);
            JobHandle.ScheduleBatchedJobs();
        }

        private void PostLateUpdate()
        {
            handle.Complete();
            moveHandle.Complete();

            boidsArrayOutput.CopyTo(boidsArray);
            forceArrayOutput.CopyTo(forceArray);

            avoidBounds.CopyFrom(AvoidColliders.Select(col => col.bounds).ToArray());
            favorBounds.CopyFrom(FavorColliders.Select(col => col.bounds).ToArray());
        }

        private void OnDestroy()
        {
            PlayerLoopManager.OnEarlyUpdate -= EarlyUpdate;
            PlayerLoopManager.OnPostLateUpdate -= PostLateUpdate;

            avoidBounds.Dispose();
            favorBounds.Dispose();

            boidsArray.Dispose();
            forceArray.Dispose();
            boidsArrayOutput.Dispose();
            forceArrayOutput.Dispose();

            transformAccessor.Dispose();
        }
    }
}