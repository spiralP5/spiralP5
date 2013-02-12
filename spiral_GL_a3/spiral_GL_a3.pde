// SpiralP5 ReCode Project
// The second verison of Sprial code using GLGraphics
// Now, it's full 3D environment
// code is based on particle system example from GLGraphics library
//
// App written in Processing 1.5.1 with GLGraphics lib 1.0.0
//
// 02/09/2013
// 
// initial contributors: James Lee(james0709@gmail.com) & Arthur Nishimoto


import processing.opengl.*;
import codeanticode.glgraphics.*;
import java.nio.FloatBuffer;

// intermediate blur texture
GLTexture blurTex;

// off-screen canvas
GLGraphicsOffScreen offcanvas;

// spiral blur filter (post-processing shader)
GLTextureFilter spiral_blur;

// Spiral Object Array
ArrayList spirals;

// Number of Spiral Objects
// Tried many spirals at the same time... upto 20 spirals on my macbook pro seems working file (60fps)
int nSpirals = 1;

// number of sprite (point) for each spiral object
static int nPoints = 1000;

// Scene Orientation Variables
float angleX = 0.0;
float angleY = 0.0;

// spiral control variables: as you change these values, visualization of spiral changes
// you can play with these vars to associate with phycial inputs from various devices
// or use those to manipulate sound or something else...
// refer to Sprial::updateSpiralupdateSpiral() to see how each variable works together!
float sK = 0.1;        // this is rather constant value affecting how dense spiral is...
float sT = 2.0;        // how fast spiral rotates (smaller -> faster)
float sH = 1.0;        // how wide the sprial cone angle. (smaller -> wider) i.e 1.0 => 90 degree, 2.0 => 45 degree, 0.0 => 180 degree 
float sA = 1000.0;     // how close each consequent points. affect angle between two points. (bigger -> closer)

void setup() {

  // set canvas size
  size(1024, 1024, GLConstants.GLGRAPHICS);

  // setup spiral stuff
  setupSpirals();
}

void draw() {

  // sprial variable update
  updateSpiral();

  // begin offscreen buffer stuff
  beginOffDrawing();

  // draw spirals
  for (int i=0; i<spirals.size(); i++) {
    Spiral sp = (Spiral) spirals.get(i);
    sp.drawSpiral();
  }

  // end offscreen buffer
  endOffDrawing();

  // frame rate
  text("fps: " + nfc(frameRate, 2), 20, 20);
}

// update spiral control variables
// do what you like to do here to change spiral control vars
void updateSpiral() {

  // change sA by mouseX (how close each consequent points)
  sA = mouseX;
  if ( sA <= 0 )
    sA = 1;

  // change sT by mouseY (spiral rotation speed)
  sT = mouseY;
  if ( sT <= 0 )
    sT = 1;
}

// key function to control rotation values (x & y axis)
void keyPressed() {
  
  // rotate scene by arrow keys
  if (key == CODED) {
    if (keyCode == UP) {
      angleX += 0.02;
    } 
    else if (keyCode == DOWN) {
      angleX -= 0.02;
    } 
    else if (keyCode == LEFT) {
      angleY += 0.02;
    } 
    else if (keyCode == RIGHT) {
      angleY -= 0.02;
    }
  } 
  else if (key == ENTER || key == RETURN) {
    // reset scene orientation
    angleX = angleY = 0.0;
  }
  
  // change spiral cone angle 
  else if (key == '-') {
    sH = min(sH+0.1, 10.0);
  } 
  else if (key == '=') {
    sH = max(sH-0.1, 0.0);
  }
  
}

void setupSpirals() {

  // create offscreen buffer for blur effect
  offcanvas = new GLGraphicsOffScreen(this, width, height, true, 4);
  offcanvas.setDepthMask(false);

  // intermediate blurred image storage
  blurTex = new GLTexture(this, width, height, GLTexture.FLOAT);

  // blur filter: post-processing on offscreen buffer
  spiral_blur = new GLTextureFilter(this, "spiral_blur.xml");

  // create spiral objects: will evenly set orientation of each spiral along Y-asix
  spirals = new ArrayList();
  float angleShift = 2.0 * PI / nSpirals;
  for (int i=0; i<nSpirals; i++) {
    Spiral sp = new Spiral(this, offcanvas, nPoints);
    sp.setOrientation(0, i*angleShift, 0);
    spirals.add(sp);
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

