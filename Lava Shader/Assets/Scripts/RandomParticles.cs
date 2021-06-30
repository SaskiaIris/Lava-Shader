using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomParticles : MonoBehaviour {
    [SerializeField]
    private int particleRate = 1;

    [SerializeField]
    private GameObject particlePrefab;

    [SerializeField]
    private List<GameObject> spawnPool;

    [SerializeField]
    private GameObject lavaField;

    // Start is called before the first frame update
    void Start()
    {
        SpawnParticles();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void SpawnParticles()
	{
        DestroyTimedOutParticles();
        int randomItem = 0;
        GameObject toSpawn;
        MeshCollider lavaMeshCollider = lavaField.GetComponent<MeshCollider>();

	}

    private void DestroyTimedOutParticles()
	{

	}
}
