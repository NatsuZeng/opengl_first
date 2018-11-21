#version 330 core

out vec4 FragColor;

in vec3 FragPos;
in vec3 normal;
in vec2 TexCoord;

struct Material
{
	//phongObjectColor
	//移除了环境光材质颜色向量，因为环境光颜色在几乎所有情况下都等于漫反射颜色，
	//所以我们不需要将它们分开储存
	sampler2D diffuse;
	sampler2D specular;
	float shininess;
};
struct Light
{
	vec3 position;
	//phongLightColor;
	vec3 ambient;
	vec3 diffuse;
	vec3 specular;
};

uniform Material material;
uniform Light light;
uniform vec3 viewPos;

void main()
{
	vec3 Normal = normalize(normal);

	//phong
	//ambient
	vec3 ambientLight = light.ambient * vec3(texture(material.diffuse,TexCoord));

	//diffuse
	vec3 lightDirection = normalize(light.position - FragPos);
	float diffuseStrength = max(dot(lightDirection,Normal),0.0f);
	vec3 diffuseLight = light.diffuse * diffuseStrength * vec3(texture(material.diffuse,TexCoord));

	//specular
	vec3 viewDirection = normalize(viewPos - FragPos);
	vec3 reflectDirection = reflect(-lightDirection,Normal);
	float specularStrength = pow(max(dot(viewDirection,reflectDirection),0.0f),material.shininess);
	vec3 specularLight = light.specular * specularStrength * texture(material.specular,TexCoord).rgb;

	vec3 light = ambientLight + diffuseLight + specularLight;

	FragColor = vec4(light,1.0f);
}