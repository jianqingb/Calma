import processing.serial.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioPlayer player;
Serial btPort;

PrintWriter output;
PFont Lfont;
PFont Rfont;
PFont Mfont;
PFont Bfont;
PImage Slogo;
PImage exit;
PImage print;
PImage data;
PImage guy;
PImage girl;
PImage other;
PImage heart;

String pulseBuffer;
int pulseCv;
int pulseThreshold;
int pulseDanger;
int pulseAverage_minute;
int pulseAverage_hour;
int pulseAverage_overall;
int pulseSum_minute;
int pulseSum_hour;
int pulseSum_overall;
int pulseIndex;
int thresholdCount;
float thresholdLine;
int dangerCount;
float dangerLine;
int cooldown;
int rep;
int[] rate;
int[] pulseHistory;
long elapsed;

int analysisWindowWidth;
int analysisWindowHeight;
int pulseWindowWidth;
int pulseWindowHeight;

int keyP;
int running;
String NBuffer;
String name;
int gender;
int age;

class Button 
{
  float x;
  float y;
  float w;
  float h;

  Button(float xPos, float yPos, float widthB, float heightB)
  {
    x = xPos;
    y = yPos;
    w = widthB;
    h = heightB;
  }

  boolean mouseOver()
  {
    if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h))
    {
      return true;
    }
    return false;
  }
}

Button resetB;
Button printB;
Button g_maleB;
Button g_femaleB;
Button g_otherB;
Button oneB;
Button twoB;
Button threeB;
Button fourB;
Button fiveB;
Button sixB;

void setup()
{
  size(2048, 1108);
  background(27, 34, 59);
  frameRate(120);
  Lfont = loadFont("Gilroy-Light-48.vlw");
  Rfont = loadFont("Gilroy-Regular-48.vlw");
  Mfont = loadFont("Gilroy-Medium-48.vlw");
  Bfont = loadFont("Gilroy-Bold-48.vlw");
  Slogo = loadImage("logo.png");
  exit = loadImage("exit.png");
  print = loadImage("print.png");
  data = loadImage("analysis.png");
  guy = loadImage("boy.png");
  girl = loadImage("girl.png");
  other = loadImage("robot.png");
  heart = loadImage("heart.png");
  textAlign(LEFT);
  rectMode(CORNER);
  ellipseMode(CENTER);  
  btPort = new Serial(this, Serial.list()[1], 9600);
  minim = new Minim(this);
  reset();
}

void draw()
{
  background(30, 38, 66);
  noStroke();
  elapsed = millis();
  if (running == 1)
  {
    splash();
  } else if (running == 2)
  {
    setGender();
  } else if (running == 3)
  {
    setAge();
  } else if (running == 4)
  {
    readAndParseSerial();
    drawBackground();
    drawMarkers();
    drawProfile();
    drawPulse();
    drawAnalysis();
    // drawAlert();
    playAudio();
    resetButton();
    printButton();
  }
}

void resetButton()
{
  if (resetB.mouseOver())
  {
    cursor(HAND);

    if (mousePressed == true)
    {
      reset();
    }
  } else if (resetB.mouseOver() == false)
  {
    cursor(ARROW);
  }
}

void printButton()
{
  if (printB.mouseOver())
  {
    cursor(HAND);

    if (mousePressed == true)
    {
      for (int i = 0; i < pulseHistory.length - 1; i++)
      {  
        output.println(pulseHistory[i]);
      }
      output.flush();
      output.close();
    }
  } else if (resetB.mouseOver() == false)
  {
    cursor(ARROW);
  }
}

void genderButton()
{
  if (g_maleB.mouseOver())
  {
    cursor(HAND);

    if (mousePressed == true)
    {
      gender = 0;
      running = 3;
    }
  } else if (g_femaleB.mouseOver())
  {
    cursor(HAND);

    if (mousePressed == true)
    {
      gender = 1;
      running = 3;
    }
  } else if (g_otherB.mouseOver())
  {
    cursor(HAND);

    if (mousePressed == true)
    {
      gender = 2;
      running = 3;
    }
  } else if (g_maleB.mouseOver() == false || g_femaleB.mouseOver() == false || g_otherB.mouseOver() == false)
  {
    cursor(ARROW);
  }
}

