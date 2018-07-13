import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

Box2DProcessing box2d;
ArrayList<Floor> floors = new ArrayList<Floor>();
ArrayList<Spike> spikes = new ArrayList<Spike>();
ArrayList<Diamond> diamonds = new ArrayList<Diamond>();
Player player;
double count=1;
int d_count=0, gamespeed=50;
float score=0;
PImage dino1, dino2, dino3, diamond, diamondS, spike;
boolean gameOver=false;

int isCeiling = 1;

void mousePressed()
{
}

void keyPressed()
{
  if(keyCode==32)
  {
    Vec2 force = new Vec2(0,2000000);
    player.applyForce(force);
    for(Spike s : spikes)
    {
     //s.body.setLinearVelocity(new Vec2(0,0));
     //Vec2 pos=box2d.getBodyPixelCoord(s.body);
     //float d=dist(pos.x,pos.y,height/2,pos.y);
     //float x_off=map(d,0,width/2,10000000,0);
     //if(pos.x<width/2) x_off*=-1;
     //s.applyForce(new Vec2(x_off,10000000));
    }
  }
  
  if(keyCode==RIGHT) player.right=true;
  if(keyCode==LEFT) player.left=true;
  
  if(gameOver && keyCode==32);
   //restartGame();
}

void keyReleased()
{
  if(keyCode==RIGHT) player.right=false;
  if(keyCode==LEFT) player.left=false;
}

void setup()
{
  size(1280,720);
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,-400);
  
  floors.add(new Floor(width/2,height-25,width*2,50));
  floors.add(new Floor(width/2,height-350,width*2,50));
  player = new Player(100,height-85,70,70,35);
  //diamonds.add(new Diamond(width,height-175));
  
  dino1=loadImage("data/dino1.png");
  dino2=loadImage("data/dino2.png");
  dino3=loadImage("data/dino3.png");
  diamond=loadImage("data/diamond.png");
  diamondS=loadImage("data/diamondS.png");
  spike=loadImage("assets/spike.png");
}

void draw()
{
  background(255); count++;
  if(!gameOver)
  box2d.step();
  box2d.listenForCollisions();
  //score+=1.0/60.0;
  fill(0); textAlign(LEFT); textSize(12);
  //text(frameRate,0,10);
  text("SCORE: "+floor(score),0,10);
  imageMode(CORNER);
  image(diamondS,5,20); textSize(18);
  text(d_count,30,37);
  
  //floor
  for(Floor f : floors)
  {
    f.show(); 
  }
  
  //player
  player.show();
  player.move();
  textAlign(CENTER);
  textSize(40);
  fill(0);
  if(gameOver)
  {
    text("GAME OVER",width/2,height/2-100);
    textSize(20);
    text("Press any button to play again",width/2,height/2-50);
  }
  
  //obstacles
  HashMap<String, Float> spawnChances = new HashMap<String, Float>();
  spawnChances.put("spike", 0.1);
  // spawnChances.put("diamond", 0.25);
  
  if (random(1) <= spawnChances.get("spike")) {
    if (Obstacle.canSpawn(width)) {
      isCeiling ^= 1; 
      int orientation = isCeiling + 1;
      int heightDiff = orientation == 1 ? 60 : 315;
      float groupSize = round(random(1,3) * 4);
      for (int i=0; i < groupSize; i++) {
        spikes.add(new Spike(width + i*12, height - heightDiff, orientation));
      }
      if (orientation == 1) {
        diamonds.add(new Diamond(width + random(-100,100), height - random(150,200)));
      }
    }
  }
  
  float maxPos=0;
  for(Spike s : spikes)
  {
    s.show();
    if(s.pos.x>maxPos)
     maxPos=s.pos.x;
    Obstacle.lastObstaclePos=maxPos;
  }
  
  for(int i=spikes.size()-1; i>=0; i--)
  {
    Spike s = spikes.get(i);
    if(s.isDead())
    {
      spikes.remove(i);
      score++;
    }
  }
  
  //diamonds
  for(Diamond d : diamonds)
   d.show();
   
  for(int i=diamonds.size()-1; i>=0; i--)
  {
    Diamond d = diamonds.get(i);
    if(d.isDead())
    {
      diamonds.remove(i);
    }
    if(d.dead)
    {
     d.killBody();
     diamonds.remove(i);
    }
  }
}

void restartGame()
{
  //player = new Player(100,height-85,70,70,35);
  for(int i=diamonds.size()-1; i>=0; i--)
    diamonds.remove(i); 
    
  for(int i=spikes.size()-1; i>=0; i--)
    spikes.remove(i); 
    
  score=0;
  count=1;
  
  gameOver=false;
}

void beginContact(Contact cp) 
{
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  
  if (o1==null || o2==null)
   return;
   
  if((o1.getClass()==Spike.class && o2.getClass()==Player.class)||(o2.getClass()==Spike.class && o1.getClass()==Player.class))
  {
    gameOver=true;
  }
  
  if(o1.getClass()==Diamond.class && o2.getClass()==Player.class)
  {
    Diamond d1=(Diamond) o1;
    d_count++;
    d1.applyForce(new Vec2(0,2000));
    d1.animate=true;
  }
  else if(o2.getClass()==Diamond.class && o1.getClass()==Player.class)
  {
    Diamond d1=(Diamond) o2;
    d_count++;
    d1.applyForce(new Vec2(0,2000));
    d1.animate=true;
  }
}

void endContact(Contact cp)
{
}
