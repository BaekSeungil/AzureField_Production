using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace JJS.Utils
{
    [RequireComponent(typeof(Collider))]
    public class CollisionEventRiser : MonoBehaviour
    {
        [SerializeField]
        private Collider detector;
        public Collider Detector
        {
            get
            {
                if (detector == null)
                    detector = GetComponent<Collider>();

                return detector;
            }
        }

        public event Action<Collider> OnTriggerEnterEvent;
        public event Action<Collider> OnTriggerStayEvent;
        public event Action<Collider> OnTriggerExitEvent;


        private void OnTriggerEnter(Collider other)
        {
            OnTriggerEnterEvent?.Invoke(other);
        }

        private void OnTriggerExit(Collider other)
        {
            OnTriggerExitEvent?.Invoke(other);
        }

        protected void CallOnTriggerStay(Collider other)
        {
            OnTriggerStayEvent?.Invoke(other);
        }

    }
}