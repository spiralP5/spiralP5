// Spiral Project
// The second verison of Sprial code using GLGraphics
// Now, it's full 3D environment
// code is based on particle system example from GLGraphics library
// 02/09/2013 by James Lee


import processing.opengl.*;
import codeanticode.glgraphics.*;
import java.nio.FloatBuffer;

GLTexture blurTex;
GLGraphicsOffScreen offcanvas;
GLTextureFilter spiral_blur;

//Spiral sp;
ArrayList spirals;

float angle;
float angleX = 0.0;
float angleY = 0.0;

// these are spiral control variables
// it is global for now however, each spiral object may have its own set later
float k = 0.1;
float t = 2;
float thick = 1.0;    // how wide the sprial cone angle

int nPoints = 1000;
int pointVar = 1000;

void setup() {
  
  // set canvas size
  size(640, 640, GLConstants.GLGRAPHICS);
  
  // create offscreen buffer
  offcanvas = new GLGraphicsOffScreen(this, width, height, true, 4);
  offcanvas.setDepthMask(false);
  
  // intermediate blurred image storage
  blurTex = new GLTexture(this, width, height, GLTexture.FLOAT);
  
  // blur filter: post-processing on offscreen buffer
  spiral_blur = new GLTextureFilter(this, "spiral_blur.xml");
  
  // create spiral object: just test one for now
  spirals = new ArrayList();
  for (int i=0; i<3; i++) {
    Spiral sp = new Spiral(this, offcanvas, nPoints);
    sp.setOrientation(0, i*PI*2.0/3.0, 0);
    spirals.add(sp);
  }
  
}

void draw() {
  
  // begin offscreen buffer stuff
  beginOffDrawing();
  
  // draw spirals
  //sp.drawSpiral();
  for (int i=0; i<spirals.size(); i++) {
    Spiral sp = (Spiral) spirals.get(i);
    sp.drawSpiral();
  }
  
  // end offscreen buffer
  endOffDrawing();
  
  // frame rate
  text("fps: " + nfc(frameRate, 2), 20, 20);

}

// key function to control rotation values (x & y axis)
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angleX += 0.02;
    } else if (keyCode == DOWN) {
      angleX -= 0.02;
    } else if (keyCode == LEFT) {
      angleY += 0.02;
    } else if (keyCode == RIGHT) {
      angleY -= 0.02;
    } 
  } else if (key == ENTER || key == RETURN) {
    angleX = angleY = 0.0;
  } else if (key == '-') {
    thick = min(thick+0.1, 10.0);
    println("thick: " + thick);
  } else if (key == '=') {
    thick = max(thick-0.1, 0.1);
    println("thick: " + thick);
  }
}


void beginOffDrawing() {

  // begin offscreen buffer
  offcanvas.beginDraw();
  offcanvas.beginGL();
  
  // blur previous framebuffer
  offcanvas.getTexture().filter(spiral_blur, blurTex);
  
  // clear offscreen buffer
  offcanvas.background(0);
  
  // draw blurred image back onto buffer
  offcanvas.image(blurTex, 0, 0, width*2, height*2);

  // translation to the center
  offcanvas.translate(width/2, height/2, 0);
  
  // rotation along X, Y axis: controlled by user or external inputs  
  offcanvas.rotateX(angleX);
  offcanvas.rotateY(angleY);
  
  
}

void endOffDrawing() {
  // end offscreen drawing
  offcanvas.endGL();
  offcanvas.endDraw();  
  
  // draw offscreen canvas to framebuffer
  image(offcanvas.getTexture(), 0, 0, width, height);  
  
}


