//
//  main.m
//  Simulator
//
//  Created by Trevor Wilkin on 3/27/11.
//  Copyright 2011 Mind Virus. All rights reserved.
//

#include <stdlib.h>
#include <GLUT/glut.h>
#include "Lights.h"
#include "Camera.h"
#include "Grid.h"
#include "Texture.h"

using namespace Fexy;
using namespace Fexy::Math;

Camera g_Camera;
Lights g_Lights;
Grid g_Grid;
Texture g_LightTex;

int g_AnimationMode = 0;															// Default animation, changed by pressing keys 1-0
const float g_CameraDistance = 30;													// Distance camera is away from the rings
const float g_UpdateRate = 60;	// doubled this rate to increase change speed       // Update is called 60 times per second

const uint32 g_RingCount = 6; // added one additional set of rings					// Number of rings
const uint32 g_LightsPerRing[g_RingCount] = { 212, 165, 165, 121, 76, 31 };				// Each rings light count
const float g_RadiusPerRing[g_RingCount] = { 10.0f, 8.0f, 8.0f, 6.0f, 4.0f, 2.0f};		// Each rings radius in ft
const float g_HeightPerRing[g_RingCount] = { 0.0f, 2.8f, 4.0f, 8.0f, 12.0f, 16.0f};		// Each rings height off the ground in ft

// ----------------------------------------------------------------------------------------------
// This initializes the simulation and gets it ready to update and render
// ----------------------------------------------------------------------------------------------

void Init()
{
	// First create a series of rings
	for (uint32 i=0; i<g_RingCount; ++i)
	{
		g_Lights.AddRing(g_HeightPerRing[i],g_RadiusPerRing[i],g_LightsPerRing[i]);
	}
	
	// Make all lights white
	g_Lights.SetColor_15bit(31,31,31);
		
	// Load texture
	g_LightTex.Load("Light.png");
	
	// Init random
	Math::Init(0);
}

// ----------------------------------------------------------------------------------------------
// This updates the simulation, you can change colors etc
// ----------------------------------------------------------------------------------------------

void RandomColorsFunction(uint32 lightCount)
{
	// Mode one sets random lights to random colors...
	for (uint32 i=0; i<lightCount; ++i)
	{
		uint32 light = Rand(g_Lights.GetNumberOfLights());
		g_Lights.SetColor_15bit(light,Rand(31),Rand(31),Rand(31));
	}
}

void RandomRingColorFunction()
{
	// Which ring?
	uint32 ring = Rand(g_RingCount);
	
	// We know the ring, how many lights in the series is that?
	uint32 lightStart = 0;
	for (uint32 i=0; i<ring; ++i)
	{
		lightStart += g_LightsPerRing[i];
	}
	
	// Set lights to random color
	uint8 r = Rand(31);
	uint8 g = Rand(31);
	uint8 b = Rand(31);
	for (uint32 i=lightStart; i<lightStart+g_LightsPerRing[ring]; ++i)
	{
		g_Lights.SetColor_15bit(i,r,g,b);
	}	
}

void RandomRingChaserFunction()
{
	static uint32 lightIndex = 0;
	static uint8 r = 31;
	static uint8 g = 31;
	static uint8 b = 31;
	
	// Gradually fill all lights with color
	g_Lights.SetColor_15bit(lightIndex, r,g,b);
	++lightIndex;
	
	// When we get past the last light, pick a new color and start again
	if (lightIndex>=g_Lights.GetNumberOfLights())
	{
		lightIndex = 0;
		r = Rand(31);
		g = Rand(31);
		b = Rand(31);
	}
}

void RainbowChaserFunction() // DAN - added this function in to chase specific colors
{
    static uint32 lightIndex = 0;
	static uint8 r = 0; //starts out by turning the lights off
	static uint8 g = 0;
	static uint8 b = 0;
    static uint32 x = 1;
    static uint32 y = 1;
    static uint32 z = 1;
    
    // Gradually fill all lights with color
	g_Lights.SetColor_15bit(lightIndex, r,g,b);
	++lightIndex;
    
    if (lightIndex>=g_Lights.GetNumberOfLights())
	{
        lightIndex=0;
        if (z==0) {
            r=31;g=31;b=31; // changes to white
            x=1;y=1;z=1;
        } else {
            if (y==0) {
                r=1;g=31;b=1; // changes to a green
                x=1;y=1;z=0;
            } else {
                if (x==0) {
                    r=31;g=1;b=31; // changes to pink
                    x=1;y=0;z=1;
                } else {
                    r=1;g=1;b=31; // changes to blue
                    x=0;y=1;z=1;
                }
            }
        }        
	}
}

void AquaColorsFunction(uint32 lightCount)
{
    uint32 a = 0;
	// Mode five sets random lights to set colors...
	for (uint32 i=0; i<lightCount; ++i)
	{
		uint32 light = Rand(g_Lights.GetNumberOfLights());
        
        if (a==0) {
            g_Lights.SetColor_15bit(light,1,1,31);
            a=1;
        } else {
            g_Lights.SetColor_15bit(light,1,15,15);
            a=0;
        }
	}
}

