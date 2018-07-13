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
ArrayList<Player> players = new ArrayList<Player>();
//Player player;
double count=1;
int d_count=0, gamespeed=50;
float score=0;
PImage dino1, dino2, dino3, diamond, diamondS, spike;
boolean gameOver;

void mousePressed()
{
}

void keyPressed()
{
  if(keyCode==32)
  {
    Vec2 force = new Vec2(0,2000000);
    for(Player player : players)
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
  for(Player player : players)
  {
    if(keyCode==RIGHT) player.right=true;
    if(keyCode==LEFT) player.left=true;
  }
  
  //if(gameOver && keyCode==32)
   //restartGame();
}

void keyReleased()
{
  for(Player player : players)
  {
    if(keyCode==RIGHT) player.right=false;
    if(keyCode==LEFT) player.left=false;
  }
}

void setup()
{
  size(1280,720);
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,-400);
  gameOver=false;
  
  floors.add(new Floor(width/2,height-25,width*2,50));
  floors.add(new Floor(width/2,height-350,width*2,50));
  //player = new Player(100,height-85,70,70,35);
  players.add(new Player(100,height-85,70,70,35));
  //diamonds.add(new Diamond(width,height-175));
  
  dino1=loadImage("data/dino1.png");
  dino2=loadImage("data/dino2.png");
  dino3=loadImage("data/dino3.png");
  diamond=loadImage("data/diamond.png");
  diamondS=loadImage("data/diamondS.png");
  spike=loadImage("data/spike.png");
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
  for(Player player : players)
  {
    player.show();
    player.move();
  }
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
  if(count%(75*50.0/gamespeed)==0)
  {
    float rand=random(50,250);
    for(int i=0; i<round(random(1,3))*4; i++)
     spikes.add(new Spike(width+rand+i*12,height-60,1));
    diamonds.add(new Diamond(width+rand+random(-100,100),height-random(150,200)));
  }
  else if((count+37)%(75*50.0/gamespeed)==0)
  {
    float rand=random(50,250);
    for(int i=0; i<round(random(1,3))*4; i++)
     spikes.add(new Spike(width+rand+i*12,height-315,2));
  }
    
  for(Spike s : spikes)
  {
    s.show(); 
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
  for(int i=players.size()-1; i>=0; i--)
    players.remove(i); 
  
  for(int i=diamonds.size()-1; i>=0; i--)
    diamonds.remove(i); 
    
  for(int i=spikes.size()-1; i>=0; i--)
    spikes.remove(i); 
    
  score=0;
  count=1;
  
  players.add(new Player(100,height-85,70,70,35));
  
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
