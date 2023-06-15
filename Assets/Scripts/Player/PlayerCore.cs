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
    [SerializeField] private float swimSpeed = 1.0f;
    [SerializeField] private float jumpPower = 1.0f;


    [Title("Physics")]
    [SerializeField,Range(0f,1f)] private float horizontalDrag = 0.5f;
    [SerializeField] private float groundCastDistance = 0.1f;
    [SerializeField] private LayerMask groundIgnore;
    [SerializeField] private float WatersinkTreshold = 0.8f;
    [SerializeField] private LayerMask WaterLayer;
    [SerializeField,Range(0f,0.8f)] private float WaterWalkDragging = 0.5f;
    [SerializeField,ReadOnly] private bool grounding = false;
    [SerializeField,ReadOnly] private float WaterSinkRate = 0f;
    [SerializeField,ReadOnly] private Vector3 groundNormal = Vector3.up;

#if UNITY_EDITOR
    [SerializeField,ReadOnly,LabelText("CurrentMove")] private string current_move_debug = "";

#endif

    [Title("ChildReferences")]
    [SerializeField,Required] private Animator animator;
    [SerializeField,Required] private Transform RCO_foot;
    [SerializeField,Required] new CapsuleCollider collider;

    #endregion

    private Rigidbody rBody;
    private MainPlayerInputActions input;

    private bool sprinting = false;
    public bool Grounding { get { return grounding; } }

    private MovementState currentMovement_hidden;
    private MovementState CurrentMovement
    {
        get { return currentMovement_hidden; }
        set 
        { 
            if(currentMovement_hidden == null) currentMovement_hidden = value;
            else
            {
                if(currentMovement_hidden.GetType() == value.GetType()) return;
                    currentMovement_hidden.OnMovementExit(this);
                    currentMovement_hidden = value;
                    currentMovement_hidden.OnMovementEnter(this);
            }
        }           
    }


    private void Awake()
    {
        rBody = GetComponent<Rigidbody>();   

        input = new MainPlayerInputActions();
        input.Player.Enable();
        input.Player.Sprint.performed += OnSprint;
        input.Player.Sprint.canceled += OnSprintEnd;
        input.Player.Jump.performed += OnJump;

        CurrentMovement = new Movement_Ground();

    }

    private void Update() 
    {
        RaycastHit groundHit;

        if(Physics.Raycast(RCO_foot.position,-groundNormal,out groundHit,groundCastDistance,~groundIgnore))
        {
            grounding = true;
            groundNormal = groundHit.normal;

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

        RaycastHit waterHit;

        if(Physics.Raycast(transform.position + Vector3.up*collider.height*WatersinkTreshold, Vector3.down,out waterHit,WatersinkTreshold ,WaterLayer))
        {
            WaterSinkRate = (WatersinkTreshold - waterHit.distance) / WatersinkTreshold;
        }
        else
        {
            WaterSinkRate = 0.0f;
        }

        var watered = Physics.OverlapSphere(transform.position + Vector3.up*collider.height*WatersinkTreshold,0f,WaterLayer);
        
        if(watered.Length != 0 && CurrentMovement.GetType() == typeof(Movement_Ground))
        {
            CurrentMovement = new Movement_Swimming();
        }
        if(watered.Length == 0 && CurrentMovement.GetType() == typeof(Movement_Swimming))
        {
            CurrentMovement = new Movement_Ground();
        }

        // =================== CURRENT MOVEMENT UPDATE =========================
        CurrentMovement.OnUpdate(this);
        // =================== CURRENT MOVEMENT UPDATE =========================

#if UNITY_EDITOR
        if(CurrentMovement.GetType() == typeof(Movement_Ground)) current_move_debug = "GROUND";
        else if (CurrentMovement.GetType() == typeof(Movement_Swimming)) current_move_debug = "SWIMMING";
#endif
    }

    private void FixedUpdate() 
    {
        // =================== CURRENT MOVEMENT FIXED UPDATE =========================
        CurrentMovement.OnFixedUpdate(this);
        // =================== CURRENT MOVEMENT FIXED UPDATE =========================
    }


    #region MovementStates

    protected class MovementState
    {
        public virtual void OnMovementEnter(PlayerCore @player){}
        public virtual void OnUpdate(PlayerCore @player){}
        public virtual void OnFixedUpdate(PlayerCore @player){}
        public virtual void OnMovementExit(PlayerCore @player){}
    }

    protected class Movement_Ground : MovementState
    {
        public override void OnFixedUpdate(PlayerCore player)
        {
            base.OnFixedUpdate(player);

            if(player.input.Player.Move.IsPressed())
            {
                Vector2 inputVector = player.input.Player.Move.ReadValue<Vector2>();
                Vector3 lookTransformedVector = Camera.main.transform.TransformDirection(new Vector3(inputVector.x,0f,inputVector.y));
                lookTransformedVector = Vector3.ProjectOnPlane(lookTransformedVector, Vector3.up).normalized;
                
                float adjuestedScale = (player.sprinting && player.grounding) ? player.sprintSpeed : player.moveSpeed;
                Vector3 slopedMoveVelocity = Vector3.ProjectOnPlane(lookTransformedVector,player.groundNormal) * adjuestedScale;
                Vector3 finalVelocity = (1f - player.WaterSinkRate * player.WaterWalkDragging)*slopedMoveVelocity;
                player.rBody.velocity = new Vector3 (finalVelocity.x,player.rBody.velocity.y,finalVelocity.z);

                bool LargeTurn = Quaternion.Angle(player.transform.rotation,Quaternion.LookRotation(lookTransformedVector,Vector3.up)) > 60f;

                player.transform.rotation = Quaternion.RotateTowards(
                    player.transform.rotation,
                    Quaternion.LookRotation(lookTransformedVector, Vector3.up),
                    LargeTurn ? 30f : 10f
                );

                player.animator.SetBool("MovementInput",true);
            }
            else
            {
                player.rBody.velocity = Vector3.Lerp(player.rBody.velocity,new Vector3(0f,player.rBody.velocity.y,0f),player.horizontalDrag);
                player.animator.SetBool("MovementInput",false);
            }        
        }

        public override void OnUpdate(PlayerCore player)
        {
            base.OnUpdate(player);
            if(player.sprinting) player.animator.SetFloat("RunBlend",1f,0.5f,Time.deltaTime);
            else player.animator.SetFloat("RunBlend",0f,0.5f,Time.deltaTime);
        }
    }

    protected class Movement_Swimming : MovementState
    {
        public override void OnMovementEnter(PlayerCore player)
        {
            base.OnMovementEnter(player);
            player.animator.SetTrigger("Swimming_Enter");
            player.rBody.useGravity = false;
        }

        public override void OnFixedUpdate(PlayerCore player)
        {
            base.OnFixedUpdate(player);

              if(player.input.Player.Move.IsPressed())
            {
                Vector2 inputVector = player.input.Player.Move.ReadValue<Vector2>();
                Vector3 lookTransformedVector = Camera.main.transform.TransformDirection(new Vector3(inputVector.x,0f,inputVector.y));
                lookTransformedVector = Vector3.ProjectOnPlane(lookTransformedVector, Vector3.up).normalized;
        
                Vector3 finalVelocity = lookTransformedVector * player.moveSpeed;
                player.rBody.velocity = new Vector3 (finalVelocity.x,0f,finalVelocity.z);

                player.transform.rotation = Quaternion.RotateTowards(
                    player.transform.rotation,
                    Quaternion.LookRotation(lookTransformedVector, Vector3.up),
                    5f
                );
                player.animator.SetBool("Swimming_Move",true);
            }
            else
            {
                player.rBody.velocity = Vector3.Lerp(player.rBody.velocity,Vector3.zero,player.horizontalDrag);
                player.animator.SetBool("Swimming_Move",false);
            }
        }

        public override void OnMovementExit(PlayerCore player)
        {
            base.OnMovementExit(player);
            player.animator.SetTrigger("Swimming_Exit");
            player.rBody.useGravity = true;
        }
    }

    #endregion 

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
