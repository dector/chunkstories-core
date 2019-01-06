#version 330
//Entry attributes
in vec4 vertexIn;
in vec2 texCoordIn;
in vec4 normalIn;
in ivec4 boneIdIn;
in vec4 boneWeightsIn;

out vec2 texcoord;
out vec2 worldLight;
out float fresnelTerm;
out float chunkFade;
out float rainWetness;
out float fogI;
out vec4 modelview;
out vec3 eye;

out vec3 inNormal;
out vec4 inVertex;
uniform float useColorIn;
uniform float useNormalIn;
uniform float isUsingInstancedData;
uniform sampler2D instancedDataSampler;

//Lighthing
uniform float sunIntensity;

uniform float time;
uniform vec3 camPos;

uniform float vegetation;
uniform mat4 projectionMatrix;
uniform mat4 projectionMatrixInv;

uniform mat4 modelViewMatrix;
uniform mat4 modelViewMatrixInv;

uniform mat3 normalMatrix;
uniform mat3 normalMatrixInv;

uniform vec2 worldLightIn;

uniform mat4 objectMatrix;
uniform mat3 objectMatrixNormal;

uniform mat4 bones[32];

//Weather
uniform float wetness;

uniform int isShadowPass;
#include ../lib/shadowTricks.glsl

void main(){
	//Usual variable passing
	texcoord = texCoordIn;
	vec4 v0 = bones[boneIdIn.x] * vec4(vertexIn.xyz, 1.0);
	vec4 v1 = bones[boneIdIn.y] * vec4(vertexIn.xyz, 1.0);
	vec4 v2 = bones[boneIdIn.z] * vec4(vertexIn.xyz, 1.0);
	vec4 v3 = bones[boneIdIn.w] * vec4(vertexIn.xyz, 1.0);
	
	vec4 v = objectMatrix * (v0 * boneWeightsIn.x + v1 * boneWeightsIn.y + v2 * boneWeightsIn.z + v3 * boneWeightsIn.w);
	
	vec4 n0 = bones[boneIdIn.x] * vec4(normalIn.xyz, 0.0);
	vec4 n1 = bones[boneIdIn.y] * vec4(normalIn.xyz, 0.0);
	vec4 n2 = bones[boneIdIn.z] * vec4(normalIn.xyz, 0.0);
	vec4 n3 = bones[boneIdIn.w] * vec4(normalIn.xyz, 0.0);
	
	vec4 n = objectMatrix * (n0 * boneWeightsIn.x + n1 * boneWeightsIn.y + n2 * boneWeightsIn.z + n3 * boneWeightsIn.w);
	
	//v = objectMatrix * v0;
	//vec4 v = objectMatrix * vec4(vertexIn.xyz, 1.0);
	
	/*if(isUsingInstancedData > 0)
	{
		mat4 matrixInstanced = mat4(texelFetch(instancedDataSampler, ivec2(mod(gl_InstanceID * 8, 32), (gl_InstanceID * 8) / 32), 0),
									texelFetch(instancedDataSampler, ivec2(mod(gl_InstanceID * 8 + 1, 32), (gl_InstanceID * 8 + 1) / 32), 0),
									texelFetch(instancedDataSampler, ivec2(mod(gl_InstanceID * 8 + 2, 32), (gl_InstanceID * 8 + 2) / 32), 0),
									texelFetch(instancedDataSampler, ivec2(mod(gl_InstanceID * 8 + 3, 32), (gl_InstanceID * 8 + 3) / 32), 0)
									);
	
		v = matrixInstanced * vec4(vertexIn.xyz, 1.0);
		
		inVertex = v;
		inNormal =  mat3(transpose(inverse(matrixInstanced))) * (normalIn).xyz;//(normalIn.xyz-0.5)*2.0;//normalIn;;
	}*/
	
	inVertex = v;
	inNormal = objectMatrixNormal * normalize(n).xyz;//(normalIn.xyz-0.5)*2.0;//normalIn;
	
	fresnelTerm = 0.0 + 1.0 * clamp(0.7 + dot(normalize(v.xyz - camPos), vec3(inNormal)), 0.0, 1.0);
	
	//Compute lightmap coords
	rainWetness = wetness;
	
	//if(isUsingInstancedData > 0)
	//	worldLight = vec2(texelFetch(instancedDataSampler, ivec2(mod(gl_InstanceID * 8 + 4, 32), (gl_InstanceID * 8 + 5) / 32), 0).xy / 15.0);
	
	worldLight = vec2(worldLightIn / 15.0);
	
	gl_Position = projectionMatrix * modelViewMatrix * v;
	if(isShadowPass == 1)
		gl_Position = accuratizeShadowIn(modelViewMatrix * v);
	
	//Eye transform
	eye = v.xyz-camPos;
}