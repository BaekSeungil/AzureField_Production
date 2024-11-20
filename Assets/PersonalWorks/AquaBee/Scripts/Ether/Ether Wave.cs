using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using InteractSystem;
public class EtherWave : MonoBehaviour
{
    [SerializeField] private AnimationCurve animationCurve;
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
        int i = Physics.OverlapBoxNonAlloc(transform.position + offset, size, colliders, Quaternion.identity, layerMask);
        if(i > 0)
        {
            for(int n = 0; n < i; n++)
            {
                //InterRingBell inter = 
                colliders[n].GetComponent<IInteract>().Interact();
                //inter.Interact();
            }
            gameObject.SetActive(false);
            // 이제 작동 했으니 여긴 없어져야함.
        }
        else
        {
            //i = Physics.OverlapBoxNonAlloc(transform.position + offset, size, colliders, Quaternion.identity, ~(1 << 3 << 4 << 6));
            //if(i > 0)
            //{
            //    // 삭제!
            //    gameObject.SetActive(false);
            //}
        }
    }

    private void Movement()
    {
        if(GetDistance() < Range)
        {
            curCurve = Mathf.Clamp(GetDistance() / Range ,0 ,1);
            transform.position = Vector3.MoveTowards(transform.position, transform.position + transform.forward, speed * Time.deltaTime);
            transform.position = new Vector3(transform.position.x, startPoint.y + height * animationCurve.Evaluate(curCurve), transform.position.z);
        }
        else
        {
            // 거리를 벗어났을 때 사용
            //Debug.Log("AA");
        }
    }

    private float GetDistance()
    {
        //Debug.Log(Vector3.Distance(startPoint, transform.position));
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
        //transform.position = new Vector3(transform.position.x, transform.position.y - height , transform.position.z);
        startPoint = transform.position;
    }

    [SerializeField] private float radius = 0;
    [SerializeField] private Vector3 size ;

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.blue;

        Gizmos.DrawWireCube(transform.position + offset, size);


    }
}
