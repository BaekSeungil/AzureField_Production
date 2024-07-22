using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace JJS
{
    public class TestAutoMove : MonoBehaviour
    {
        [SerializeField]
        private Vector3 Axis;

        [SerializeField]
        private AnimationCurve curve;

        [SerializeField]
        private Transform Start;

        [SerializeField]
        private Transform End;
        [SerializeField]
        private float speed;

        [SerializeField]
        private bool useReversive = false;

        float last = 0;
        void Update()
        {
            var t = Mathf.PingPong(Time.time * speed, 1);
            var dt = last - t;

            if (dt < 0 || !useReversive)
                transform.position = Vector3.Lerp(Start.position, End.position, curve.Evaluate(t));
            else
                transform.position = Vector3.Lerp(End.position, Start.position, curve.Evaluate(1 - t));

            last = t;
        }
    }
}