#version 330 core

out vec4 FragColor;

in vec3 FragPos;
in vec3 normal;

struct Material
{
	//PhongObjectColor
	vec3 ambient;
	vec3 diffuse;
	vec3 specular;
	float shininess;
};
struct Light
{
	vec3 lightPos;
	//PhongLightColor;控制三个phong光照形式的各个分量强度
	vec3 ambientColor;
	vec3 diffuseColor;
	vec3 specularColor;
};

uniform Material material;
uniform Light light;
uniform vec3 viewPos;


void main()
{
	//Phong
	//ambient
	vec3 ambientLight = light.ambientColor * material.ambient;

	//diffuse
	vec3 Normal = normalize(normal);
	vec3 lightDirection = normalize(light.lightPos - FragPos);
	float diffuseStrength = max(dot(Normal,lightDirection),0.0);
	vec3 diffuseLight = light.diffuseColor * (diffuseStrength * material.diffuse);

	//specular
	vec3 viewDirection = normalize(viewPos - FragPos);
	vec3 reflectDirection = reflect(-lightDirection,Normal);
	reflectDirection = normalize(reflectDirection);
	float spec = pow(max(dot(viewDirection,reflectDirection),0.0),material.shininess);
	vec3 specularLight = light.specularColor * (spec * material.specular);
	
	vec3 colors = ambientLight + diffuseLight + specularLight;

	FragColor = vec4(colors,1.0f);
}