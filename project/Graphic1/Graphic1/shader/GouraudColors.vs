#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform mat3 normalMat;
uniform vec3 lightColor;
uniform vec3 lightPos;
uniform vec3 viewPos;

//out vec3 FragPos;
//out vec3 Normal;
out vec3 light;

void main()
{
	vec3 FragPos = vec3(model * vec4(aPos,1.0f));
	//Normal = normalize(vec3(model*vec4(aNormal,0.0f)));
	//Normal = mat3(transpose(inverse(model)))*aNormal;
	//Normal = normalize(aNormal);
	vec3 Normal = normalMat*aNormal;
	gl_Position = projection * view * model * vec4(aPos,1.0);

	//Gouraud×ÅÉ«·¨
	//ambient
	float ambientStrength = 0.5f;
	vec3 ambientLight = ambientStrength * lightColor;

	//diffuse
	vec3 lightDirection = normalize(lightPos - FragPos);
	float diffuseStrength = max(dot(Normal,lightDirection),0.0);
	vec3 diffuseLight = diffuseStrength * lightColor;
	
	//specular
	float specularStrength = 0.5f;
	vec3 viewDirection = normalize(viewPos - FragPos);
	vec3 reflectDirection = reflect(-lightDirection,Normal);
	float specular = pow(max(dot(reflectDirection,viewDirection),0.0),32);
	vec3 specularLight = specularStrength * specular * lightColor;

	light = ambientLight + diffuseLight + specularLight;

}