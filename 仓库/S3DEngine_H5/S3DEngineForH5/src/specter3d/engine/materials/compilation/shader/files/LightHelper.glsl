// 灯光整理
struct DirectionLight
{
	vec3 diffuseColor;
	vec3 direction;
	vec3 ambientColor;
	vec3 specularColor;
	float specularShininess;
};

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
		vec3 eye = normalize(v_eye - out_fragpos);
		float specularFactor=pow(max(dot(eye,reflection),0.0),pLight.specularShininess);
		specularColor = pLight.specularColor * specularFactor;
	}
	float attenuate = 1.0 / dot(pLight.attenuation, vec3(1.0, d, d*d));
	diffuseColor  *= attenuate;
	specularColor *= attenuate;
	return vec4((pLight.ambientColor + diffuseColor + specularColor) * singleColor.rgb,u_DiffuseAlpha);
}