void ageButton()
{
  redraw();

  if (oneB.mouseOver())
  {
    cursor(HAND);

    if (mousePressed == true)
    {
      age = 0;
      running = 4;
    }
  } else if (twoB.mouseOver())
  {
    cursor(HAND);

    if (mousePressed == true)
    {
      age = 1;
      running = 4;
    }
  } else if (threeB.mouseOver())
  {
    cursor(HAND);

    if (mousePressed == true)
    {
      age = 2;
      running = 4;
    }
  } else if (fourB.mouseOver())
  {
    cursor(HAND);

    if (mousePressed == true)
    {
      age = 3;
      running = 4;
    }
  } else if (fiveB.mouseOver())
  {
    cursor(HAND);

    if (mousePressed == true)
    {
      age = 4;
      running = 4;
    }
  } else if (sixB.mouseOver())
  {
    cursor(HAND);

    if (mousePressed == true)
    {
      age = 5;
      running = 4;
    }
  } else if (oneB.mouseOver() == false || twoB.mouseOver() == false || threeB.mouseOver() == false || fourB.mouseOver() == false || fiveB.mouseOver() == false || sixB.mouseOver() == false)
  {
    cursor(ARROW);
  }
  if (age == 0)
  {
    pulseThreshold = pulseThreshold - 13;
    pulseDanger = pulseDanger - 13;
  } else if (age == 1)
  {
    pulseThreshold = pulseThreshold - 17;
    pulseDanger = pulseDanger - 17;
  } else if (age == 2)
  {
    pulseThreshold = pulseThreshold - 30;
    pulseDanger = pulseDanger - 30;
  } else if (age == 3)
  {
    pulseThreshold = pulseThreshold - 42;
    pulseDanger = pulseDanger - 42;
  } else if (age == 4)
  {
    pulseThreshold = pulseThreshold - 58;
    pulseDanger = pulseDanger - 58;
  } else if (age == 5)
  {
    pulseThreshold = pulseThreshold - 78;
    pulseDanger = pulseDanger - 78;
  }
}



void splash()
{
  image(Slogo, 816, 160);
  fill(255, 105, 97);
  textFont(Mfont);
  textSize(24);
  text("PROTOTYPE HEALTH-TRACKING APP & DEVICE (with a twist)", 707, 850);

  fill(253, 253, 150);
  textFont(Bfont);
  textSize(16);
  text("**Press any key to start**", 933, 950);

  if (keyPressed == true)
  {
    running = 2;
  }
}

void setAge()
{
  fill(79, 90, 129);
  textFont(Rfont);
  textSize(48);
  text("What is your age?", 820, 175);
  fill(45, 54, 94);
  rect(610, 250, 400, 200, 24);
  rect(1040, 250, 400, 200, 24);
  rect(610, 480, 400, 200, 24);
  rect(1040, 480, 400, 200, 24);
  rect(610, 710, 400, 200, 24);
  rect(1040, 710, 400, 200, 24);
  fill(33, 41, 73);
  textFont(Bfont);
  textSize(32);
  text("<13", 785, 360);
  text("13-19", 1200, 360);
  text("20-35", 775, 590);
  text("36-50", 1200, 590);
  text("51-65", 775, 820);
  text("66<", 1215, 820);
  ageButton();  
}

void setGender()
{
  fill(79, 90, 129);
  textFont(Rfont);
  textSize(48);
  text("What is your gender?", 800, 300);
  fill(45, 54, 94);
  rect(680, 450, 200, 200, 24);
  rect(930, 450, 200, 200, 24);
  rect(1180, 450, 200, 200, 24);
  fill(33, 41, 73);
  textFont(Bfont);
  textSize(32);
  text("Male", 745, 560);
  text("Female", 980, 560);
  text("Others", 1230, 560);
  genderButton();
  if (gender == 0)
  {
    pulseThreshold = 180;
    pulseDanger = 210;
  } else if (gender == 1)
  {
    pulseThreshold = 190;
    pulseDanger = 220;
  } else if (gender == 2)
  {
    pulseThreshold = 180;
    pulseDanger = 220;
  }
}

