using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEngine;

namespace JJS.Utils
{
    public static class StringExtensions
    {
        public static string[] ParseExact(this string data, string format)
        {
            return ParseExact(data, format, false);
        }

        public static string[] ParseExact(this string data, string format, bool ignoreCase)
        {
            string[] values;

            if (TryParseExact(data, format, out values, ignoreCase))
                return values;
            else
                throw new ArgumentException("Format not compatible with value.");
        }

        public static bool TryExtract(this string data, string format, out string[] values)
        {
            return TryParseExact(data, format, out values, false);
        }

        public static bool TryParseExact(this string data, string format, out string[] values, bool ignoreCase)
        {
            int tokenCount = 0;
            format = Regex.Escape(format).Replace("\\{", "{");

            for (tokenCount = 0; ; tokenCount++)
            {
                string token = string.Format("{{{0}}}", tokenCount);
                if (!format.Contains(token)) break;
                format = format.Replace(token, string.Format("(?'group{0}'.*)", tokenCount));
            }

            RegexOptions options = ignoreCase ? RegexOptions.IgnoreCase : RegexOptions.None;

            Match match = new Regex(format, options).Match(data);

            if (tokenCount != (match.Groups.Count - 1))
            {
                values = new string[] { };
                return false;
            }
            else
            {
                values = new string[tokenCount];
                for (int index = 0; index < tokenCount; index++)
                    values[index] = match.Groups[string.Format("group{0}", index)].Value;
                return true;
            }
        }
    }

    public static class CollectionExtension
    {
        public static T GetRandom<T>(this List<T> list)
        {
            return list[UnityEngine.Random.Range(0, list.Count)];
        }

        public static T GetRandom<T>(this List<T> list, Predicate<T> pred)
        {
            var matchedList = list.Where(new Func<T, bool>(pred)).ToList();
            return matchedList[UnityEngine.Random.Range(0, matchedList.Count)];
        }

        public static T Next<T>(this List<T> list, T value)
        {
            var idx = list.IndexOf(value);
            return list[(idx + 1) % list.Count];
        }


        //make tryget static extension
        public static bool TryGet<T>(this List<T> list, int index, out T value)
        {
            if (index < 0 || index >= list.Count)
            {
                value = default(T);
                return false;
            }
            value = list[index];
            return true;
        }

        public static void MoveTo<T>(this List<T> list, ref List<T> to)
        {
            to.AddRange(list);
            list.Clear();
        }

        //public static bool IsEmpty<T>(this List<T> list)
        //{
        //    return list.Count <= 0;
        //}

        public static bool IsEmpty<TKey, TValue>(this Dictionary<TKey, TValue> dictionary)
        {
            return dictionary.Count <= 0;
        }

        public static void AddWhenNotContains<T>(this List<T> list, in T item)
        {
            if (list.Contains(item))
                return;

            list.Add(item);
        }

        public static bool IsEmpty(this ICollection collection)
        {
            return collection.Count <= 0;
        }

        public static TValue GetValueOrNull<TKey, TValue>(this Dictionary<TKey, TValue> dictionary, TKey key) where TValue : class
        {
            if (dictionary.ContainsKey(key))
            {
                return dictionary[key];
            }
            else
            {
                return null;
            }
        }

        public static IEnumerable<T> AsEnumerable<T>(this IEnumerator enumerator)
        {
            while (enumerator.MoveNext())
            {
                yield return (T)enumerator.Current;
            }
        }
    }

    public static class GameObjectExtension
    {
        public static GameObject SetAsRoot(this GameObject obj)
        {
            SetAsRoot(obj.transform);
            return obj;
        }

        public static Transform SetAsRoot(this Transform obj)
        {
            if (obj.parent != null)
                obj.SetParent(null, true);

            return obj;
        }
    }

    public static class PhysicsExtension
    {
        public static bool ComputePenetration(this Collider staticCollider, Collider dynamicCollider, out Vector3 dir, out float dis)
        {
            return Physics.ComputePenetration(
                dynamicCollider, dynamicCollider.transform.position, dynamicCollider.transform.rotation,
                staticCollider, staticCollider.transform.position, staticCollider.transform.rotation,
                out dir, out dis);
        }

