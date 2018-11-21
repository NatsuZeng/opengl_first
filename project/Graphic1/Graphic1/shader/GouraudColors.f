#version 330 core

out vec4 FragColor;
in vec3 light;


uniform vec3 objectColor;


void main()
{
	//ambient
	//float ambientStrength = 0.5f;
	//vec3 ambientLight = ambientStrength * lightColor;

	//diffuse
	//vec3 lightDirection = normalize(lightPos - FragPos);
	//float diffStrength = max(dot(lightDirection,Normal),0.0);
	//vec3 diffuseLight = diffStrength * lightColor;

	//specular
	//float specularStrength = 0.5f;
	//vec3 viewDirection = normalize(viewPos - FragPos);
	//vec3 reflectDirection = reflect(-lightDirection,Normal);
	//float spec = pow(max(dot(viewDirection,reflectDirection),0.0),32);
	//vec3 specularLight = specularStrength * spec * lightColor;

	//light
	//vec3 light = ambientLight + diffuseLight + specularLight;

	//result
	vec3 result = light * objectColor;

	FragColor = vec4(result,1.0);
}