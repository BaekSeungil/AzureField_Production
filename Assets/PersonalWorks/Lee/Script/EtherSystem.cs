using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using UnityEngine;

public class EtherSystem : MonoBehaviour
{

    public bool CalledWave = false;
    private Transform SetTransform; // 생성지점
    [SerializeField,LabelText("파도 시작부분")] private GameObject StartCollider;
    [SerializeField,LabelText("파도 머리부분")] private GameObject EndCollider;


    private Vector3 StartinitialScale; //  시작부분 콜라이더 스케일 값
    private Vector3 EndinitialScale; // 머리부분 콜라이더 스케일 값
    [SerializeField]private ParticleSystem Startparticl;
    [SerializeField]private ParticleSystem Idleparticl;
    [SerializeField]private ParticleSystem Endparticl;

    public float moveingSpeed; //스케일 증가 속도

    public bool Moving = true;

    private float currentWaveScaleX = 0f;
    private float currentWaveScaleY = 0f;
    private float currentWaveScaleZ = 0f;

    

    // Start is called before the first frame update
    private void Start()
    {
        StartinitialScale = StartCollider.transform.localScale;
        EndinitialScale = EndCollider.transform.localScale;

        Startparticl.Stop();
        Idleparticl.Stop();
        Endparticl.Stop();

        StartCollider.transform.localScale = Vector3.zero;
        EndCollider.transform.localScale = Vector3.zero;

    }

    // Update is called once per frame
    private void FixedUpdate() 
    {
        //콜라이더가 원래 값으로 천천히 증가
        if(Moving)
        {
            StartCollider.transform.localScale = Vector3.Lerp(StartCollider.transform.localScale,
            StartinitialScale,Time.fixedDeltaTime * moveingSpeed);

            EndCollider.transform.localScale = Vector3.Lerp(StartCollider.transform.localScale,
            EndinitialScale,Time.fixedDeltaTime * moveingSpeed);

            if(Vector3.Distance(StartCollider.transform.localScale, StartinitialScale)< 0.01f &&
            Vector3.Distance(EndCollider.transform.localScale, EndinitialScale) < 0.01f)
            {
                IdelWave();
            }
        }
    }

    
    public void WaveParticleOn()
    {
        if(Moving == true)
        {
            Startparticl.Play();

        }
        else if (Moving == false)
        {
            Endparticl.Play();
            Idleparticl.Stop();
        }
    }

    public void IdelWave()
    {
        Idleparticl.Play();
    }

    private void OnCollisionEnter(Collision other) {
        if (other.gameObject.tag == "Reef")
        {
            Destroy(gameObject);
            
        }
    }
}
