using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlowingLava : MonoBehaviour
{
    public float scrollSpeed = 0.1f;
    Renderer rendererComp;

    // Start is called before the first frame update
    void Start()
    {
        rendererComp = GetComponent<Renderer>();
    }

    // Update is called once per frame
    void Update()
    {
        float moveThis = Time.time * scrollSpeed;
        rendererComp.material.SetTextureOffset("_MainTex", new Vector2(0, moveThis));
    }
}