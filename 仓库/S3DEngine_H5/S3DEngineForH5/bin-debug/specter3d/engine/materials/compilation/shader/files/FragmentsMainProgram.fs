#ifdef FSHIGHPRECISION
	precision highp float;
#else
	precision mediump float;
#endif

uniform vec3 u_camerapos;
uniform float u_DiffuseAlpha;
varying vec3 v_eye;

#ifdef USE_DIFFUSE_MAP
	uniform sampler2D u_DiffuseSampler;
#else
	uniform vec3 u_DiffuseColor;
#endif

#ifdef USE_UV
	varying vec2 v_UV;
#endif

#ifdef USE_NORMAL
	varying vec3 v_Normal;
#endif

#ifdef USE_LIGHT_DIRECTION
struct DirectionLight
{
	vec3 diffuseColor;
	vec3 direction;
	vec3 ambientColor;
	vec3 specularColor;
	float specularShininess;
};

uniform DirectionLight u_DirectionLight;

vec4 computeDirectionLight(vec3 outNormal,in vec4 singleColor,in DirectionLight dLight)
{
	vec3 normal = normalize(outNormal);
	vec3 lightVec=-normalize(dLight.direction);
	float diffuseFactor = dot(normal,lightVec);
	vec3 diffuseColor= vec3(0.0);
	vec3 specularColor=vec3(0.0);
	if(diffuseFactor  > 0.0)
	{
	    diffuseColor = dLight.diffuseColor * diffuseFactor ;
		vec3 reflection=reflect(lightVec,normal);
		vec3 eye = normalize(v_eye);
		float specularFactor=pow(max(dot(eye,reflection),0.0),dLight.specularShininess);
		specularColor = dLight.specularColor * specularFactor;
	}
	return vec4((dLight.ambientColor + diffuseColor + specularColor) * singleColor.rgb,u_DiffuseAlpha);
}
#endif

#ifdef USER_LIGHT_POINT
struct PointLight
{
	vec3 position;
	vec3 diffuseColor;
	vec3 ambientColor;
	vec3 specularColor;
	float specularShininess;
	float range;
	vec3 attenuation;
};
uniform PointLight u_PointLight[8];
varying vec3 out_fragpos;

vec4 computePointLight(vec3 outNormal,in vec4 singleColor,in PointLight pLight)
{
	vec3 diffuseColor= vec3(0.0);
	vec3 specularColor=vec3(0.0);
	
	vec3 normal = normalize(outNormal);
	vec3 lightVec=normalize(pLight.position-out_fragpos);
	
	float d = length(lightVec);
	
	if( d > pLight.range)
		return vec4((pLight.ambientColor + diffuseColor + specularColor) * singleColor.rgb,u_DiffuseAlpha);
		
	lightVec /= d;
	
	float diffuseFactor = dot(normal,lightVec);
	
	if(diffuseFactor  > 0.0)
	{
		diffuseColor = pLight.diffuseColor * diffuseFactor;
		vec3 reflection=normalize(reflect(lightVec,normal));
		vec3 eye = normalize(out_fragpos);
		float specularFactor=pow(max(dot(eye,reflection),0.0),pLight.specularShininess);
		specularColor = pLight.specularColor * specularFactor;
	}
	float attenuate = 1.0 / dot(pLight.attenuation, vec3(1.0, d, d*d));
	diffuseColor  *= attenuate;
	specularColor *= attenuate;
	return vec4((pLight.ambientColor + diffuseColor + specularColor) * singleColor.rgb,u_DiffuseAlpha);
}
#endif

void main()
{
	vec4 singleColor = vec4(1.0);
	#ifdef USE_DIFFUSE_MAP
		singleColor = texture2D(u_DiffuseSampler, v_UV);
	#else
		singleColor = vec4(u_DiffuseColor,u_DiffuseAlpha);
	#endif
	#ifdef USE_LIGHT_DIRECTION
		singleColor = computeDirectionLight(v_Normal,singleColor,u_DirectionLight);
	#endif
	#ifdef USER_LIGHT_POINT
		vec4 results = vec4(0.0);
		results += computePointLight(v_Normal,singleColor,u_PointLight[0]);
		results += computePointLight(v_Normal,singleColor,u_PointLight[1]);
		results += computePointLight(v_Normal,singleColor,u_PointLight[2]);
		results += computePointLight(v_Normal,singleColor,u_PointLight[3]);
		singleColor = results;
	#endif
	
	
	singleColor.a = u_DiffuseAlpha;
	gl_FragColor = singleColor;
	
}