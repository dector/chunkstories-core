/*
Fancy procedural sky
Massive thanks to robobo1221 for this !

Requires uniforms:
Camera camera
WorldConditions world
*/

//const float overcastFactor = 0.0;
#define overcastFactor world.cloudyness
#define sunPos world.sunPosition
#define foggyness clamp(overcastFactor * overcastFactor * 4.0, 0.0, 1.0)

#define PI 3.14159265359
#define pi PI

#define aWeather	overcastFactor*overcastFactor*overcastFactor			//0 is clear 1 is rainy

#define rCoeff vec3(0.3,0.5,0.9)	//Rayleigh coefficient //You can edit this to your liking
#define mCoeff mix(0.1, 5.0, aWeather)	//Mie coefficient //You can edit this to your liking
#define mieSize mix(0.05, 5.0, aWeather)	//Mie Multiscatter Radius //You can edit this to your liking
#define eR 8000.0			//Earth radius (not particulary accurate) //You can edit this to your liking
#define aR mix(0.25, 0.25, aWeather)				//Atmosphere radius (also not accurate) //You can edit this to your liking
#define scatterBrightness 1.0	//Brightness of the sky //You can edit this to your liking
#define sunBrightness 70.0; //Brightness of the sunspot //You can edit this to your liking

#define aRef(x,x2,y)(x*y+x2*y)		//Reflects incomming light
#define aAbs(x,x2,y)exp2(-aRef(x,x2,y))	//Absorbs incomming light
#define d0Fix(x)abs(x+1.0e-32)		//Fixes devide by zero infinites
#define sA(x,y,z,w)d0Fix(x-y)/d0Fix(z-w)	//Absorbs scattered light
#define aScatter(x,y,z,w,s)sA(x,y,z,w)*s //Scatters reflected light

float gDepth(float x){float d=eR+aR,eR2=eR*eR;float b=x*eR ;return sqrt(d*d+b*b-eR2)+b;}	//Calculates the distance between the camera and the edge of the atmosphere
float rPhase(float x){return 0.375*(x*x+1.0);}								//Rayleigh phase function
float gPhase(float x,float g){float g2 = g*g;return (1.0/4.0*PI)*((1.0-g2)/pow(1.0+g2-2.0*g*x,1.5));}	//Henyey greenstein phase function
float mPhase(float x,float d){return gPhase(x,exp2(d*-mieSize));}						//Mie phase function

float calcSunSpot(float x){const float sunSize = 0.9997; return smoothstep(sunSize, sunSize+0.00001,x);}	//Calculates sunspot

float lDotU = dot(normalize(world.sunPosition), vec3(0.0, -1.0, 0.0)); //float lDotV = dot(l, v);
float opticalSunDepth = gDepth(lDotU);	//Get depth from lightpoint
vec3 sunAbsorb    = aAbs(rCoeff, mCoeff, opticalSunDepth);
#define foggyness clamp(overcastFactor * overcastFactor * 4.0, 0.0, 1.0)

vec3 getAtmosphericScatteringAmbient(){
	float uDotV = -0.5; //float lDotV = dot(l, v);
	
	float opticalDepth    = gDepth(uDotV);	//Get depth from viewpoint
	
	float phaseRayleigh = rPhase(lDotU);		//Rayleigh Phase
	float phaseMie = mPhase(lDotU, opticalDepth);	//Mie Phase
	
	vec3 viewAbsorb   = aAbs(rCoeff, mCoeff, opticalDepth);
	vec3 sunCoeff     = aRef(rCoeff, mCoeff, opticalSunDepth);
	vec3 viewCoeff    = aRef(rCoeff, mCoeff, opticalDepth);
	vec3 viewScatter  = aRef(rCoeff * phaseRayleigh, mCoeff * phaseMie, opticalDepth);
	
	vec3 finalScatter = aScatter(sunAbsorb, viewAbsorb, sunCoeff, viewCoeff, viewScatter); //Scatters all sunlight
	vec3 result = (finalScatter * PI) * (2.0 * scatterBrightness);

	result += vec3(0.0, 0.4, 1.0) * 0.0025;
	
	return result;
}

vec3 getAtmosphericScattering(vec3 v, vec3 sunVec, vec3 upVec, float sunspotStrength){ 
	sunVec = normalize(sunVec);
	v = normalize(v);
	upVec = normalize(upVec);
	
	float lDotV = dot(sunVec, v); //float lDotV = dot(l, v);
	float uDotV = dot(upVec, -v); //float lDotV = dot(l, v);
	
	float opticalDepth    = gDepth(uDotV);	//Get depth from viewpoint
	float opticalDepth2    = gDepth(uDotV);	//Get depth from viewpoint

    // slightly fuzz this to avoid nasty artifact
    // i have no idea how this sky actually works
    // may the shader gods accept my repentence
    if(opticalDepth == opticalSunDepth) {
        opticalDepth += 0.1;
    }
	
	float phaseRayleigh = rPhase(lDotV);		//Rayleigh Phase
	float phaseMie = mPhase(lDotV, opticalDepth2);	//Mie Phase
	
	vec3 viewAbsorb   = aAbs(rCoeff, mCoeff, opticalDepth);
	vec3 sunCoeff     = aRef(rCoeff, mCoeff, opticalSunDepth);
	vec3 viewCoeff    = aRef(rCoeff, mCoeff, opticalDepth);
	vec3 viewScatter  = aRef(rCoeff * phaseRayleigh, mCoeff * phaseMie, opticalDepth2);
	
	vec3 finalScatter = (abs(sunAbsorb - viewAbsorb) + 0.000001) / (abs( sunCoeff - viewCoeff) + 0.000001) * viewScatter; //Scatters all sunlight
    if(sunCoeff == viewCoeff)
        finalScatter = viewScatter;

	vec3 sunSpot = (calcSunSpot(lDotV) * viewAbsorb) * sunBrightness; //Sunspot
	sunSpot *= sunspotStrength * (1.0 - foggyness);
	//vec3 sunSpot = vec3(0);
	
	vec3 result = (finalScatter + sunSpot) * PI * (2.0 * scatterBrightness);

	result += vec3(0.0, 0.4, 1.0) * 0.0025;
	
    return result;
    //return result;
}

//Returns the sky color depending on direction and time
vec3 getSkyColor(float time, vec3 eyeDirection)
{
	return getAtmosphericScattering(eyeDirection, world.sunPosition, vec3(0.0, 1.0, 0.0), 5.0);
}

vec4 getFogColor(float time, vec3 eyePosition)
{	
	float overCastRatio = clamp(aWeather * 2.0, 0.0, 1.0);
	
	float dist = clamp(length(eyePosition) - mix(64.0, 0.0, foggyness), 0.0, 4096.0) * mix(0.002, 0.015, foggyness);
	float fogIntensity = 1.0 - exp2(-dist);	//Proper realistic fog distribution
	
	vec3 fogColor = getAtmosphericScatteringAmbient();
	
	return vec4(fogColor, fogIntensity);
}