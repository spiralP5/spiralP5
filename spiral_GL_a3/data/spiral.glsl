// simple modification from processing blur shader
// use some color manipulation and decay
// initial mod by James Lee

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D textureSampler;
uniform vec2 texcoordOffset;

//varying vec4 vertColor;
//varying vec4 vertTexcoord;

#define KERNEL_SIZE 9

// Gaussian kernel
// 1 2 1
// 2 4 2
// 1 2 1
float kernel[KERNEL_SIZE];

vec2 offset[KERNEL_SIZE];

void main(void) {
  int i = 0;
  vec4 sum = vec4(0.0);

  vec2 vertTexcoord = gl_TexCoord[0].st;
  
  offset[0] = vec2(-texcoordOffset.s, -texcoordOffset.t);
  offset[1] = vec2(0.0, -texcoordOffset.t);
  offset[2] = vec2(texcoordOffset.s, -texcoordOffset.t);

  offset[3] = vec2(-texcoordOffset.s, 0.0);
  offset[4] = vec2(0.0, 0.0);
  offset[5] = vec2(texcoordOffset.s, 0.0);

  offset[6] = vec2(-texcoordOffset.s, texcoordOffset.t);
  offset[7] = vec2(0.0, texcoordOffset.t);
  offset[8] = vec2(texcoordOffset.s, texcoordOffset.t);

  kernel[0] = 1.0/16.0;   kernel[1] = 2.0/16.0;   kernel[2] = 1.0/16.0;
  kernel[3] = 2.0/16.0;   kernel[4] = 4.0/16.0;   kernel[5] = 2.0/16.0;
  kernel[6] = 1.0/16.0;   kernel[7] = 2.0/16.0;   kernel[8] = 1.0/16.0;

  for(i = 0; i < KERNEL_SIZE; i++) {
    vec4 tmp = texture2D(textureSampler, vertTexcoord.st + offset[i]);
    sum += tmp * kernel[i];
  }

  // manipulate colors a bit: this is very experimental
  // compute luma
  float luma = 0.33*sum.r + 0.5*sum.g + 0.16*sum.b;
  
  // color shift 
  sum.b = sum.b * luma * 1.1;
  sum.r = sum.r * luma * 1.5;
  
  //gl_FragColor = vec4(sum.rgb, 1.0) * vertColor;
  
  // multiply decay constant (< 1.0) to diminish colors
  // the smaller value used, the faster it goes away
  //gl_FragColor = vec4(sum.rgb, 1.0) * vertColor * 0.985;
  gl_FragColor = vec4(sum.rgb, 1.0) * 0.98;
  
}
