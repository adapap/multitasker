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

// The following are containers for reference throughout the game
// Collection of forces used
HashMap<String, Vec2> forces = new HashMap<String, Vec2>();
// Collection of static (non-interactive) sprites
HashMap<String, PImage> sprites = new HashMap<String, PImage>();
// Names for common keyboard keys
IntDict keyCodes = new IntDict();
// Values such as score or the current tick
IntDict gameState = new IntDict();

void mousePressed()
{
}

void keyPressed()
{
  if(keyCode==keyCodes.get("SPACE"))
  {
    player.applyForce(forces.get("playerJump"));
    /* for(Spike s : spikes)
    {
     s.body.setLinearVelocity(new Vec2(0,0));
     Vec2 pos=box2d.getBodyPixelCoord(s.body);
     float d=dist(pos.x,pos.y,height/2,pos.y);
     float x_off=map(d,0,width/2,10000000,0);
     if(pos.x<width/2) x_off*=-1;
     s.applyForce(new Vec2(x_off,10000000));
    } */
  }
  
  if (keyCode==RIGHT) {
    player.right=true;
  }
  if(keyCode==LEFT) {
    player.left=true;
  }
  
  if(gameState.get("active")==0 && keyCode==keyCodes.get("SPACE")) {
     resetGame();
  }
}

void keyReleased()
{
  if(keyCode==RIGHT) {
    player.right=false;
  }
  if(keyCode==LEFT) {
    player.left=false;
  }
}

void setup()
{
  sprites.put("diamondIcon", loadImage("assets/misc/diamondSmall.png"));
  
  forces.put("playerJump", new Vec2(0, 2E6));
  forces.put("diamondAnimation", new Vec2(0, 2E3));
  forces.put("idk?", new Vec2(0, 400));
  
  keyCodes.set("SPACE", 32);
  
  // Initiate the world for the game
  size(1280,720);
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,-400);
  
  // Create boundaries (floors, temp.) and the player
  floors.add(new Floor(width/2, height-25, width*2, 50));
  floors.add(new Floor(width/2, height-350, width*2, 50));
  player = new Player();
  
  resetGame();
}

void draw()
{
  // General rendering of background and scores
  background(255);
  if(gameState.get("active")==1) {
    box2d.step();
    box2d.listenForCollisions();
    gameState.increment("tick");
  }
  //score+=1.0/60.0;
  fill(0);
  textAlign(LEFT);
  
  textSize(12);
  //text(frameRate,0,10);
  text("SCORE: " + gameState.get("score"),0,10);
  
  imageMode(CORNER);
  image(sprites.get("diamondIcon"), 5, 20);
  textSize(18);
  text(gameState.get("diamondsCollected"), 30, 37);
  
  // Floor rendering
  for(Floor f : floors)
  {
    f.show(); 
  }
  
  // Player updates
  player.show();
  player.move();
  textAlign(CENTER);
  textSize(40);
  fill(0);
  if(gameState.get("active") == 0) {
    text("GAME OVER", width/2, height/2 - 100);
    textSize(20);
    text("Press any button (SPACE) to play again", width/2, height/2 - 50);
  }
  
  // Obstacle Logic
  HashMap<String, Float> spawnChances = new HashMap<String, Float>();
  spawnChances.put("spike", 0.1);
  // spawnChances.put("diamond", 0.25);
  
  if (random(1) <= spawnChances.get("spike")) {
    if (Obstacle.canSpawn(width)) {
      Obstacle.spikeIsCeiling ^= 1; 
      int orientation = Obstacle.spikeIsCeiling + 1;
      int heightDiff = orientation == 1 ? 53 : 322;
      float groupSize = round(random(1,3) * 4);
      for (int i=0; i < groupSize; i++) {
        spikes.add(new Spike(width + i*12, height - heightDiff, orientation));
      }
      if (orientation == 1) {
        diamonds.add(new Diamond(width + random(-100,100), height - random(150,200)));
      }
    }
  }
  
  // Obstacle rendering
  float maxPos = 0;
  for(Spike s : spikes)
  {
    s.show();
    if(s.pos.x > maxPos) {
      maxPos = s.pos.x;
    }
  }
  Obstacle.lastObstaclePos = maxPos;
  
  for(int i=spikes.size()-1; i>=0; i--)
  {
    Spike s = spikes.get(i);
    if(s.isDead())
    {
      spikes.remove(i);
      gameState.increment("score");
    }
  }
  
  // Collectible rendering
  for(Diamond d : diamonds) {
    d.show();
  }
   
  for(int i=diamonds.size()-1; i>=0; i--)
  {
    Diamond d = diamonds.get(i);
    if(d.isDead())
    {
      diamonds.remove(i);
    }
  }
}

void resetGame()
{
  gameState.set("tick", 1);
  gameState.set("score", 0);
  gameState.set("diamondsCollected", 0);
  gameState.set("speed", 50);
  gameState.set("active", 1);
  Obstacle.lastObstaclePos = 0;
  
  player.reset();
  
  for(int i=diamonds.size()-1; i>=0; i--) {
    Diamond d = diamonds.get(i);
    d.killBody();
    diamonds.remove(i);
  }
    
  for(int i=spikes.size()-1; i>=0; i--) {
    Spike s = spikes.get(i);
    s.killBody();
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
  
  if (o1==null || o2==null) {
    return;
  }
  Class o1c = o1.getClass();
  Class o2c = o2.getClass();
  
  boolean Player_Obstacle = (o1c==Spike.class && o2c==Player.class)||(o2c==Spike.class && o1c==Player.class);
  boolean Player_Collectible = (o1c==Diamond.class && o2c==Player.class)||(o2c==Diamond.class && o1c==Player.class);
   
  if (Player_Obstacle) {
    gameState.set("active", 0);
  }
  
  if (Player_Collectible) {
    Diamond d;
    if (o1c==Diamond.class) {
      d = (Diamond) o1;
    }
    else {
      d = (Diamond) o2;
    }
    gameState.increment("diamondsCollected");
    d.applyForce(forces.get("diamondAnimation"));
    d.animate=true;
  }
}

void endContact(Contact cp)
{
}
