//#include <glad/glad.h>
//#include <GLFW/glfw3.h>
//#include <stb_image.h>
//
//#include <glm/glm.hpp>
//#include <glm/gtc/matrix_transform.hpp>
//#include <glm/gtc/type_ptr.hpp>
//
//#include <shader_s.h>
//#include <camera.h>
//
//#include <iostream>
//
//void framebuffer_size_callback(GLFWwindow* window, int width, int height);
//void processInput(GLFWwindow *window);
//void mouse_callback(GLFWwindow *window, double xpos, double ypos);
//void scroll_callback(GLFWwindow *window, double xoffset, double yoffset);
//
//// settings
//const unsigned int SCR_WIDTH = 800;
//const unsigned int SCR_HEIGHT = 600;
//
//glm::vec3 cameraPos = glm::vec3(0.0f, 0.0f, 3.0f);
//glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);
//glm::vec3 cameraUp = glm::vec3(0.0f, 1.0f, 0.0f);
//
//Camera camera(cameraPos);
//
//float deltaTime = 0.0f; // 当前帧与上一帧的时间差
//float lastFrame = 0.0f; // 上一帧的时间
//
//float lastX = SCR_WIDTH * 0.5;
//float lastY = SCR_HEIGHT * 0.5;
//
//float yaw = 0;
//float pitch = 0;
//
//bool firstMouse = true;
//
//float fov = 45.0f;
//
//int main()
//{
//	// glfw: initialize and configure
//	// ------------------------------
//	glfwInit();
//	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
//	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
//	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
//
//#ifdef __APPLE__
//	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // uncomment this statement to fix compilation on OS X
//#endif
//
//	// glfw window creation
//	// --------------------
//	GLFWwindow* window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", NULL, NULL);
//	if (window == NULL)
//	{
//		std::cout << "Failed to create GLFW window" << std::endl;
//		glfwTerminate();
//		return -1;
//	}
//	glfwMakeContextCurrent(window);
//	glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
//	glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
//	glfwSetCursorPosCallback(window, mouse_callback);
//	glfwSetScrollCallback(window, scroll_callback);
//
//	// glad: load all OpenGL function pointers
//	// ---------------------------------------
//	if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
//	{
//		std::cout << "Failed to initialize GLAD" << std::endl;
//		return -1;
//	}
//
//	Shader ourShader("shader/coordinate_system.vs", "shader/coordinate_system.f");
//
//	//float vertices[] = {
//	//	// positions          // texture coords
//	//	0.5f,  0.5f, 0.0f,   1.0f, 1.0f, // top right
//	//	0.5f, -0.5f, 0.0f,   1.0f, 0.0f, // bottom right
//	//	-0.5f, -0.5f, 0.0f,   0.0f, 0.0f, // bottom left
//	//	-0.5f,  0.5f, 0.0f,   0.0f, 1.0f  // top left 
//	//};
//	float vertices[] = {
//		-0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
//		0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
//		0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//		0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//		-0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
//		-0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
//
//		-0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//		0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
//		0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
//		0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
//		-0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
//		-0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//
//		-0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//		-0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//		-0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//		-0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//		-0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//		-0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//
//		0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//		0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//		0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//		0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//		0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//		0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//
//		-0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//		0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
//		0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
//		0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
//		-0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
//		-0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
//
//		-0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
//		0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
//		0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//		0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
//		-0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
//		-0.5f,  0.5f, -0.5f,  0.0f, 1.0f
//	};
//
//
//	unsigned int indices[] = {
//		0, 1, 3, // first triangle
//		1, 2, 3  // second triangle
//	};
//
//	unsigned int VBO, VAO, EBO;
//	glGenVertexArrays(1, &VAO);
//	glGenBuffers(1, &VBO);
//	glGenBuffers(1, &EBO);
//
//	glBindVertexArray(VAO);
//	glBindBuffer(GL_ARRAY_BUFFER, VBO);
//	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
//
//	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
//	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
//
//	//position attribute
//	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
//	glEnableVertexAttribArray(0);
//	// texture coord attribute
//	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
//	glEnableVertexAttribArray(1);
//
//	unsigned int texture1, texture2;
//
//	glGenTextures(1,&texture1);
//	glBindTexture(GL_TEXTURE_2D, texture1);
//
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	// set texture wrapping to GL_REPEAT (default wrapping method)
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
//	// set texture filtering parameters
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//	// load image, create texture and generate mipmaps
//	int width, height, nrChannels;
//	//stbi_set_flip_vertically_on_load(true);
//	// The FileSystem::getPath(...) is part of the GitHub repository so we can find files on any IDE/platform; replace it with your own image path.
//	unsigned char *data = stbi_load("resources/textures/container.jpg", &width, &height, &nrChannels, 0);
//	if (data)
//	{
//		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
//		glGenerateMipmap(GL_TEXTURE_2D);
//	}
//	else
//	{
//		std::cout << "Failed to load texture" << std::endl;
//	}
//	stbi_image_free(data);
//
//	glGenTextures(1, &texture2);
//	glBindTexture(GL_TEXTURE_2D, texture2);
//
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	// set texture wrapping to GL_REPEAT (default wrapping method)
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
//	// set texture filtering parameters
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//
//	data = stbi_load("resources/textures/awesomeface.png", &width, &height, &nrChannels, 0);
//	if (data)
//	{
//		// note that the awesomeface.png has transparency and thus an alpha channel, so make sure to tell OpenGL the data type is of GL_RGBA
//		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
//		glGenerateMipmap(GL_TEXTURE_2D);
//	}
//	else
//	{
//		std::cout << "Failed to load texture" << std::endl;
//	}
//	stbi_image_free(data);
//
//	//glm::mat4 view(1.0f);
//	glm::mat4 projection(1.0f);
//	//projection = glm::perspective(glm::radians(45.0f), (float)SCR_WIDTH / (float)SCR_HEIGHT, 0.1f, 100.0f);
//
//	ourShader.use();
//	ourShader.setInt("texture1", 0);
//	ourShader.setInt("texture2", 1);
//	//ourShader.setMat4("projection", projection);
//	glEnable(GL_DEPTH_TEST);
//	//render loop
//	while (!glfwWindowShouldClose(window))
//	{
//		processInput(window);
//
//		glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
//		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//
//		//bind textures on corresponding texture units
//		glActiveTexture(GL_TEXTURE0);
//		glBindTexture(GL_TEXTURE_2D, texture1);
//		glActiveTexture(GL_TEXTURE1);
//		glBindTexture(GL_TEXTURE_2D, texture2);
//
//		ourShader.use();
//
//		glm::vec3 cubePositions[] = {
//			glm::vec3(0.0f,  0.0f,  0.0f),
//			glm::vec3(2.0f,  5.0f, -15.0f),
//			glm::vec3(-1.5f, -2.2f, -2.5f),
//			glm::vec3(-3.8f, -2.0f, -12.3f),
//			glm::vec3(2.4f, -0.4f, -3.5f),
//			glm::vec3(-1.7f,  3.0f, -7.5f),
//			glm::vec3(1.3f, -2.0f, -2.5f),
//			glm::vec3(1.5f,  2.0f, -2.5f),
//			glm::vec3(1.5f,  0.2f, -1.5f),
//			glm::vec3(-1.3f,  1.0f, -1.5f)
//		};
//
//		//glm::mat4 model(1.0f);
//		//glm::mat4 view(1.0f);
//		//glm::mat4 projection(1.0f);
//		//model = glm::rotate(model, (float)glfwGetTime() * glm::radians(50.0f), glm::vec3(0.5f, 1.0f, 0.0f));
//		//普通view矩阵
//		//view = glm::translate(view, glm::vec3(0.0f, 0.0f, -3.0f));
//		//lookat矩阵
//		/*view = glm::lookAt(glm::vec3(0.0f,0.0f,3.0f),
//							glm::vec3(0.0f,0.0f,0.0f),
//							glm::vec3(0.0f,1.0f,0.0f));*/
//		//旋转lookat矩阵
//		/*float radius = 10.0f;
//		float camX = sin(glfwGetTime()) * radius;
//		float camZ = cos(glfwGetTime()) * radius;
//		view = glm::lookAt(glm::vec3(camX, 0.0f, camZ),
//			glm::vec3(0.0f, 0.0f, 0.0f),
//			glm::vec3(0.0f, 1.0f, 0.0f));*/
//		//移动lookat摄像头
//		/*glm::vec3 cameraPos = glm::vec3(0.0f, 0.0f, 3.0f);
//		glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);
//		glm::vec3 cameraUp = glm::vec3(0.0f, 1.0f, 0.0f);*/
//
//		//view = glm::lookAt(cameraPos, cameraPos + cameraFront, cameraUp);
//
//		projection = glm::perspective(glm::radians(camera.Zoom), (float)SCR_WIDTH / (float)SCR_HEIGHT, 0.1f, 100.0f);
//		// retrieve the matrix uniform locations
//		//unsigned int modelLoc = glGetUniformLocation(ourShader.ID, "model");
//		//unsigned int viewLoc = glGetUniformLocation(ourShader.ID, "view");
//		// pass them to the shaders (3 different ways)
//		//glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));
//		//glUniformMatrix4fv(viewLoc, 1, GL_FALSE, &view[0][0]);
//		// note: currently we set the projection matrix each frame, but since the projection matrix rarely changes it's often best practice to set it outside the main loop only once.
//		ourShader.setMat4("projection", projection);
//		ourShader.setMat4("view", camera.GetViewMatrix());
//		glBindVertexArray(VAO);
//		/*for (unsigned int i = 0; i < 10; ++i)
//		{
//			glm::mat4 model(1.0f);
//			model = glm::translate(model, cubePositions[i]);
//			model = glm::rotate(model, (float)glfwGetTime() * glm::radians(50.0f), glm::vec3(0.5f, 1.0f, 0.0f));
//			ourShader.setMat4("model", model);
//			glDrawArrays(GL_TRIANGLES, 0, 36);
//		}*/
//		for (unsigned int i = 0; i < 10; i++)
//		{
//			// calculate the model matrix for each object and pass it to shader before drawing
//			glm::mat4 model(1.0f);
//			model = glm::translate(model, cubePositions[i]);
//			float angle = 20.0f * i;
//			if (i % 3 == 0)  // every 3rd iteration (including the first) we set the angle using GLFW's time function.
//				angle = glfwGetTime() * 25.0f;
//			model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));
//			ourShader.setMat4("model", model);
//
//			glDrawArrays(GL_TRIANGLES, 0, 36);
//		}
//		//glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
//		
//
//		glfwSwapBuffers(window);
//		glfwPollEvents();
//	}
//	// optional: de-allocate all resources once they've outlived their purpose:
//	// ------------------------------------------------------------------------
//	glDeleteVertexArrays(1, &VAO);
//	glDeleteBuffers(1, &VBO);
//	glDeleteBuffers(1, &EBO);
//
//	// glfw: terminate, clearing all previously allocated GLFW resources.
//	// ------------------------------------------------------------------
//	glfwTerminate();
//	return 0;
//}
//
//// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
//// ---------------------------------------------------------------------------------------------------------
//void processInput(GLFWwindow *window)
//{
//	float currentTime = glfwGetTime();
//	deltaTime = currentTime - lastFrame;
//	lastFrame = currentTime;
//	if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
//		glfwSetWindowShouldClose(window, true);
//	//float cameraSpeed = 2.5f * deltaTime;
//	if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
//	{
//		//cameraPos += cameraSpeed * cameraFront;
//		camera.ProcessKeyboard(FORWARD, deltaTime);
//	}
//	if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
//	{
//		//cameraPos -= cameraSpeed * cameraFront;
//		camera.ProcessKeyboard(BACKWARD, deltaTime);
//	}
//	if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
//	{
//		//cameraPos -= cameraSpeed*glm::normalize(glm::cross(cameraFront, cameraUp));
//		camera.ProcessKeyboard(LEFT, deltaTime);
//	}
//	if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
//	{
//		//cameraPos += cameraSpeed*glm::normalize(glm::cross(cameraFront, cameraUp));
//		camera.ProcessKeyboard(RIGHT, deltaTime);
//	}
//}
//
//// glfw: whenever the window size changed (by OS or user resize) this callback function executes
//// ---------------------------------------------------------------------------------------------
//void framebuffer_size_callback(GLFWwindow* window, int width, int height)
//{
//	// make sure the viewport matches the new window dimensions; note that width and 
//	// height will be significantly larger than specified on retina displays.
//	glViewport(0, 0, width, height);
//}
//
//void mouse_callback(GLFWwindow *window, double xpos, double ypos)
//{
//	if (firstMouse)
//	{
//		lastX = xpos;
//		lastY = ypos;
//		firstMouse = false;
//	}
//	float xoffset = xpos - lastX;
//	float yoffset = lastY - ypos;
//
//	lastX = xpos;
//	lastY = ypos;
//
//	camera.ProcessMouseMovement(xoffset, yoffset);
//
//	//float sensitivity = 0.05f;
//
//	//xoffset *= sensitivity;
//	//yoffset *= sensitivity;
//
//	/*yaw += xoffset;
//	pitch += yoffset;
//
//	if (pitch > 89.0f)
//	{
//		pitch = 89.0f;
//	}
//	else if (pitch < -89.0f)
//	{
//		pitch = -89.0f;
//	}
//
//	glm::vec3 front;
//	front.x = cos(glm::radians(pitch)) * cos(glm::radians(yaw));
//	front.y = sin(glm::radians(pitch));
//	front.z = cos(glm::radians(pitch)) * sin(glm::radians(yaw));
//
//	cameraFront = glm::normalize(front);*/
//
//}
//
//void scroll_callback(GLFWwindow *window, double xoffset, double yoffset)
//{
//	camera.ProcessMouseScroll(yoffset);
//	////if (fov >= 1.0f && fov <= 45.0f)
//	////{
//	//	fov -= yoffset;
//	////}
//	//if (fov < 1.0f)
//	//{
//	//	fov = 1.0f;
//	//}
//	//else if(fov > 45.0f)
//	//{
//	//	fov = 45.0f;
//	//}
//}