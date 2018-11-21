struct Transform
{
	uniform mat4 u_projectionMatrix;
	uniform mat4 u_viewMatrix;
	uniform mat4 u_modelMatrix;
};

struct Entity
{
	attribute vec3 a_position;
	attribute vec3 a_normal;
	attribute vec3 a_tangent;
	attribute vec2 a_uv;
	attribute vec2 a_secondaryUV;
};

varying vec3 sgl_eye;