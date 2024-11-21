using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMODUnity;
using Sirenix.OdinInspector;


namespace InteractSystem
{
    public class InterRingBell : MonoBehaviour, IInteract
    {
        [SerializeField] private Animator bellAnimator;

        [SerializeField] private ParticleSystem particle;
        [SerializeField] private StudioEventEmitter sound;

        [SerializeField] private Manager.RingBellSystem BellSystem;

        public int RingNumber = 0;
        public bool Active = false;

        private float coolDownTime =  3.0f;
        private bool Ring = false;

        private void Start()
        {

        }

        //public void UpdateStoneStatus()
        //{
        //    //BellSystem
        //     BellSystem.SetActiveLamp(RingNumber, Active);
        //}

        public void PlaySoundAndsParticles()
        {
            try
            {
                sound.Play();
                particle.Play();
            }
            catch
            {

            }
        }

        public void Interact()
        {
            // 상호작용 시 작동하는 시스템
            PlaySoundAndsParticles();
            // 연결된 종의 활성/비활성
            BellSystem.HittedWaves(RingNumber);
            BellSystem.SetActiveLamp(RingNumber, Active);

            StopAllCoroutines();

            StartCoroutine(HittedCollDown());

        }

        private IEnumerator HittedCollDown()
        {
            Ring = true;
            bellAnimator.SetBool("Ring", Ring);
            yield return new WaitForSeconds(coolDownTime);
            Ring = false;
            bellAnimator.SetBool("Ring", Ring);

        }

        private void OnTriggerEnter(Collider other)
        {

            //if (other.CompareTag("WaterReaction") && !Ring)
            //{
            //    if (!BellSystem.Running) return;

            //    PlaySoundAndsParticles();
            //    // 연결된 종의 활성/비활성
            //    BellSystem.HittedWaves(RingNumber);
            //    BellSystem.SetActiveLamp(RingNumber, Active);
                
            //    StopAllCoroutines();

            //    StartCoroutine(HittedCollDown());

            //    //other.GetComponent<EtherSystem>().HideWave();

            //}
        }

    }


}