void readAndParseSerial()
{
  if (btPort.available() > 0)
  {
    pulseBuffer = btPort.readStringUntil('\n');  
    if (pulseBuffer != null)
    {
      String pulseBufferT = trim(pulseBuffer);
      pulseCv = Integer.parseInt(pulseBufferT);
      pulseHistory[pulseIndex] = pulseCv;
      pulseIndex++;
      pulseSum_minute = 0;
      pulseSum_hour = 0;
      pulseSum_overall = 0;
      thresholdCount = 0;
      dangerCount = 0;

      for (int i = 0; i < pulseHistory.length; i++)
      {
        pulseSum_overall = pulseSum_overall + pulseHistory[i];
      }

      pulseAverage_overall = int(pulseSum_overall/pulseIndex);

      /*if (pulseIndex >= 60)
       {
       for (int i = 0; i < 61; i++)
       {
       pulseSum_minute = pulseSum_minute + pulseHistory[pulseHistory.length - i];
       }
       pulseAverage_minute = int(pulseSum_minute/60);
       } else 
       {*/
      pulseAverage_minute = pulseAverage_overall;
      /*}
       
       if (pulseIndex >= 360)
       {     
       for (int i = 0; i < 361; i++)
       {
       pulseSum_hour = pulseSum_minute + pulseHistory[pulseHistory.length - i];
       }
       
       pulseAverage_hour = int(pulseSum_hour/60);
       } else
       {*/
      pulseAverage_hour = pulseAverage_overall;
    }

    for (int i = 0; i < pulseHistory.length; ++i)
    {
      if (pulseHistory[i] >= 120)
      {
        thresholdCount++;
      }
    }

    for (int i = 0; i < pulseHistory.length; ++i)
    {
      if (pulseHistory[i] >= 190)
      {
        dangerCount++;
      }
    }
  }
}

void drawBackground()
{
  fill(32, 42, 72);
  rect(0, 0, 660, 1108, 0, 48, 48, 0);
  fill(44, 52, 87);
  rect(0, 0, 100, 1108, 0, 48, 48, 0);
  fill(28, 36, 63);
  rect(1087, 197, 450, 390, 24, 24, 24, 24);
  rect(247, 197, 790, 390, 24, 24, 24, 24);
  rect(247, 747, pulseWindowWidth - 10, pulseWindowHeight - 10, 24, 24, 24, 24);
  fill(33, 41, 73);
  rect(1090, 200, 460, 400, 24, 24, 24, 24);
  rect(250, 200, 800, 400, 24, 24, 24, 24);
  rect(250, 750, pulseWindowWidth, pulseWindowHeight, 24, 24, 24, 24);
  fill(45, 54, 94);
  rect(1100, 210, 460, 400, 24, 24, 24, 24);
  rect(260, 210, 800, 400, 24, 24, 24, 24);
  rect(260, 760, pulseWindowWidth, pulseWindowHeight, 24, 24, 24, 24);
  tint(255, 255);
  image(Slogo, 1900, 40, 100, 150);
  tint(255, 200);
  image(exit, 1933, 210, 50, 50);
  image(print, 1927, 280, 50, 50);
  tint(255, 255);
  image(data, 980, 240, 50, 50);
  fill(68, 78, 116);
  textFont(Mfont);
  textSize(32);
  text("Your Data", 250, 170);
  text("Your Heart-Rate", 250, 720);
}

void drawPulse()
{
  for (int i = 0; i < rate.length - 1; i++) 
  {
    rate[i] = rate[i + 1];
  }

  float dummy = map(pulseCv, 0, 220, 1024, 776);
  rate[rate.length-1] = int(dummy);

  stroke(61, 198, 253);
  noFill();
  strokeWeight(2);
  beginShape();

  for (int i = 0; i < rate.length - 40; i++)
  {  
    vertex(i + 280, rate[i]);
  }

  endShape();

  stroke(177, 156, 217);
  strokeWeight(2);
  line(280, rate[0], 1540, rate[rate.length - 1]);

  stroke(253, 253, 150);
  strokeWeight(5);
  line(800, rate[rate.length - 250], 1000, rate[rate.length - 1]);
}

