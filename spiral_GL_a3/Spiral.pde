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
  
  void initSpiral() {
    // new spiral model
    _spiral = new GLModel(_parent, _nPoints, GLModel.POINT_SPRITES, GLModel.DYNAMIC);
    
    // point size
    float pmax = _spiral.getMaxPointSize();
    _spiral.setMaxSpriteSize(pmax*0.9);
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
      pos[2] = -n*5.0;
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
  
  
  void updateSpiral() {
    
    // update spiral's vertices
    _spiral.beginUpdateVertices();
    FloatBuffer vbuf = _spiral.vertices;
    float pos[] = { 0, 0, 0 };
    
    // loop all vertices
    for (int n = 0; n < _spiral.getSize(); n++) {
      
      vbuf.position(4 * n);
      vbuf.get(pos, 0, 3);  
      
      // main spiral drawing algorithm
      float th = n * (3600.0 / sA);
      float R = sK * th;
      pos[0] = R * sin(th);    // x
      pos[1] = R * cos(th);    // y
      pos[2] = R * sH;         // z
      
      vbuf.position(4 * n);
      vbuf.put(pos, 0, 3);
    }
    
    // rewide buffer and update vertices
    vbuf.rewind();
    _spiral.endUpdateVertices();  

  }
  
  void drawSpiral() {
    
    updateSpiral();
    
    // this transform part needs some work!!!
    _canvas.pushMatrix();
    _canvas.rotateX(_ori.x);
    _canvas.rotateY(_ori.y);
    //_canvas.rotateZ(_ori.z);  // well don't rotate it along Z-axis
    
    _canvas.pushMatrix();
    
    // rotation for spiral effect along Z-axis
    _canvas.rotate(millis() / sT );
    
    _canvas.model(_spiral);
    _canvas.popMatrix();
    
    _canvas.popMatrix();
  }
  
  
  void setPosition(float x, float y, float z) {
    _pos.x = x;
    _pos.y = y;
    _pos.z = z;
  }
  
  void setOrientation(float x, float y, float z) {
    _ori.x = x;
    _ori.y = y;
    _ori.z = z;
  }
  
}