void FireColorsFunction(uint32 lightCount)
{
    uint32 a = 0;
	// Mode five sets random lights to set colors...
	for (uint32 i=0; i<lightCount; ++i)
	{
		uint32 light = Rand(g_Lights.GetNumberOfLights());
        
        if (a==0) {
            g_Lights.SetColor_15bit(light,30,20,0);
            a=1;
        } else {
            g_Lights.SetColor_15bit(light,15,0,0);
            a=0;
        }
	}
}


void Update()
{
	// Here is where you could change colors procedurally... I've enabled 10 different modes using keys 0-9
	switch (g_AnimationMode)
	{
		case 0:
		{
			// Mode zero does nothing...
			break;
		}
		case 1:
		{
			// Mode 1 will set 40 random lights to random colors
			RandomColorsFunction(40);
			break;
		}
		case 2:
		{
			// Mode two sets entire rings to random colors...
			RandomRingColorFunction();
			break;
		}
		case 3:
		{
			// Mode 3 gradually fills each ring with color working from one to the next
			RandomRingChaserFunction();
			break;
		}
		case 4:
		{
			// TODO! Your own effect
			RainbowChaserFunction();
            break;
		}
		case 5:
		{
			// TODO! Your own effect
			AquaColorsFunction(40);
            break;
		}
		case 6:
		{
			// TODO! Your own effect
			FireColorsFunction(10);
            break;
		}
		case 7:
		{
			// TODO! Your own effect
			break;
		}
		case 8:
		{
			// TODO! Your own effect
			break;
		}
		case 9:
		{
			// TODO! Your own effect
			break;
		}
	}
		
	// Trigger redraw
    glutPostRedisplay();
}




// ----------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------
// You can ignore everything from here on downwards...
// ----------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------

void Render()
{
	// This binds a camera (so we can see things) and triggers the light drawing
	g_Camera.Bind();
	glClearDepth(1.0f);
	glClearColor(0,0,0,0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    {
		glShadeModel(GL_SMOOTH);
		glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);
		glHint(GL_POINT_SMOOTH_HINT,GL_NICEST);
		glBlendFunc(GL_SRC_ALPHA,GL_ONE);		// GL_ONE_MINUS_SRC_ALPHA may provide better visuals
		glEnable(GL_BLEND);
		glDisable(GL_DEPTH_TEST);
		
		// Render the grid up to 12 feet away from the base
		g_Grid.Render(12);
		
		// Render the lights
		g_LightTex.Bind();
		g_Lights.Render();
		g_LightTex.Unbind();
	}
    glutSwapBuffers();
}

void Resize(int width, int height)
{
	// Called when viewport changes size
    glViewport(0, 0, width, height);
	g_Camera.Perspective(PI*0.25f,(float)width/(float)height,0.1f,100.0f);
	g_Camera.LookAt(Vector3(0,g_CameraDistance*0.75f,-g_CameraDistance),Vector3(0,6,0),Vector3::_UP);
	g_Camera.DirtyCamera();
	g_Camera.DirtyFrustum();
}

GLvoid Keyboard( GLubyte key, GLint x, GLint y )
{
    switch (key)
	{
		case '0' : { g_AnimationMode = 0; break; }
		case '1' : { g_AnimationMode = 1; break; }
		case '2' : { g_AnimationMode = 2; break; }
		case '3' : { g_AnimationMode = 3; break; }
		case '4' : { g_AnimationMode = 4; break; }
		case '5' : { g_AnimationMode = 5; break; }
		case '6' : { g_AnimationMode = 6; break; }
		case '7' : { g_AnimationMode = 7; break; }
		case '8' : { g_AnimationMode = 8; break; }
		case '9' : { g_AnimationMode = 9; break; }
    }
}

void TimedUpdate()
{
	// Do some logic to ensure fixed hz rendering/update
	static uint32 lastTime = glutGet(GLUT_ELAPSED_TIME);
	uint32 time = glutGet(GLUT_ELAPSED_TIME);
	float fDt = (time - lastTime) / 1000.0f;
	lastTime = time;
	
	static float wait = 0;
	wait -= fDt;
	if (wait<=0)
	{
		Update();
		wait += 1.0f / g_UpdateRate;
	}
}

int main(int argc, char** argv)
{
	float width = 800;
	float height = 600;
	
	// Setup GLUT and render loop
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);
    glutInitWindowSize(width, height);
	glutInitWindowPosition(40, 80);
    glutCreateWindow("Simulation");
	Resize(width,height);
	Init();
    glutDisplayFunc(Render);
    glutReshapeFunc(Resize);
    glutIdleFunc(TimedUpdate);
	glutKeyboardFunc(Keyboard);
    glutMainLoop();
	
    return EXIT_SUCCESS;
}