void drawMarkers()
{
  for (int i = 0; i < 61; i++)
  {
    stroke(79, 90, 129);
    strokeWeight(1);
    line(i * 21 + 280, 776, i * 21 + 280, 1024);
  }

  thresholdLine = map(pulseThreshold, 0, 220, 1024, 776);
  dangerLine = map(pulseDanger, 0, 220, 1024, 776);

  stroke(255, 179, 71);
  strokeWeight(1);
  line(280, int(thresholdLine), 1540, int(thresholdLine));

  stroke(255, 105, 97);
  strokeWeight(1);
  line(280, int(dangerLine), 1540, int(dangerLine));

  stroke(77, 130, 243);
  strokeWeight(4);
  line(250, 776, 270, 776);

  stroke(77, 130, 243);
  strokeWeight(4);
  line(250, 1024, 270, 1024);

  textFont(Mfont);
  textSize(12);
  fill(77, 130, 243);
  text("0", 240, 1024);
  text("220", 228, 776);

  fill(255, 179, 71);
  text("THRESHOLD", 1450, int(thresholdLine));

  fill(255, 105, 97);
  text("DANGER", 1450, int(dangerLine));
}

void drawAlert()
{
  textSize(24);
  stroke(180, 180, 180);
  strokeWeight(3);

  if (pulseCv < pulseThreshold)
  {
    fill(0, 255, 0);
  }

  if (pulseCv >= pulseThreshold)
  {
    fill(255, 165, 0);
  }

  if (pulseCv >= pulseDanger || pulseCv == 0)
  {
    fill(255, 0, 0);
  }

  rect(700, 310, 200, 80);

  if (pulseCv >= 190 || pulseCv == 0)
  {
    fill(255, 255, 255);
    text("RIP", 700, 320);
    fill(255, 0, 0);
  }

  text(pulseCv + " BPM", 700, 220);
}

void drawProfile()
{
  fill(79, 90, 129);
  textFont(Rfont);
  textSize(24);
  text("Hi there, user.", 1140, 280);

  fill(79, 90, 129);
  textFont(Rfont);
  textSize(16);
  text("You are a ", 1140, 370);
  fill(250, 250, 250);
  if (age == 0)
  {
    text("<13 years old", 1225, 370);
  } else if (age == 1)
  {
    text("13-19 years old", 1225, 370);
  } else if (age == 2)
  {
    text("20-35 years old", 1225, 370);
  } else if (age == 3)
  {
    text("36-50 years old", 1225, 370);
  } else if (age == 4)
  {
    text("51-65 years old", 1225, 370);
  } else if (age == 5)
  {
    text("66< years old", 1225, 370);
  }

  fill(250, 250, 250);
  if (gender == 0)
  {
    image(guy, 1430, 250, 100, 100);
    text("DUDE", 1350, 370);
  } else if (gender == 1)
  {
    image(girl, 1430, 250, 100, 100);
    text("DUDETTE", 1350, 370);
  } else if (gender == 2)
  {
    image(other, 1430, 250, 100, 100);
    text("PERSON", 1350, 370);
  }

  fill(79, 90, 129);
  text("So your maximum heart-rate will be ", 1140, 400);
  fill(255, 105, 97);
  text(pulseDanger + " BPM", 1410, 400);
  fill(79, 90, 129);
  text("Try to keep below ", 1140, 430);
  fill(255, 179, 71);
  text(pulseThreshold + " BPM", 1280, 430);

  image(heart, 1255, 500, 50, 50);
  fill(250, 250, 250);
  textSize(24);
  text(pulseCv + " BPM", 1325, 530);
}

