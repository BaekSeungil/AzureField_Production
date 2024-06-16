using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlidingPuzzle : MonoBehaviour
{
    public bool clearCheck = false;


    [SerializeField] private int[] piece = new int[9];
    //private int[] pieceNumber = new int[9];
    [SerializeField] private GameObject[] stonePiece = new GameObject[9];
    [SerializeField] private Transform[] pieceTransform = new Transform[9];


    // Start is called before the first frame update
    void Start()
    {
        FillArrayWithUniqueRandomValues();

        for (int i = 0; i < 9; i++) {
            stonePiece[i].transform.position = pieceTransform[piece[i]].position;
        }
        

    }

    // Update is called once per frame
    void Update()
    {
        
    }


    //배열내 중복된 값 제거 및 재배열
    private void FillArrayWithUniqueRandomValues()
    {
        List<int> possibleValues = new List<int>();

        // 가능한 값을 리스트에 추가
        for (int i = 0; i < 9; i++)
        {
            possibleValues.Add(i);
        }

        // 리스트를 섞음
        for (int i = 0; i < possibleValues.Count; i++)
        {
            int randomIndex = Random.Range(i, possibleValues.Count);
            int temp = possibleValues[i];
            possibleValues[i] = possibleValues[randomIndex];
            possibleValues[randomIndex] = temp;
        }

        // 섞인 값을 배열에 채워넣음
        for (int i = 0; i < piece.Length; i++)
        {
            piece[i] = possibleValues[i];
        }
    }
}
