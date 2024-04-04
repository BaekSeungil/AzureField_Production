using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class Elevator : MonoBehaviour
{

    [SerializeField] int StartPoint;
    [SerializeField] Transform[] Points;

    public float moveSpeed; 
    bool Ismove = false;
    bool reverse;
    int i;

    private void Start()
    {
        transform.position = Points[StartPoint].position;
        i = StartPoint;
    }

    private void Update() 
    {
        if(Vector3.Distance(transform.position, Points[i].position)< 0.01f)
        {
            Ismove = false;
            if(i==Points.Length - 1)
            {
                reverse = true;
                i--;
                return;
            }
            else if(i==0)
            {
                reverse =true;
                i++;
                return;
            }

            if(reverse)
            {
                i++;
            }
            else
            {
                i--;
            }
        }

        if(Ismove)
        {
            transform.position = Vector3.MoveTowards(transform.position,Points[i].position,
            moveSpeed * Time.deltaTime);
        }
    }

}
