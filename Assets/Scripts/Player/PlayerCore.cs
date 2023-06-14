using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using Sirenix.OdinInspector;

public class PlayerCore : SerializedMonoBehaviour
{
    #region Properties

    [Title("ControlProperties")]
    [SerializeField] private float moveSpeed = 1.0f;
    [ SerializeField] private float sprintSpeed = 2.0f;
    [SerializeField] private float jumpPower = 1.0f;

    [Title("Physics")]
    [SerializeField] private float groundCastDistance = 0.1f;
    [SerializeField] private LayerMask groundIgnore;
    [SerializeField,ReadOnly] private bool grounding = false;
    [SerializeField,Range(0f,1f)] private float horizontalDrag = 0.5f;

    [Title("ChildReferences")]
    [SerializeField] private Animator animator;
    [SerializeField] private Transform RCO_foot;




    private Rigidbody rBody;
    private MainPlayerInputActions input;

    private Vector3 groundNormal = Vector3.up;
    private bool sprinting = false;
    public bool Grounding { get { return grounding; } }


    #endregion

    private void Awake()
    {
        rBody = GetComponent<Rigidbody>();   

        input = new MainPlayerInputActions();
        input.Player.Enable();
        input.Player.Sprint.performed += OnSprint;
        input.Player.Sprint.canceled += OnSprintEnd;
        input.Player.Jump.performed += OnJump;

    }

    private void Update() 
    {
        RaycastHit rHit;

        if(Physics.Raycast(RCO_foot.position,-groundNormal,out rHit,groundCastDistance,~groundIgnore))
        {
            grounding = true;

            groundNormal = rHit.normal;

            animator.SetBool("Grounding", true);
        }
        else
        {
            if(grounding) OnGroundingEnter();

            grounding = false;
            groundNormal = Vector3.up;

            animator.SetBool("Grounding", false);
            if(rBody.velocity.y > 0) animator.SetFloat("AirboneBlend",0f,0.5f,Time.deltaTime);
            else animator.SetFloat("AirboneBlend",1f,0.5f,Time.deltaTime);
        }


        if(sprinting) animator.SetFloat("RunBlend",1f,0.5f,Time.deltaTime);
        else animator.SetFloat("RunBlend",0f,0.5f,Time.deltaTime);
    }

    private void FixedUpdate() 
    {
        if(input.Player.Move.IsPressed())
        {
            Vector2 inputVector = input.Player.Move.ReadValue<Vector2>();
            Vector3 lookTransformedVector = Camera.main.transform.TransformDirection(new Vector3(inputVector.x,0f,inputVector.y));
            lookTransformedVector = Vector3.ProjectOnPlane(lookTransformedVector, Vector3.up).normalized;
            
            float adjuestedScale = (sprinting && grounding) ? sprintSpeed : moveSpeed;
            Vector3 slopedMoveVelocity = Vector3.ProjectOnPlane(lookTransformedVector,groundNormal).normalized * adjuestedScale;
            rBody.velocity = new Vector3 (slopedMoveVelocity.x,rBody.velocity.y,slopedMoveVelocity.z);

            transform.rotation = Quaternion.RotateTowards(
                transform.rotation,
                Quaternion.LookRotation(lookTransformedVector, Vector3.up),
                10f
            );

            animator.SetBool("MovementInput",true);
        }
        else
        {
            rBody.velocity = Vector3.Lerp(rBody.velocity,new Vector3(0f,rBody.velocity.y,0f),horizontalDrag);
            animator.SetBool("MovementInput",false);
        }
    }

    #region InputCallbacks

    private void OnJump(InputAction.CallbackContext context)
    {
        if(grounding)
        {
            rBody.velocity += Vector3.up * jumpPower;
            animator.SetFloat("AirboneBlend",0f);
        }
    }

    private void OnSprint(InputAction.CallbackContext context)
    {
        sprinting = true;

    }

    private void OnSprintEnd(InputAction.CallbackContext context)
    {
        sprinting = false;
    }

    #endregion

    private void OnGroundingEnter()
    {

    }
}
