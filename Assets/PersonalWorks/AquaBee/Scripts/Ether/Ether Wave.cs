using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using InteractSystem;
public class EtherWave : MonoBehaviour
{
    [SerializeField] private AnimationCurve animationCurve;
    [SerializeField] private GameObject splashObject;
    [SerializeField] private float speed;
    [SerializeField] private float height;
    [SerializeField] private float Range;
    [Range(0, 1)] private float curCurve;

    private Vector3 startPoint;

    public LayerMask layerMask;

    [Header("몰라")]
    public Vector3 offset;
    

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        // 충돌 체크
        CustomOnCollisionEnter();
        // 움직임
        Movement();
    }
    private Collider[] colliders = new Collider[5];

    public void CustomOnCollisionEnter()
    {
        // Box의 절반 크기(Half-Extent)로 정의
        Vector3 halfSize = new Vector3(size.x / 2, size.y / 2, size.z / 2);

        // 월드 공간에서의 정확한 위치 계산
        Vector3 boxCenter = transform.position + transform.rotation * offset;

        // 충돌 체크
        int hitCount = Physics.OverlapBoxNonAlloc(boxCenter, halfSize, colliders, transform.rotation, layerMask);

        if (hitCount > 0)
        {
            for (int n = 0; n < hitCount; n++)
            {
                // 충돌한 오브젝트의 상호작용 처리
                colliders[n].GetComponent<IInteract>()?.Interact();
            }

            Instantiate(splashObject, new Vector3(transform.position.x,startPoint.y + height, transform.position.z),Quaternion.identity);

            // 충돌 후 오브젝트 비활성화

            gameObject.SetActive(false);
        }
    }


    private void Movement()
    {
        if(GetDistance() < Range)
        {
            curCurve = Mathf.InverseLerp(0f, Range, GetDistance());

            transform.position = Vector3.MoveTowards(transform.position, transform.position + transform.forward, speed * Time.deltaTime);
            transform.position = new Vector3(transform.position.x, startPoint.y + height * animationCurve.Evaluate(curCurve), transform.position.z);
        }
        else
        {
            gameObject.SetActive(false);
        }
    }

    private float GetDistance()
    {
        return Vector3.Distance(startPoint, transform.position);
    }

    private void OnEnable()
    {
        // 출발 
        Initialized();
    }


    private void Initialized()
    {
        curCurve = 0;
        startPoint = transform.position;
    }

    [SerializeField] private float radius = 0;
    [SerializeField] private Vector3 size;

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Vector3 halfSize = new Vector3(size.x / 2, size.y / 2, size.z / 2);
        Vector3 boxCenter = transform.position + transform.rotation * offset;
        Gizmos.matrix = Matrix4x4.TRS(boxCenter, transform.rotation, Vector3.one);
        Gizmos.DrawWireCube(Vector3.zero, halfSize * 2); // 크기 원복

    }
}
