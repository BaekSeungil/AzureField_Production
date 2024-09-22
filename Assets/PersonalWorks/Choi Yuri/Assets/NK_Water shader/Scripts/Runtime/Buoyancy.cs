#if UNITY_EDITOR
#endif
using UnityEngine;
using UnityEngine.Profiling;

#if MATHEMATICS
using static Unity.Mathematics.math;
using Vector4 = Unity.Mathematics.float4;
using Vector3 = Unity.Mathematics.float3;
using Vector2 = Unity.Mathematics.float2;
#endif

namespace NKStudio
{
    public static partial class Buoyancy
    {
        internal static bool ComputeReadbackAvailable;
        
        private static WaveParameters waveParameters = new WaveParameters();
        private static Material lastMaterial;
        
        private static readonly int CustomTimeID = Shader.PropertyToID("_CustomTime");
        private static readonly int TimeParametersID = Shader.PropertyToID("_TimeParameters");
        
        public struct BuoyancySample
        {
            public int hashCode;
            
            public UnityEngine.Vector3[] inputPositions;
            
            public UnityEngine.Vector3[] outputOffset;
            public UnityEngine.Vector3[] outputNormal;

            public void SetSamplePositions(UnityEngine.Vector3[] positions)
            {
                inputPositions = positions;
                outputOffset = new UnityEngine.Vector3[positions.Length];
                outputNormal = new UnityEngine.Vector3[positions.Length];
            }
        }

        private static void GetMaterialParameters(Material mat)
        {
            waveParameters.Update(mat);
        }
        
        private static float customTimeValue = -1f;

        /// <summary>
        /// 임의의 시간 값을 전달하면 모든 종류의 애니메이션에서 이를 파도 애니메이션(따라서 부력 계산도 포함)을 포함한 시간 인덱스로 사용합니다.
        /// 물 셰이더가 이를 사용하지 못하게 하려면 0보다 낮은 값을 전달해야합니다.
        /// </summary>
        /// <param name="value"></param>
        public static void SetCustomTime(float value)
        {
            customTimeValue = value;
            Shader.SetGlobalFloat(CustomTimeID, customTimeValue);
        }
        
        // _TimeParameters.x와 동일한 값을 반환합니다.
        private static float _TimeParameters
        {
            get
            {
                if (customTimeValue > 0) return customTimeValue;
                
#if UNITY_EDITOR
                return Application.isPlaying ? Time.time : Shader.GetGlobalVector(TimeParametersID).x;
#else
                return Time.time;
#endif
            }
        }
        
        private static float Dot2(Vector2 a, Vector2 b)
        {
#if MATHEMATICS
            return dot(a,b);
#else
            return Vector2.Dot(a, b);
#endif
        }
        
        private static float Dot3(Vector3 a, Vector3 b)
        {
#if MATHEMATICS
            return dot(a,b);
#else
            return Vector3.Dot(a, b);
#endif
        }
        
        private static float Dot4(Vector4 a, Vector4 b)
        {
#if MATHEMATICS
            return dot(a,b);
#else
            return Vector4.Dot(a, b);
#endif
        }
        
        private static float Sine(float t)
        {
#if MATHEMATICS
            return sin(t);
#else
            return Mathf.Sin(t);
#endif
        }
        
        private static float Cosine(float t)
        {
#if MATHEMATICS
            return cos(t);
#else
            return Mathf.Cos(t);
#endif
        }

        private static void Vector4Sin(ref Vector4 input, Vector4 a, Vector4 b)
        {
            input.x = Sine(a.x + b.x);
            input.y = Sine(a.y + b.y);
            input.z = Sine(a.z + b.z);
            input.w = Sine(a.w + b.w);
        }
        
        private static void Vector4Cosin(ref Vector4 input, Vector4 a, Vector4 b)
        {
            input.x = Cosine(a.x + b.x);
            input.y = Cosine(a.y + b.y);
            input.z = Cosine(a.z + b.z);
            input.w = Cosine(a.w + b.w);
        }

        private static Vector4 MultiplyVec4(Vector4 a, Vector4 b)
        {
#if MATHEMATICS
            return a * b;
#else
            return Vector4.Scale(a, b);
#endif
        }

        private static Vector4 sine;
        private static Vector4 cosine;
        private static Vector4 dotABCD;
        private static Vector4 AB;
        private static Vector4 CD;
        private static Vector4 direction1;
        private static Vector4 direction2;
        private static Vector4 TIME;
        private static Vector2 planarPosition;
        
