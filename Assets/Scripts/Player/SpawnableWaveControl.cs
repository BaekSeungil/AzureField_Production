using System.Linq;
using UnityEngine;

public class SpawnableWaveControl : MonoBehaviour
{
    [SerializeField] private float coolDownTime = 1f;
    [SerializeField] private GameObject wavePrefab;
    [SerializeField] private Transform waveSpawnPoint;
    [SerializeField] private GameObject waveHolo_Positive;
    [SerializeField] private GameObject waveHolo_Negative;
    //[SerializeField] private float SearchRedius;
    [SerializeField] private float SearchHeightOffset = 5f;
    [SerializeField] private LayerMask SpawnMask;
    //[SerializeField] private GameObject waveParticlePrefab;
    private GameObject activeWavePrefab;
    
    private MainPlayerInputActions inputActions;
    private Collider[] colliders;

    private bool isPressed;
    private Vector3 searchHitPoint = Vector3.zero;
    

    private void Start()
    {
        Initialized();
    }

    private void Initialized()
    {
        inputActions = new MainPlayerInputActions();
        inputActions.Player.Ether.Enable();

        activeWavePrefab = Instantiate(wavePrefab);
        activeWavePrefab.SetActive(false);

    }
    // on off로 해주기

    private float timer = 0f;

    private void Update()
    {
        PressedUpdate();
    }
    private bool isSpawn = false;
    private void PressedUpdate()
    {
        timer += Time.deltaTime;
        //if (activeWavePrefab.activeSelf)
        //    return;
        if (!isPressed)
        {
            if (inputActions.Player.Ether.IsPressed())
            {
                // 누르고 있을 땐 범위 체크로 계속해서 
                //PrintDebug("Press True");
                isPressed = true;
            }
        }
        else
        {
            if (!inputActions.Player.Ether.IsPressed())
            {
                if (timer < coolDownTime) return;
                else timer = 0f;

                //PrintDebug("Press False");
                isPressed = false;
                waveHolo_Positive.SetActive(false);
                waveHolo_Negative.SetActive(false);
                // 쏴라!!!
                activeWavePrefab.transform.position = new Vector3(waveSpawnPoint.position.x, searchHitPoint.y - 5f, waveSpawnPoint.position.z);
                activeWavePrefab.transform.rotation = Quaternion.Euler(transform.rotation.eulerAngles);
                activeWavePrefab.SetActive(false);
                activeWavePrefab.SetActive(isSpawn);

            }
            else
            {
                if (!CheckSpawns())
                {
                    //PrintDebug("Red");
                    waveHolo_Negative.transform.position = searchHitPoint;
                    waveHolo_Positive.SetActive(false);
                    waveHolo_Negative.SetActive(true);
                    isSpawn = false;
                }
                else
                {
                    //PrintDebug("Blue");
                    waveHolo_Positive.transform.position = searchHitPoint;
                    waveHolo_Positive.SetActive(true);
                    waveHolo_Negative.SetActive(false);
                    isSpawn = true;
                }
            }
        }
    }

    private bool CheckSpawns()
    {
       RaycastHit[] hits =  Physics.RaycastAll(waveSpawnPoint.position + (Vector3.up * SearchHeightOffset), Vector3.down,
            SearchHeightOffset * 2);

        hits = hits.OrderBy(i => i.distance).ToArray();

        if(hits == null || hits.Length == 0) return false;

        RaycastHit first = hits[0];
        searchHitPoint = first.point;

        if (!first.collider.CompareTag("WaterReaction"))
        {
            if (((1 << first.collider.gameObject.layer) & SpawnMask) != 0)
            {
                if (first.collider.gameObject.layer == 3)
                {
                    if (GlobalOceanManager.IsInstanceValid)
                    {
                        searchHitPoint = new Vector3(searchHitPoint.x, GlobalOceanManager.Instance.GetWaveHeight(searchHitPoint), searchHitPoint.z);
                    }
                }
                return true;
            }
            else
            {
                return false;
            }
        }


        //colliders = Physics.OverlapSphere(waveSpawnPoint.position, SearchRedius, SpawnMask);
        //if (colliders.Length > 0)
        //    return false;
        //return true;

        return true;
    }

    private void PrintDebug(string str)
    {
#if UNITY_EDITOR
        Debug.Log(str);
#endif
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        //Gizmos.matrix = transform.localToWorldMatrix;
        Gizmos.color = Color.magenta;
        DrawArrow.ForGizmo(waveSpawnPoint.position + (Vector3.up * SearchHeightOffset), Vector3.down * SearchHeightOffset * 2f);
        CheckSpawns();
        Gizmos.DrawWireSphere(searchHitPoint,0.5f);
    }

}
