import processing.core.*; 
import processing.xml.*; 

import processing.opengl.*; 
import codeanticode.glgraphics.*; 
import java.nio.FloatBuffer; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class spiral_GL_a3 extends PApplet {

// SpiralP5 ReCode Project
// The second verison of Sprial code using GLGraphics
// Now, it's full 3D environment
// code is based on particle system example from GLGraphics library
//
// App written in Processing 1.5.1 with GLGraphics lib 1.0.0
//
// 02/09/2013 by James Lee (james0709@gmail.com)






// intermediate blur texture
GLTexture blurTex;

// off-screen canvas
GLGraphicsOffScreen offcanvas;

// spiral blur filter (post-processing shader)
GLTextureFilter spiral_blur;

// Spiral Object Array
ArrayList spirals;

// Number of Spiral Objects
int nSpirals = 20;

// Scene Orientation Variables
float angleX = 0.0f;
float angleY = 0.0f;

// these are spiral control variables
// it is global for now however, each spiral object may have its own set later
float k = 0.1f;
float t = 2;
float thick = 1.0f;    // how wide the sprial cone angle

int nPoints = 1000;
int pointVar = 1000;

public void setup() {
  
  // set canvas size
  size(1024, 1024, GLConstants.GLGRAPHICS);
  
  // create offscreen buffer for blur effect
  offcanvas = new GLGraphicsOffScreen(this, width, height, true, 4);
  offcanvas.setDepthMask(false);
  
  // intermediate blurred image storage
  blurTex = new GLTexture(this, width, height, GLTexture.FLOAT);
  
  // blur filter: post-processing on offscreen buffer
  spiral_blur = new GLTextureFilter(this, "spiral_blur.xml");
  
  // create spiral objects 
  spirals = new ArrayList();
  float angleShift = 2.0f * PI / nSpirals;
  for (int i=0; i<nSpirals; i++) {
    Spiral sp = new Spiral(this, offcanvas, nPoints);
    sp.setOrientation(0, i*angleShift, 0);
    spirals.add(sp);
  }
  
}

public void draw() {
  
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

// key function to control rotation values (x & y axis)
public void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angleX += 0.02f;
    } else if (keyCode == DOWN) {
      angleX -= 0.02f;
    } else if (keyCode == LEFT) {
      angleY += 0.02f;
    } else if (keyCode == RIGHT) {
      angleY -= 0.02f;
    } 
  } else if (key == ENTER || key == RETURN) {
    angleX = angleY = 0.0f;
  } else if (key == '-') {
    thick = min(thick+0.1f, 10.0f);
    //println("thick: " + thick);
  } else if (key == '=') {
    thick = max(thick-0.1f, 0.1f);
    //println("thick: " + thick);
  }
}


public void beginOffDrawing() {

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

public void endOffDrawing() {

  // end offscreen drawing
  offcanvas.endGL();
  offcanvas.endDraw();  
  
  // draw offscreen canvas to framebuffer
  image(offcanvas.getTexture(), 0, 0, width, height);  
  
}


// Spiral Class

class Spiral {
  
  PApplet _parent;
  PVector _pos;
  PVector _ori;
  GLGraphicsOffScreen _canvas;
  GLModel _spiral;
  int _nPoints;
  
  Spiral(PApplet parent, GLGraphicsOffScreen off, int np) {
    _pos = new PVector(0,0,0);
    _ori = new PVector(0,0,0);
    _parent = parent;
    _canvas = off;
    _nPoints = np;
    initSpiral();
  }
  
  public void initSpiral() {
    // new spiral model
    _spiral = new GLModel(_parent, _nPoints, GLModel.POINT_SPRITES, GLModel.DYNAMIC);
    
    // point size
    float pmax = _spiral.getMaxPointSize();
    _spiral.setMaxSpriteSize(pmax*0.9f);
    _spiral.setSpriteSize(20, 400);
    
    // color for later... some aux effect from various inputs
    //spiral.initColors();
    //spiral.setColors(1, 1);
    
    // iniital position
    _spiral.beginUpdateVertices();
    FloatBuffer vbuf = _spiral.vertices;
    float pos[] = { 0, 0, 0, 0 };
    for (int n = 0; n < _spiral.getSize(); n++) {
      vbuf.position(4 * n);
      vbuf.get(pos, 0, 3);  
      
      pos[0] = n;
      pos[1] = 0;
      pos[2] = -n*5.0f;
      pos[3] = 1;           // The W coordinate must be 1.
      
      vbuf.position(4 * n);
      vbuf.put(pos, 0, 4);
    }  
    _spiral.endUpdateVertices();  
    
  
    // texture
    GLTexture tx = new GLTexture(_parent, "particle.png");
    _spiral.initTextures(1);
    _spiral.setTexture(0, tx);
    _spiral.setBlendMode(BLEND);
      
  }
  
  
  public void updateSpiral() {
    
    // update spiral's vertices
    _spiral.beginUpdateVertices();
    FloatBuffer vbuf = _spiral.vertices;
    float pos[] = { 0, 0, 0 };
    
    // loop all vertices
    for (int n = 0; n < _spiral.getSize(); n++) {
      
      vbuf.position(4 * n);
      vbuf.get(pos, 0, 3);  
      
      // spiral position update...
      float th = n * (3600.0f / pointVar);
      float R = k * th;
      pos[0] = R * sin(th);    // x
      pos[1] = R * cos(th);    // y
      //pos[2] = R;              // z
      pos[2] = R * thick;
      
      vbuf.position(4 * n);
      vbuf.put(pos, 0, 3);
    }
    
    // rewide buffer and update vertices
    vbuf.rewind();
    _spiral.endUpdateVertices();  
    
    pointVar = mouseX; //96 straight line spiral
    //k = mouseY / 1000.0;
    t = mouseY;
    if( pointVar <= 0 )
      pointVar = 1;
      
    if( t <= 0 )
      t = 1;

  }
  
  public void drawSpiral() {
    
    updateSpiral();
    
    // this transform part needs some work!!!
    _canvas.pushMatrix();
    _canvas.rotateX(_ori.x);
    _canvas.rotateY(_ori.y);
    //_canvas.rotateZ(_ori.z);
    
    _canvas.pushMatrix();
    
    // rotation for spiral effect along Z-axis
    _canvas.rotate(millis() / t );
    _canvas.model(_spiral);
    _canvas.popMatrix();
    
    _canvas.popMatrix();
  }
  
  
  public void setPosition(float x, float y, float z) {
    _pos.x = x;
    _pos.y = y;
    _pos.z = z;
  }
  
  public void setOrientation(float x, float y, float z) {
    _ori.x = x;
    _ori.y = y;
    _ori.z = z;
  }
  
}


  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--stop-color=#cccccc", "spiral_GL_a3" });
  }
}
