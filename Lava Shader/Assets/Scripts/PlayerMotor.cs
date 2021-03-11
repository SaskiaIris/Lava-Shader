using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Animator))]
//[RequireComponent(typeof(CharacterController))]

public class PlayerMotor : MonoBehaviour {
    public float forwardSpeed = 2f;
    public float backwardSpeed = 1f;
    public float rotateSpeed = 1f;
    public float jumpSpeed = 6f;


    private Vector3 velocity;
    private float h;
    private float v;

    private bool isJumping;


    Animator animator;
    Rigidbody rigidBody;

    private void Start() {
        animator = GetComponent<Animator>();
        rigidBody = GetComponent<Rigidbody>();

        isJumping = false;
    }

	void Update() {
        h = Input.GetAxis("Horizontal");
        v = Input.GetAxis("Vertical");

        velocity = new Vector3(0, 0, v);
        velocity = transform.TransformDirection(velocity);

        if(v > 0.01) {
            velocity *= forwardSpeed;
            animator.SetBool("Walk", true);
        } else if(v < -0.01) {
            velocity *= backwardSpeed;
            animator.SetBool("Walk back", true);
        } else {
            animator.SetBool("Walk", false);
            animator.SetBool("Walk back", false);
        }

        if(h != 0) {
            transform.Rotate(0, h * rotateSpeed, 0);
        }
        //Jumping
        if(Input.GetButton("Jump") && isJumping == false) {
            //velocity.y = jumpSpeed;
            rigidBody.AddForce(new Vector3(0,jumpSpeed,0), ForceMode.Impulse);
            animator.SetBool("Jump", true);
            isJumping = true;
        }

        transform.localPosition += velocity * Time.fixedDeltaTime;
    }

	private void OnTriggerEnter(Collider other) {
        if(other.gameObject.transform.tag == "Floor") {
            isJumping = false;
            animator.SetBool("Jump", false);
        } else {
        
        }
	}

	/*private void OnCollisionEnter(Collision collision) {
        isJumping = false;
	}*/
}