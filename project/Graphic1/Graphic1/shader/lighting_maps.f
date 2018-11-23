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
struct PointLight
{
	vec3 position;
	//phongLightColor;
	vec3 ambient;
	vec3 diffuse;
	vec3 specular;

	float constant;
    float linear;
    float quadratic;
};

struct DirectionLight
{
	vec3 direction;
	vec3 ambient;
	vec3 diffuse;
	vec3 specular;
};

struct SpotLight
{
	vec3 position;
	vec3 spotDirection;
	float cutOff;
	float outerCutOff;

	vec3 ambient;
	vec3 diffuse;
	vec3 specular;

	float constant;
	float linear;
	float quadratic;
};

uniform Material material;
uniform PointLight pointLight;
uniform vec3 viewPos;
uniform DirectionLight directionLight;
uniform SpotLight spotLight;

vec3 Normal = normalize(normal);
vec3 viewDirection = normalize(viewPos - FragPos);

vec3 setSpotLight()
{
	float distance = length(spotLight.position - FragPos);
	float attenuation = 1.0 / (spotLight.constant + spotLight.linear * distance + spotLight.quadratic * distance * distance);

	//默认光源的方向是指向光源位置
	vec3 lightDirection = normalize(spotLight.position - FragPos);
	//默认光源的方向是指向光源位置,在计算过程中光源方向会取反，所以聚焦方向也要取反，进行点乘dot计算
	vec3 spotDirection = normalize(-spotLight.spotDirection);
	float theta = dot(lightDirection,spotDirection);
	if(theta > spotLight.cutOff)
	{
		//phong
		//ambient
		vec3 ambientLight = spotLight.ambient * texture(material.diffuse,TexCoord).rgb;
		//diffuse
		float diffuseStrength = max(dot(Normal,lightDirection),0.0f);
		vec3 diffuseLight = spotLight.diffuse * diffuseStrength * texture(material.diffuse,TexCoord).rgb;
		//specular
		vec3 reflectDirection = reflect(-lightDirection,Normal);
		float specularStrength = pow(max(dot(reflectDirection,viewDirection),0.0f),material.shininess);
		vec3 specularLight = spotLight.specular * specularStrength * texture(material.specular,TexCoord).rgb;

		vec3 light = (ambientLight + diffuseLight + specularLight) * attenuation;
		return light;
	}
	return spotLight.ambient * texture(material.diffuse,TexCoord).rgb;
}

vec3 setSpotLightSoftEdges()
{
	float distance = length(spotLight.position - FragPos);
	float attenuation = 1.0 / (spotLight.constant + spotLight.linear * distance + spotLight.quadratic * distance * distance);

	//默认光源的方向是指向光源位置
	vec3 lightDirection = normalize(spotLight.position - FragPos);
	//默认光源的方向是指向光源位置,在计算过程中光源方向会取反，所以聚焦方向也要取反，进行点乘dot计算
	vec3 spotDirection = normalize(-spotLight.spotDirection);

	//phong
	//ambient
	vec3 ambientLight = spotLight.ambient * texture(material.diffuse,TexCoord).rgb;
	//diffuse
	float diffuseStrength = max(dot(Normal,lightDirection),0.0f);
	vec3 diffuseLight = spotLight.diffuse * diffuseStrength * texture(material.diffuse,TexCoord).rgb;
	//specular
	vec3 reflectDirection = reflect(-lightDirection,Normal);
	float specularStrength = pow(max(dot(reflectDirection,viewDirection),0.0f),material.shininess);
	vec3 specularLight = spotLight.specular * specularStrength * texture(material.specular,TexCoord).rgb;

	//soft edges
	float theta = dot(lightDirection,spotDirection); 
	float epsilon = spotLight.cutOff - spotLight.outerCutOff;
	float intensity = clamp((theta - spotLight.outerCutOff)/epsilon,0.0f,1.0f);

	diffuseLight *= intensity;
	specularLight *= intensity;

	vec3 light = (ambientLight + diffuseLight + specularLight) * attenuation;
	return light;
	
}

vec3 setPointLight()
{
	//phong
	//PointLight
	float distance    = length(pointLight.position - FragPos);
	float attenuation = 1.0 / (pointLight.constant + pointLight.linear * distance + pointLight.quadratic * (distance * distance));
	//ambient
	vec3 pointAmbientLight = pointLight.ambient * vec3(texture(material.diffuse,TexCoord));

	//diffuse
	vec3 lightDirection = normalize(pointLight.position - FragPos);
	float diffuseStrength = max(dot(lightDirection,Normal),0.0f);
	vec3 pointDiffuseLight = pointLight.diffuse * diffuseStrength * vec3(texture(material.diffuse,TexCoord));

	//specular
	vec3 reflectDirection = reflect(-lightDirection,Normal);
	float specularStrength = pow(max(dot(viewDirection,reflectDirection),0.0f),material.shininess);
	vec3 pointSpecularLight = pointLight.specular * specularStrength * texture(material.specular,TexCoord).rgb;

	vec3 pointLight = (pointAmbientLight + pointDiffuseLight + pointSpecularLight) * attenuation;

	return pointLight;
}

vec3 setDirectionLight()
{
	//phong
	//DirectionLight
	//direction
	vec3 lightDirection = normalize(-directionLight.direction);

	//ambient
	vec3 directionAmbientLight = directionLight.ambient * vec3(texture(material.diffuse,TexCoord));

	//diffuse
	float diffuseStrength = max(dot(lightDirection,Normal),0.0f);
	vec3 directionDiffuseLight = directionLight.diffuse * diffuseStrength * vec3(texture(material.diffuse,TexCoord));

	//specular
	vec3 reflectDirection = reflect(-lightDirection,Normal);
	float specularStrength = pow(max(dot(viewDirection,reflectDirection),0.0f),material.shininess);
	vec3 directionSpecularLight = directionLight.specular * specularStrength * texture(material.specular,TexCoord).rgb;

	vec3 directionLight = directionAmbientLight + directionDiffuseLight + directionSpecularLight;

	return directionLight;

}

void main()
{
	
	vec3 pointLight = setPointLight();
	
	vec3 directionLight = setDirectionLight();

	vec3 spotLight = setSpotLightSoftEdges();

	//DirectionLight

	vec3 Light = pointLight + directionLight + spotLight;


	FragColor = vec4(spotLight,1.0f);
}

