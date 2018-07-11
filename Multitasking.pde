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
Player player;
double count=1;
PImage dino1, dino2;
boolean gameOver=false;

void mousePressed()
{
  Vec2 force = new Vec2(0,200000);
  player.applyForce(force);
}

void keyPressed()
{
  if(keyCode==32)
  {
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
  box2d.setGravity(0,-200);
  
  floors.add(new Floor(width/2,height-25,width*2,50));
  player = new Player(100,height-85,70,70);
  
  dino1=loadImage("data/dino1.png");
  dino2=loadImage("data/dino2.png");
}

void draw()
{
  background(255); count++;
  if(!gameOver)
  box2d.step();
  box2d.listenForCollisions();
  fill(0); textAlign(LEFT); textSize(12);
  text(frameRate,0,10);
  
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
  if(player.check())
  {
    text("GAME OVER",width/2,height/2);
    gameOver=true;
  }
  
  //obstacles
  if(count%60==0)
  {
    float rand=random(50,250);
    for(int i=0; i<4; i++)
     spikes.add(new Spike(width+rand+i*12,height-75));
  }
    
  for(Spike s : spikes)
  {
    s.show(); 
  }
  
  for(int i=spikes.size()-1; i>=0; i--)
  {
    Spike s = spikes.get(i);
    if(s.isDead())
      spikes.remove(i);
  }
}

void beginContact(Contact cp) 
{
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  
  
  //if((o1.getClass()==Spike.class && o2.getClass()==Player.class)|| (o2.getClass()==Spike.class && o1.getClass()==Player.class))
  //{
  //  //Spike s1 = (Spike) o1;
  //  //s1.change();
  //  //Player p2 = (Player) o2;
  //  //p2.change();
  //  println(frameRate);
  //}
}

void endContact(Contact cp)
{
}
