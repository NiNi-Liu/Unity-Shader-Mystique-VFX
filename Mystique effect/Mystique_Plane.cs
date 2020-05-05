using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mystique_Plane : MonoBehaviour
{
    [Header("Input")]
    [SerializeField]
    Material mat;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Plane plane = new Plane(transform.forward,transform.position);
        Vector4 m_vector = new Vector4(plane.normal.x, plane.normal.y, plane.normal.z, plane.distance);
        mat.SetVector("_mVector", m_vector);
    }
}