        public static bool ComputePenetration(this Collider staticCollider, Collider dynamicCollider, Vector3 position, out Vector3 dir, out float dis)
        {
            return Physics.ComputePenetration(
                dynamicCollider, position, dynamicCollider.transform.rotation,
                staticCollider, staticCollider.transform.position, staticCollider.transform.rotation,
                out dir, out dis);
        }
    }



    public static class VectorExtension
    {
        public static float Remap(this float value, in float start1, in float stop1, in float start2, in float stop2) => start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));

        public static float Remap(this float value, in (float, float) input, in (float, float) output) => output.Item1 + (output.Item2 - output.Item1) * ((value - input.Item1) / (input.Item2 - input.Item1));

        public static Vector2 SetX(this in Vector2 vector, float x) => new Vector2(x, vector.y);
        public static Vector2 SetY(this in Vector2 vector, float y) => new Vector2(vector.x, y);

        public static Vector2 ToInvertY(this in Vector2 vector) => new Vector2(vector.x, -vector.y);
        public static Vector2 ToXZ(this in Vector3 vector) => new Vector2(vector.x, vector.z);
        public static Vector2 ToVector2(this in Vector3 vector) => vector;
        public static Vector2 ToVector2(this in (float x, float y) tuple) => new Vector2(tuple.x, tuple.y);

        public static (float, float) ToTuple(this in Vector2 vector) => (vector.x, vector.y);
        public static (float, float, float) ToTuple(this in Vector3 vector) => (vector.x, vector.y, vector.z);


        public static Vector3 SetX(this in Vector3 vector, float x) => new Vector3(x, vector.y, vector.z);
        public static Vector3 SetY(this in Vector3 vector, float y) => new Vector3(vector.x, y, vector.z);
        public static Vector3 SetZ(this in Vector3 vector, float z) => new Vector3(vector.x, vector.y, z);

        public static Vector3 ToVector3(this in Vector2 vector) => vector;
        public static Vector3 ToVector3(this in (float x, float y, float z) tuple) => new Vector3(tuple.x, tuple.y, tuple.z);
        public static Vector3 ToVector3(this in Vector2 vector, float z) => new Vector3(vector.x, vector.y, z);
        public static Vector3 ToVector3FromXZ(this in Vector2 xzVector) => new Vector3(xzVector.x, 0, xzVector.y);
        public static Vector3 ToVector3FromXZ(this in Vector2 xzVector, float y) => new Vector3(xzVector.x, y, xzVector.y);
        public static Vector3 AdaptY(this in Vector3 xzVector, in float y) => new Vector3(xzVector.x, y, xzVector.z);
        public static Vector3 MultiplyEachChannel(this in Vector3 lhs, in Vector3 rhs) => new Vector3(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z);

        public static Vector3 Round(this in Vector3 vector, in float scale) => new Vector3(
            Mathf.Round(vector.x / scale) * scale,
            Mathf.Round(vector.y / scale) * scale,
            Mathf.Round(vector.z / scale) * scale);

        public static Vector2 Decrease(this in Vector2 vector, in float amount) => new Vector2(
            Mathf.Sign(vector.x) * Mathf.Max(Mathf.Abs(vector.x) - amount, 0),
            Mathf.Sign(vector.y) * Mathf.Max(Mathf.Abs(vector.y) - amount, 0));
        public static Vector3 Decrease(this in Vector3 vector, in float amount) => new Vector3(
            Mathf.Sign(vector.x) * Mathf.Max(Mathf.Abs(vector.x) - amount, 0),
            Mathf.Sign(vector.y) * Mathf.Max(Mathf.Abs(vector.y) - amount, 0),
            Mathf.Sign(vector.z) * Mathf.Max(Mathf.Abs(vector.z) - amount, 0));

        //projection2D
        public static Vector2 ProjectionToXAxis(this Vector2 vector, Vector2 start, float xAxisValue)
        {
            return new Vector2(
                xAxisValue,
                (vector.y - start.y) * (xAxisValue - start.x) / (vector.x - start.x) + start.y);
        }
        public static Vector2 ProjectionToYAxis(this Vector2 vector, Vector2 start, float yAxisValue)
        {
            return new Vector2(
                (vector.x - start.x) * (yAxisValue - start.y) / (vector.y - start.y) + start.x,
                yAxisValue);
        }

        //projection3D
        public static Vector3 ProjectionToZAxis(this Vector3 vector, Vector3 start, float zAxisValue)
        {
            return new Vector3(
                (vector.x - start.x) * (zAxisValue - start.z) / (vector.z - start.z) + start.x,
                (vector.y - start.y) * (zAxisValue - start.z) / (vector.z - start.z) + start.y,
                zAxisValue);
        }
        public static Vector3 ProjectionToXAxis(this Vector3 vector, Vector3 start, float xAxisValue)
        {
            return new Vector3(
                xAxisValue,
                (vector.y - start.y) * (xAxisValue - start.x) / (vector.x - start.x) + start.y,
                (vector.z - start.z) * (xAxisValue - start.x) / (vector.x - start.x) + start.z);
        }
        public static Vector3 ProjectionToYAxis(this Vector3 vector, Vector3 start, float yAxisValue)
        {
            return new Vector3(
                (vector.x - start.x) * (yAxisValue - start.y) / (vector.y - start.y) + start.x,
                yAxisValue,
                (vector.z - start.z) * (yAxisValue - start.y) / (vector.y - start.y) + start.z);
        }

        public static Vector2 ToAbs(this Vector2 vector)
        {
            return new Vector2(Mathf.Abs(vector.x), Mathf.Abs(vector.y));
        }

        public static Vector3 ToAbs(this Vector3 vector)
        {
            return new Vector3(Mathf.Abs(vector.x), Mathf.Abs(vector.y), Mathf.Abs(vector.z));
        }

        public static Vector3 IntersectionPoint(Vector3 origin, Vector3 target, Vector3 center, float radius)
        {
            var centerDir = center - origin;
            var forwardLength = Vector3.Project(centerDir, (target - origin).normalized);
            var orthogonal = Vector3.Distance(origin + forwardLength, center);

            if (orthogonal > radius)
                orthogonal = radius;

            var innerForward = Mathf.Sqrt((radius * radius) - (orthogonal * orthogonal));
            var dist = forwardLength.magnitude - innerForward;

            return origin + (target - origin).normalized * dist;
        }

        public static Vector3 GetRandomDirectionXZ()
        {
            return new Vector3(UnityEngine.Random.Range(-1.0f, 1.0f), 0, UnityEngine.Random.Range(-1.0f, 1.0f)).normalized;
        }

        public static Quaternion SlerpReverseUnClamped(Quaternion q1, Quaternion q2, float t)
        {
            float RawCosom =
                q1.x * q2.x +
                q1.y * q2.y +
                q1.z * q2.z +
                q1.w * q2.w;

            // 내적 판단을 거꾸로 한다.
            float Cosom = RawCosom >= 0 ? -RawCosom : RawCosom;
            float Scale0, Scale1;

            if (Cosom < 0.9999f)
            {
                Scale0 = 1.0f - t;
                Scale1 = t;
            }
            else
            {
                float Omega = Mathf.Acos(Cosom);
                float InvSin = 1.0f / Mathf.Sin(Omega);

                Scale0 = Mathf.Sin((1.0f - t) * Omega) * InvSin;
                Scale1 = Mathf.Sin(t * Omega) * InvSin;
            }

            // 적용도 거꾸로 한다.
            Scale1 = RawCosom >= 0 ? -Scale1 : Scale1;

            Quaternion Result;

            Result.x = Scale0 * q1.x + Scale1 * q2.x;
            Result.y = Scale0 * q1.y + Scale1 * q2.y;
            Result.z = Scale0 * q1.z + Scale1 * q2.z;
            Result.w = Scale0 * q1.w + Scale1 * q2.w;

            return Result;
        }
    }
}