        private static Vector4 amp = new Vector4(0.3f, 0.35f, 0.25f, 0.25f);
        private static Vector4 freq = new Vector4(1.3f, 1.35f, 1.25f, 1.25f);
        private static Vector4 speed = new Vector4(1.2f, 1.375f, 1.1f, 1);
        private static Vector4 dir1 = new Vector4(0.3f, 0.85f, 0.85f, 0.25f);
        private static Vector4 dir2 = new Vector4(0.1f, 0.9f, -0.5f, -0.5f);
        private static Vector4 steepness = new Vector4(12f,12f,12f,12f);

        // 웨이브 레이어별 실제 주파수 값
        private static Vector4 frequency;
        // 산출
        private static Vector3 offsets;

        /// <summary>
        /// 원점에서 방향으로 투사된 광선이 (평평한) 수위 높이에 닿는 월드 공간의 위치를 반환합니다.
        /// </summary>
        /// <param name="origin"></param>
        /// <param name="direction"></param>
        /// <param name="waterLevel">Water level height in world-space</param>
        /// <returns></returns>
        public static Vector3 FindWaterLevelIntersection(Vector3 origin, Vector3 direction, float waterLevel)
        {
            float upDot = Dot3(direction, UnityEngine.Vector3.up);
            float angle = (Mathf.Acos(upDot) * 180f) / Mathf.PI;

            float depth = waterLevel - origin.y;
            //Distance from origin to water level along direction
            float hypotenuse = depth / Cosine(Mathf.Deg2Rad * angle);
            
            return origin + (direction * hypotenuse);
        }

        /// <summary>
        /// 수면에 대한 가짜 레이캐스트
        /// </summary>
        /// <param name="waterObject">물의 재질과 레벨(높이)을 구하는 데 사용되는 물 개체 구성 요소</param>
        /// <param name="origin">Ray origin</param>
        /// <param name="direction">Ray direction</param>
        /// <param name="dynamicMaterial">true인 경우 매 함수 호출마다 재질의 웨이브 매개변수를 다시 가져옵니다.</param>
        /// <param name="hit">RaycastHit에 대한 참조, 히트 포인트 및 노멀이 설정됩니다.</param>
        public static void Raycast(WaterObject waterObject, Vector3 origin, Vector3 direction,  bool dynamicMaterial, out RaycastHit hit)
        {
            Raycast(waterObject.Material, waterObject.transform.position.y, origin, direction, dynamicMaterial, out hit);
        }

        private static RaycastHit hit = new RaycastHit();
        /// <summary>
        /// 수면에 대한 가짜 레이캐스트
        /// </summary>
        /// <param name="waterMat">Water Shader를 사용한 머티리얼</param>
        /// <param name="waterLevel">기준 수면의 높이.</param>
        /// <param name="origin">Ray origin</param>
        /// <param name="direction">Ray direction</param>
        /// <param name="dynamicMaterial">true인 경우 매 함수 호출마다 재질의 웨이브 매개변수를 다시 가져옵니다.</param>
        /// <param name="hit">RaycastHit에 대한 참조, 히트 포인트 및 노멀이 설정됩니다.</param>
        public static void Raycast(Material waterMat, float waterLevel, Vector3 origin, Vector3 direction, bool dynamicMaterial, out RaycastHit hit)
        {
            Vector3 samplePos = FindWaterLevelIntersection(origin, direction, waterLevel);

            float waveHeight = SampleWaves(samplePos, waterMat, waterLevel, 1f, dynamicMaterial, out var normal);
            samplePos.y = waveHeight;

            hit = Buoyancy.hit;
            hit.normal = normal;
            hit.point = samplePos;
        }

        /// <summary>
        /// 월드 공간의 위치가 주어지면 파도 높이와 법선을 반환합니다.
        /// </summary>
        /// <param name="position">월드 공간의 샘플 위치</param>
        /// <param name="waterObject">물의 재질과 레벨(높이)을 구하는 데 사용되는 물 개체 구성 요소</param>
        /// <param name="rollStrength">일반 강도에 대한 승수</param>
        /// <param name="dynamicMaterial">true인 경우 매 함수 호출마다 재질의 웨이브 매개변수를 다시 가져옵니다.</param>
        /// <param name="normal">파동에 수직인 상향 법선 벡터 출력</param>
        /// <returns>World Space에서의 파도 높이.</returns>
        public static float SampleWaves(UnityEngine.Vector3 position, WaterObject waterObject, float rollStrength, bool dynamicMaterial, out UnityEngine.Vector3 normal)
        {
            return SampleWaves(position, waterObject.Material, waterObject.transform.position.y, rollStrength, dynamicMaterial, out normal);
        }

