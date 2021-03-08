using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Animator))]
//[RequireComponent(typeof(CharacterController))]

public class PlayerMotor : MonoBehaviour {
    public float forwardSpeed = 0.5f;
    public float backwardSpeed = 0.2f;
    public float rotateSpeed = 0.2f;
    //public float jumpSpeed = 8.0f;


    private Vector3 velocity;
    private float h;
    private float v;


    Animator animator;
    //CharacterController controller;

    private void Start() {
        animator = GetComponent<Animator>();
        //controller = GetComponent<CharacterController>();
    }

	void Update() {
        h = Input.GetAxis("Horizontal");
        v = Input.GetAxis("Vertical");

        velocity = new Vector3(0, 0, v);
        velocity = transform.TransformDirection(velocity);

        if(v > 0.1) {
            velocity *= forwardSpeed;
            animator.SetBool("Walk", true);
        } else if(v < -0.1) {
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
        /*if(Input.GetButtonDown("Jump")) {
                velocity.y = jumpSpeed;
                animator.SetBool("Jump", true);
            }
            if(Input.GetButtonUp("Jump")) {
                animator.SetBool("Jump", false);
            }*/

        transform.localPosition += velocity * Time.fixedDeltaTime;
    }
}