void drawAnalysis()
{
  fill(250, 250, 250);
  textFont(Mfont);
  textSize(24);
  text("Active", 300, 280);

  fill(79, 90, 129);
  textFont(Mfont);
  textSize(16);
  text("Last", 450, 300);
  text("Minute", 550, 300);
  text("Hour", 650, 300);
  text("Overall", 750, 300);
  text("Current HR", 300, 350);
  text("Max HR", 300, 400);
  text("Min HR", 300, 450);
  text("Avg HR", 300, 500);

  fill(250, 250, 250);
  textFont(Rfont);
  textSize(16);
  text(pulseCv, 450, 350);
  text(max(pulseHistory), 450, 400);
  text(max(pulseHistory), 550, 400);
  text(max(pulseHistory), 650, 400);
  text(max(pulseHistory), 750, 400);
  text(min(pulseHistory), 450, 450);
  text(min(pulseHistory), 550, 450);
  text(min(pulseHistory), 650, 450);
  text(min(pulseHistory), 750, 450);
  text(pulseAverage_minute, 550, 500);
  text(pulseAverage_hour, 650, 500);
  text(pulseAverage_overall, 750, 500);
  stroke(33, 41, 73);
  strokeWeight(2);
  line(550, 344, 770, 344);
  line(450, 494, 470, 494);

  stroke(79, 90, 129);
  strokeWeight(4);
  line(850, 375, 850, 475);

  fill(79, 90, 129);
  textFont(Mfont);
  textSize(16);
  text("Time Elapsed: ", 875, 350);
  text("Input Count: ", 875, 400);
  text("Threshold Count: ", 875, 450);
  text("Danger Count: ", 875, 500);

  fill(250, 250, 250);
  textFont(Rfont);
  textSize(16);
  text(elapsed / 1000 + " s", 985, 350);
  text(pulseIndex + 1, 975, 400);
  text(thresholdCount, 1008, 450);
  text(dangerCount, 992, 500);




  /*if (pulseCv == 0)
   {
   fill(200, 0, 0);
   textSize(16);
   text("I think you might be dead, best to check tho", 310, 300);
   } else if (pulseCv < pulseThreshold)
   {
   fill(0, 200, 0);
   textSize(16);
   text("All good fam!", 310, 300);
   } else if (pulseCv >= pulseThreshold && pulseCv < pulseDanger)
   {
   fill(200, 165, 0);
   textSize(16);
   text("Calm down, chill bro.", 310, 300);
   } else if (pulseCv >= pulseDanger)
   {
   fill(200, 0, 0);
   textSize(16);
   text("I hope someone called an ambulance for you! (;", 310, 300);
   }
   */
}

void playAudio()
{
  if (cooldown == 0)
  {
    if (pulseCv > pulseThreshold)
    {
      cooldown = 1;
    }
  } else if (cooldown == 1) 
  {
    if (pulseCv >= pulseThreshold && pulseCv < pulseDanger)
    {
      player = minim.loadFile("Chill.wav");

      if (!player.isPlaying())
      {
        player.play();
      }

      cooldown++;
    } else if (pulseCv >= pulseDanger)
    {
      player = minim.loadFile("Alert.wav");

      if (!player.isPlaying())
      {
        player.play();
      }

      cooldown = cooldown + 100;
    }
  } else if (cooldown < rep)
  {
    cooldown++;
  } else if (cooldown == rep)
  {
    cooldown = 0;
  }
}

void reset()
{
  pulseBuffer = " ";
  pulseCv = 0;
  pulseThreshold = 0;
  pulseDanger = 0;
  pulseAverage_minute = 0;
  pulseAverage_hour = 0;
  pulseAverage_overall = 0;
  pulseSum_minute = 0;
  pulseSum_hour = 0;
  pulseSum_overall = 0;
  pulseIndex = 0;
  thresholdCount = 0;
  thresholdLine = 0;
  dangerCount = 0;
  dangerLine = 0;
  cooldown = 0;

  elapsed = millis();
  rep = 250;
  pulseWindowWidth = 1300;
  pulseWindowHeight = 280;


  rate = new int [pulseWindowWidth];
  pulseHistory = new int[1000000];

  for (int i=0; i < rate.length; i++)
  {
    rate[i] = 1024;
  }

  running = 1;
  keyP = 0;
  age = 99;

  fill(0, 0, 0, 0);
  resetB = new Button(1933, 210, 50, 50);
  printB = new Button(1927, 280, 50, 50);
  g_maleB = new Button(680, 450, 200, 200);
  g_femaleB = new Button(930, 450, 200, 200);
  g_otherB = new Button(1180, 450, 200, 200);
  oneB = new Button(610, 250, 400, 200);
  twoB = new Button(1040, 250, 400, 200);
  threeB = new Button(610, 480, 400, 200);
  fourB = new Button(1040, 480, 400, 200);
  fiveB = new Button(610, 710, 400, 200);
  sixB = new Button(1040, 710, 400, 200);


  output = createWriter("HR_History.txt");
}