        private static void RecalculateParameters()
        {
            direction1 = MultiplyVec4(dir1, waveParameters.direction);
            direction2 = MultiplyVec4(dir2, waveParameters.direction);

            frequency = freq * (1-waveParameters.distance) * 3f;

            AB.x = steepness.x * waveParameters.steepness * direction1.x * amp.x;
            AB.y = steepness.x * waveParameters.steepness * direction1.y * amp.x;
            AB.z = steepness.x * waveParameters.steepness * direction1.z * amp.y;
            AB.w = steepness.x * waveParameters.steepness * direction1.w * amp.y;

            CD.x = steepness.z * waveParameters.steepness * direction2.x * amp.z;
            CD.y = steepness.z * waveParameters.steepness * direction2.y * amp.z;
            CD.z = steepness.w * waveParameters.steepness * direction2.z * amp.w;
            CD.w = steepness.w * waveParameters.steepness * direction2.w * amp.w;
        }
        
        private static void SampleWaves(UnityEngine.Vector3 position, Material waterMat, float waterLevel, float rollStrength, bool dynamicMaterial, out UnityEngine.Vector3 offset, out UnityEngine.Vector3 normal)
        {
            Profiler.BeginSample("Buoyancy sampling");
            
			//호출할 때마다 재질 속성을 다시 가져오고 싶지 않다면 최소한 입력 재질이 변경된 경우 가져오세요(정적 함수이므로).
			//편집 모드에서는 재료가 수정될 가능성이 높으므로 항상 이 작업을 수행하십시오.
			if(!dynamicMaterial && Application.isPlaying)
			{
				// 정확한 계산을 미러링할 수 있도록 재료의 파동 매개변수를 가져옵니다.
				if (lastMaterial == null || lastMaterial.Equals(waterMat) == false)
				{
                    #if SWS_DEV
                    Debug.Log("SampleWaves: water material changed, re-fetching parameters");
                    #endif
                    
					GetMaterialParameters(waterMat);

                    lastMaterial = waterMat;
				}
			}
			else	
			{	
				GetMaterialParameters(waterMat);
            }

            TIME = (_TimeParameters * waveParameters.animationSpeed * waveParameters.speed * speed);
            
            RecalculateParameters();

            offsets = Vector3.zero;
                
            planarPosition.x = position.x;
            planarPosition.y = position.z;

            for (int i = 0; i <= waveParameters.count; i++)
            {
                var t = 1f+((float)i / (float)waveParameters.count);

                frequency *= t;
                
                #if MATHEMATICS
                dotABCD.x = Dot2(direction1.xy, planarPosition) * frequency.x;
                dotABCD.y = Dot2(direction1.zw, planarPosition) * frequency.y;
                dotABCD.z = Dot2(direction2.xy, planarPosition) * frequency.z;
                dotABCD.w = Dot2(direction2.zw, planarPosition) * frequency.w;
                #else
                dotABCD.x = Dot2(new Vector2(direction1.x, direction1.y), planarPosition) * frequency.x;
                dotABCD.y = Dot2(new Vector2(direction1.z, direction1.w), planarPosition) * frequency.y;
                dotABCD.z = Dot2(new Vector2(direction2.x, direction2.y), planarPosition) * frequency.z;
                dotABCD.w = Dot2(new Vector2(direction2.z, direction2.w), planarPosition) * frequency.w;
                #endif

                sine.x = Sine(dotABCD.x + TIME.x);
                sine.y = Sine(dotABCD.y + TIME.y);
                sine.z = Sine(dotABCD.z + TIME.z);
                sine.w = Sine(dotABCD.w + TIME.w);

                cosine.x = Cosine(dotABCD.x + TIME.x);
                cosine.y = Cosine(dotABCD.y + TIME.y);
                cosine.z = Cosine(dotABCD.z + TIME.z);
                cosine.w = Cosine(dotABCD.w + TIME.w);
                
                offsets.x += Dot4(cosine, new Vector4(AB.x, AB.z, CD.x, CD.z));
                offsets.y += Dot4(sine, amp);
                offsets.z += Dot4(cosine, new Vector4(AB.y, AB.w, CD.y, CD.w));
            }
            
			#if MATHEMATICS
            rollStrength *= lerp(0.001f, 0.1f, waveParameters.steepness);
			#else
            rollStrength *= Mathf.Lerp(0.001f, 0.1f, waveParameters.steepness);
			#endif
            
			normal.x = -offsets.x * rollStrength * waveParameters.height;
			normal.y = 2f;
			normal.z = -offsets.z * rollStrength * waveParameters.height;
            
#if MATHEMATICS
            normal = normalize(normal);
#else
            normal = normal.normalized;
#endif

            //Average height
            offsets.y /= waveParameters.count;
            offsets.y = (offsets.y* waveParameters.height) + waterLevel;

            offset = offsets;
            
            Profiler.EndSample();
        }
        
