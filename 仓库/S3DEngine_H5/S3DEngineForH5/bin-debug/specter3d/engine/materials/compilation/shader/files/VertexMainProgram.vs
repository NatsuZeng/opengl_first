#ifdef FSHIGHPRECISION
	precision highp float;
#else
	precision mediump float;
#endif

attribute vec3 a_Position;
uniform mat4 u_projectionMatrix;
uniform mat4 u_viewMatrix;
uniform mat4 u_modelMatrix;
varying vec3 v_eye;

#ifdef USE_UV
	attribute vec2 a_UV;
	varying vec2 v_UV;
#endif

#ifdef USE_NORMAL
	attribute vec3 a_Normal;
	varying vec3 v_Normal;
#endif

#ifdef USER_LIGHT_POINT
	varying vec3 out_fragpos;
#endif

void main()
{
	 vec4 vertex = u_viewMatrix * u_modelMatrix * vec4(a_Position, 1.0);
	 v_eye = -vec3(vertex);
	 gl_Position = u_projectionMatrix * vertex;
	 #ifdef USE_NORMAL
	 	v_Normal =  mat3(u_modelMatrix) * a_Normal;
	 #endif
	 #ifdef USE_UV
	 	v_UV = a_UV;
	 #endif
	 #ifdef USER_LIGHT_POINT
		out_fragpos = vec3(u_modelMatrix * vec4(a_Position, 1));
	#endif
}