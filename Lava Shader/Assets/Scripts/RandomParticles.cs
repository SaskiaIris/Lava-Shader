using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomParticles : MonoBehaviour {
    [Header ("Particle amount per spawn, min and max")]
    [SerializeField]
    private int minParticlesToSpawn = 1;

    [SerializeField]
    private int maxParticlesToSpawn = 5;

    [Header ("The tag that the particle systems have")]
    [SerializeField]
    private string spawnTag = "Spawnable";

    [SerializeField]
    private int maxParticlesOnScreen = 10;

    [Header ("Time between spawns")]
    [SerializeField]
    private float spawnIntervalMin = 2.0f;

    [SerializeField]
    private float spawnIntervalMax = 8.0f;

    [SerializeField]
    private GameObject particlePrefab;

    [SerializeField]
    private GameObject lavaField;

    //All particle systems/gameobjects currently active in the scene
    private GameObject[] currentParticleSystems;

    // Start is called before the first frame update
    void Start() {
        StartCoroutine("SpawnParticles");

        if(maxParticlesOnScreen > lavaField.transform.localScale.x) {
            maxParticlesOnScreen = (int) lavaField.transform.localScale.x;
        }

        Debug.Log("Max particles: " + maxParticlesOnScreen);
    }

    // Update is called once per frame
    void Update() {
        
    }

    IEnumerator SpawnParticles() {
        int particleAmountToSpawn;
        GameObject toSpawn;
        MeshCollider lavaMeshCollider = lavaField.GetComponent<MeshCollider>();

        float screenX, screenY, screenZ;
        Vector3 smokePosition;

        float spawnInterval;

        for(; ; ) {
            DestroyTimedOutParticles();

            if(Random.Range(0, 5) == 0) {
                particleAmountToSpawn = 0;
            } else {
                particleAmountToSpawn = Random.Range(minParticlesToSpawn, maxParticlesToSpawn);
            }

            for(int i = 0; i < particleAmountToSpawn; i++) {
                toSpawn = particlePrefab;
                screenX = Random.Range(lavaMeshCollider.bounds.min.x, lavaMeshCollider.bounds.max.x);
                screenY = Random.Range(lavaMeshCollider.bounds.min.y, lavaMeshCollider.bounds.max.y);
                screenZ = Random.Range(lavaMeshCollider.bounds.min.z, lavaMeshCollider.bounds.max.z);
                smokePosition = new Vector3(screenX, screenY, screenZ);

                Instantiate(toSpawn, smokePosition, lavaField.transform.rotation);

                yield return new WaitForSeconds(Random.Range(0.0f, 0.5f));
            }

            spawnInterval = Random.Range(spawnIntervalMin, spawnIntervalMax);

            yield return new WaitForSeconds(spawnInterval);
        }
    }

    private void DestroyTimedOutParticles()	{
        currentParticleSystems = GameObject.FindGameObjectsWithTag(spawnTag);
        int randomizeMaxParticles = Random.Range(maxParticlesOnScreen - 3, maxParticlesOnScreen);
        foreach(GameObject o in currentParticleSystems) {
            if(o.GetComponent<ParticleSystem>().isPlaying && currentParticleSystems.Length <= randomizeMaxParticles) {
                //Do nothing
            } else if(o.GetComponent<ParticleSystem>().isPlaying && currentParticleSystems.Length <= randomizeMaxParticles) {
                FadeOut(o);
            } else {
                Destroy(o);
            }
		}
	}

	private void FadeOut(GameObject particleToFadeOut) {
        
        Destroy(particleToFadeOut);
	}

}
