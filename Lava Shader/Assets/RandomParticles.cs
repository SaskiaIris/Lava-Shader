using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomParticles : MonoBehaviour {
    [SerializeField]
    private int particleRate = 1;

    [SerializeField]
    private GameObject particlePrefab;

    public Transform[] SpawnPoints;

    // Start is called before the first frame update
    void Start()
    {
        Transform selectedSpawnPoint = SpawnPoints[(int)Random.Range(0, SpawnPoints.Count - 1)];
        Instantiate(particlePrefab, selectedSpawnPoint.position, selectedSpawnPoint.rotation);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
