#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform mat3 normalMat;

out vec3 FragPos;
out vec3 normal;


void main()
{
	FragPos = vec3(model * vec4(aPos,1.0f));
	//normal = vec3(model * vec4(aNormal,0.0f));
	normal = normalMat*aNormal;
	//normal = mat3(transpose(inverse(model))) * aNormal;
	gl_Position = projection * view * model * vec4(aPos,1.0);
}