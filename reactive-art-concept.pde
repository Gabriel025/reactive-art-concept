import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer song;
FFT fft;

PImage img, blurred, buf;//, spectrum;
PShader shader;
float t, mvaLower, mvaHigher;


void setup()
{
  size(800, 600, P2D);
  
  minim = new Minim(this);
  song = minim.loadFile("music.mp3", 1024);
  fft = new FFT(song.bufferSize(), song.sampleRate());
  song.loop();

  img = loadImage("MUNCH.jpg");
  blurred = img.copy();
  blurred.filter(BLUR, 5);
  
  buf = createImage(img.width, img.height, RGB);

  shader = loadShader("shader.glsl");
  shader.set("blurred", blurred);
  shader.set("amplitudeMultX", 1.0f);
  shader.set("amplitudeMultY", 1.0f);
}

void draw()
{
  fft.forward(song.mix);

  //if(spectrum == null) spectrum = createImage(fft.specSize() - 200, 1, RGB); 
  //if(spectrum.width != fft.specSize() - 200)   spectrum.resize(fft.specSize() - 200, 1);

  float sumAmplitudeLower = 0, sumAmplitudeHigher = 0;
  
  for(int i = 200; i < fft.specSize(); i++)
  {
    //spectrum.set(i - 200, 0, color(fft.getBand(i) * 255));
    
    if(i < fft.specSize() / 2)
      sumAmplitudeLower += fft.getBand(i);
    else
      sumAmplitudeHigher += fft.getBand(i);
  }
  
  mvaLower = (mvaLower * 5 + sumAmplitudeLower) / 6;
  mvaHigher = (mvaHigher * 5 + sumAmplitudeHigher) / 6;
  
  /*
  buf.set(0, 0, img);
  
  for(int iHueLevel = 0; iHueLevel < 5; iHueLevel++)
    for(int y = 0; y < img.height; y++)
      for(int x = 0; x < img.width; x++)
      {     
        float hueLevel = hue(blurred.get(x, y));
        hueLevel /= 255.0f;
        hueLevel = floor(hueLevel * 5); //0...5
        
        if(hueLevel == iHueLevel)
        {
          float distortDir = t + hueLevel / 5.0f * 2 * PI;
          float distortX = cos(distortDir) * mvaHigher;
          float distortY = sin(distortDir) * mvaLower;
          distortX *= 2;
          distortY *= 2;
          
          int destX = constrain(x + (int)distortX, 0, buf.width - 1);
          int destY = constrain(y + (int)distortY, 0, buf.height - 1);
          color c = img.get(x, y); //color(hueLevel / 5.0f * 255);
          buf.set(destX, destY, c);
        }
      }
  */
  
  image(img, 0, 0, width, height);
  
  shader.set("t", t);
  shader.set("mvaLower", mvaLower);
  shader.set("mvaHigher", mvaHigher);
  filter(shader);
  
  t += 0.01f;
}
  
