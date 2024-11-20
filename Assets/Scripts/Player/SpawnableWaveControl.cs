using UnityEngine;

public class SpawnableWaveControl : MonoBehaviour
{
    [SerializeField] private GameObject wavePrefab;
    [SerializeField] private Transform waveSpawnPoint;
    [SerializeField] private GameObject waveHolo_Positive;
    [SerializeField] private GameObject waveHolo_Negative;
    [SerializeField] private float SearchRedius;
    [SerializeField] private LayerMask SpawnMask;
    //[SerializeField] private GameObject waveParticlePrefab;
    private GameObject activeWavePrefab;
    

    private MainPlayerInputActions inputActions;
    private Collider[] colliders;

    private bool isPressed;
    

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

    private void Update()
    {
        PressedUpdate();
    }
    private bool isSpawn = false;
    private void PressedUpdate()
    {
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
                //PrintDebug("Press False");
                isPressed = false;
                waveHolo_Positive.SetActive(false);
                waveHolo_Negative.SetActive(false);
                // 쏴라!!!
                activeWavePrefab.transform.position = new Vector3(waveSpawnPoint.position.x, waveSpawnPoint.position.y - 5f, waveSpawnPoint.position.z); ;

                activeWavePrefab.transform.rotation = Quaternion.Euler(transform.rotation.eulerAngles);
                activeWavePrefab.SetActive(isSpawn);

            }
            else
            {
                if(CheckSpawns())
                {
                    //PrintDebug("Red");
                    waveHolo_Positive.SetActive(false);
                    waveHolo_Negative.SetActive(true);
                    isSpawn = false;
                }
                else
                {
                    //PrintDebug("Blue");
                    waveHolo_Positive.SetActive(true);
                    waveHolo_Negative.SetActive(false);
                    isSpawn = true;
                }
            }
        }
    }

    private bool CheckSpawns()
    {
        colliders = Physics.OverlapSphere(waveSpawnPoint.position, SearchRedius, SpawnMask);
        if (colliders.Length > 0)
            return false;
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
        Gizmos.matrix = transform.localToWorldMatrix;
        Gizmos.DrawWireSphere(waveSpawnPoint.position, SearchRedius);
    }

}