        private static UnityEngine.Vector3 m_offset;
        /// <summary>
        /// 월드 공간의 위치가 주어지면 파도 높이와 법선을 반환합니다.
        /// </summary>
        /// <param name="position">월드 공간의 샘플 위치</param>
        /// <param name="waterMat">Water 셰이더를 사용하는 머티리얼</param>
        /// <param name="waterLevel">기준 수면의 높이.</param>
        /// <param name="rollStrength">일반 강도에 대한 승수</param>
        /// <param name="dynamicMaterial">true인 경우 매 함수 호출마다 재질의 웨이브 매개변수를 다시 가져옵니다.</param>
        /// <param name="normal">파동에 수직인 상향 법선 벡터 출력</param>
        /// <returns>World Space에서의 파도 높이.</returns>
        public static float SampleWaves(UnityEngine.Vector3 position, Material waterMat, float waterLevel, float rollStrength, bool dynamicMaterial, out UnityEngine.Vector3 normal)
        {
            SampleWaves(position, waterMat, waterLevel, rollStrength, dynamicMaterial, out m_offset, out normal);

            return m_offset.y;
        }
        
        /// <summary>
        /// World Space의 위치가 주어지면 파도 높이와 법선을 반환합니다.
        /// </summary>
        /// <param name="sample">샘플링할 입력 위치 배열과 사용 가능한 출력으로 채워질 수면 오프셋/일반 배열을 포함하는 구조체</param>
        /// <param name="waterMat">Water Shader를 사용한 머티리얼</param>
        /// <param name="waterLevel">기준 수면의 높이.</param>
        /// <param name="dynamicMaterial">true인 경우 매 함수 호출마다 재질의 웨이브 매개변수를 다시 가져옵니다.</param>
        /// <returns>World Space에서의 파도 높이.</returns>
        public static void SampleWaves(ref BuoyancySample sample, Material waterMat, float waterLevel, bool dynamicMaterial)
        {
            if (!ComputeReadbackAvailable)
            {
                for (int i = 0; i < sample.inputPositions.Length; i++)
                {
                    SampleWaves(sample.inputPositions[i], waterMat, waterLevel, 1f, dynamicMaterial, out sample.outputOffset[i], out sample.outputNormal[i]);
                }
            }
            else
            {
                SampleDisplacement(ref sample, waterLevel, sample.hashCode);
            }
        }
        
        // 표면 수정자 확장. GPU에서 변위 데이터를 비동기적으로 다시 읽는 시스템을 호출합니다.
        static partial void SampleDisplacement(ref BuoyancySample sample, float waterLevel, int hashCode);

        /// <summary>
        /// 위치가 최대 파도 높이 이하인지 확인합니다. 더 비싼 SampleWaves 기능을 실제로 사용하기 전에 빠른 광범위 위상 검사로 사용할 수 있습니다.
        /// </summary>
        /// <param name="position"></param>
        /// <param name="waterObject"></param>
        /// <returns></returns>
        public static bool CanTouchWater(Vector3 position, WaterObject waterObject)
        {
            if (!waterObject) return false;
            
            return position.y < (waterObject.transform.position.y + WaveParameters.GetMaxWaveHeight(waterObject.Material));
        }
        
        /// <summary>
        /// 위치가 최대 파도 높이 이하인지 확인합니다. 더 비싼 SampleWaves 기능을 실제로 사용하기 전에 빠른 광범위 위상 검사로 사용할 수 있습니다.
        /// </summary>
        public static bool CanTouchWater(Vector3 position, Material waterMaterial, float waterLevel)
        {
            return position.y < (waterLevel + WaveParameters.GetMaxWaveHeight(waterMaterial));
        }
    }
}