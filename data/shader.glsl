#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset; //offsets to apply to move by one pixel

varying vec4 vertColor;
varying vec4 vertTexCoord;

#define PI 3.1415926f

uniform sampler2D blurred;
uniform float t, mvaLower, mvaHigher;
uniform float amplitudeMultX, amplitudeMultY;


vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void main(void)
{
  vec4 outColor = texture(blurred, vec2(vertTexCoord.x, 1 - vertTexCoord.y));
  
  for(int iHueLevel = 0; iHueLevel < 5; iHueLevel++)
  {
    float distortDir = t + iHueLevel / 10.0f * PI;
    
    vec2 distort;
    distort.x = cos(distortDir) * mvaHigher;
    distort.y = sin(distortDir) * mvaLower;
    
    distort.x *= amplitudeMultX;
    distort.y *= amplitudeMultY;
    
    vec4 blurredColorAtDest = texture(blurred, vec2(vertTexCoord.x, 1 - vertTexCoord.y) + texOffset.xy * distort);
    
    float hue = rgb2hsv(blurredColorAtDest.xyz).x;
    int hueLevel = int(floor(hue * 5)); //0...5
    
    if(hueLevel == iHueLevel)
        outColor = texture(texture, vec2(vertTexCoord.xy + texOffset.xy * distort));
    //color c = img.get(x, y); //color(hueLevel / 5.0f * 255);
  }
  
  gl_FragColor = vec4(outColor.rgb, 1.0) * vertColor;
}