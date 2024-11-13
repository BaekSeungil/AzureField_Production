using UnityEngine;

public class SpawnableWaveControl : MonoBehaviour
{
    [SerializeField] private GameObject wavePrefab;
    [SerializeField] private Transform waveSpawnPoint;
    [SerializeField] private GameObject waveHolo_Positive;
    [SerializeField] private GameObject waveHolo_Negative;

    private GameObject activeWavePrefab;


}
