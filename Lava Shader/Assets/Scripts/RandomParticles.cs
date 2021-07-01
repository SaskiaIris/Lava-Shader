using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomParticles : MonoBehaviour {
    [Header("Prefabs")]
    [SerializeField]
    private GameObject particlePrefab;

    [SerializeField]
    private GameObject lavaField;
    

    [Header("The tag to find the Particle System's GameObjects")]
    [SerializeField]
    private string spawnTag = "Spawnable";



    [Header("Minimum time to keep a Particle System alive")]
    [SerializeField, Tooltip("Also used for the waiting time before destroy after fading out")]
    private float minimumEmittingTime = 2.0f;



    [Header("Time between spawns, min and max")]
    [SerializeField]
    private float spawnIntervalMin = 2.0f;

    [SerializeField]
    private float spawnIntervalMax = 8.0f;


    [Header ("Smoke clouds per spawn, min and max")]
    [SerializeField]
    private int minParticlesToSpawn = 1;

    [SerializeField]
    private int maxParticlesToSpawn = 3;


    [Header("Maximum amount of smoke clouds on screen")]
    [SerializeField, Tooltip("Gets automatically set to the length of the lava field, only numbers lower than that length get accepted")] //TODO: explain why
    private int maxParticlesOnScreen = 10;    

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
            if(Random.Range(0, 5) == 0) {
                particleAmountToSpawn = 0;
            } else {
                particleAmountToSpawn = Random.Range(minParticlesToSpawn, maxParticlesToSpawn);
            }

            for(int i = 0; i < particleAmountToSpawn; i++) {
                DestroyTimedOutParticles();

                toSpawn = particlePrefab;
                screenX = Random.Range(lavaMeshCollider.bounds.min.x, lavaMeshCollider.bounds.max.x);
                screenY = Random.Range(lavaMeshCollider.bounds.min.y, lavaMeshCollider.bounds.max.y);
                screenZ = Random.Range(lavaMeshCollider.bounds.min.z, lavaMeshCollider.bounds.max.z);
                smokePosition = new Vector3(screenX, screenY, screenZ);

                Instantiate(toSpawn, smokePosition, lavaField.transform.rotation);
            }

            spawnInterval = Random.Range(spawnIntervalMin, spawnIntervalMax);

            yield return new WaitForSeconds(spawnInterval);
        }
    }

    private void DestroyTimedOutParticles()	{
        currentParticleSystems = GameObject.FindGameObjectsWithTag(spawnTag);

        int randomizedMaxParticles = Random.Range(maxParticlesOnScreen - 3, maxParticlesOnScreen);
        Debug.Log("Randomized max particles: " + randomizedMaxParticles);

        //TODO: destroy random with intervals not all at once
        foreach(GameObject particleObject in currentParticleSystems) {
            if(currentParticleSystems.Length <= randomizedMaxParticles) {
                //Do nothing maybe

                //TODO: randomly fading out some of the particles

                /*Debug.Log("TEST" + particleObject.GetComponent<ParticleSystem>().main.duration);
                if(particleObject.GetComponent<ParticleSystem>().main.duration > minimumEmittingTime) {
                    if(Random.Range(0, 4) == 4) {
                        FadeOut(particleObject, minimumEmittingTime);
                    }
                }*/
            } else {
                FadeOut(particleObject, minimumEmittingTime);
            }
		}
	}

	private void FadeOut(GameObject particleToFadeOut, float fadeSpeed) {
        ParticleSystem particleSystem = particleToFadeOut.transform.GetComponent<ParticleSystem>();
        particleSystem.Stop();
        Destroy(particleToFadeOut, fadeSpeed);
	}
}