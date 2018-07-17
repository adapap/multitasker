  import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

static Box2DProcessing box2d;
static int gameWidth = 1280;
static int gameHeight = 720;

ArrayList<Floor> floors = new ArrayList<Floor>();
//ArrayList<Spike> spikes = new ArrayList<Spike>();
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
ArrayList<Diamond> diamonds = new ArrayList<Diamond>();
Player player;

// The following are containers for reference throughout the game
// Collection of forces used
HashMap<String, Vec2> forces = new HashMap<String, Vec2>();
// Collection of static (non-interactive) sprites
HashMap<String, PImage> sprites = new HashMap<String, PImage>();
// Entity spawn chances
HashMap<String, Float> spawnChances = new HashMap<String, Float>();
// Names for common keyboard keys
IntDict keyCodes = new IntDict();
// Values such as score or the current tick
IntDict gameState = new IntDict();
// Powerups/cheats/mods
HashMap<String, Boolean> modifiers = new HashMap<String, Boolean>();

void mousePressed()
{
}

void keyPressed()
{
  if(keyCode==keyCodes.get("SPACE")) {
    player.applyForce(forces.get("playerJump"));
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
    player.stopMovement();
  }
  if(keyCode==LEFT) {
    player.left=false;
    player.stopMovement();
  }
}

void resetCamera() {
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0),
         width/2.0, height/2.0, 0,
         0, 1, 0);
}

void setup()
{
  //GODMODE
  modifiers.put("godmode", false);

  sprites.put("diamondIcon", loadImage("assets/misc/diamondSmall.png")); 
  
  forces.put("playerJump", new Vec2(0, 2E6));
  forces.put("diamondAnimation", new Vec2(0, 2E3));
  forces.put("antiGravity", new Vec2(0, 400));
  forces.put("none", new Vec2(0, 0));
  // forces.put("projectileAntigrav", new Vec2(0, 300));
  
  spawnChances.put("spike", 0.1);
  spawnChances.put("projectile", 0.005);
  
  keyCodes.set("SPACE", 32);
  
  // Initiate the world for the game
  size(1280, 720, P3D);
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,-400);
  
  // Create boundaries (floors, temp.) and the player
  floors.add(new Floor(width/2, height-25, width*2, 50));
  floors.add(new Floor(width/2, height-350, width*2, 50));
  player = new Player();
  // eye, center, up
  // camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0),
  //        width/2.0, height/2.0, 0,
  //        0, 1, 0);
  
  resetGame();
}

void draw()
{
  // General rendering of background and scores
  background(135, 206, 250);
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
  textAlign(CENTER);
  textSize(40);
  fill(0);
  if(gameState.get("active") == 0) {
    text("GAME OVER", width/2, height/2 - 100);
    textSize(20);
    text("Press SPACE to play again", width/2, height/2 - 50);
  }
  
  int tick = gameState.get("tick");
  int score = gameState.get("score");
  // Obstacle Logic
  if (random(1) <= spawnChances.get("spike")) {
    if (Obstacle.canSpawn(width)) {
      Obstacle.spikeIsCeiling ^= 1; 
      int orientation = Obstacle.spikeIsCeiling + 1;
      int heightDiff = orientation == 1 ? 53 : 322;
      float groupSize = round(random(1,3) * 4);
      for (int i=0; i < groupSize; i++) {
        obstacles.add(new Spike(width + i*12, height - heightDiff, orientation));
      }
      if (orientation == 1) {
        diamonds.add(new Diamond(width + random(-100,100), height - random(150,200)));
      }
    }
  }

  if (score > 1) {
    int randOffset = round(random(1, 3)) * 60;
    if (tick - randOffset >= Obstacle.lastProjectileTick) {
      // Spawn warning indicator
      Obstacle.lastProjectileTick = tick;
      float randHeight = random(100, 300);
      obstacles.add(new Projectile(width, height - randHeight, 100, radians(180), 15));
    }
  }
  
  // Obstacle rendering
  float maxPos = 0;
  for (int i=obstacles.size() - 1; i>=0; i--) {
    Obstacle o = obstacles.get(i);
    o.show();
    if(o.pos.x > maxPos) {
      maxPos = o.pos.x;
    }
    
    if (o.isDead()) {
      gameState.add("score", o.score);
      obstacles.remove(i);
    }
  }
  Obstacle.lastObstaclePos = maxPos;
  
  // Collectible rendering
  for (int i=diamonds.size() - 1; i>=0; i--) {
    Diamond d = diamonds.get(i);
    d.show();
    
    if (d.isDead()) {
      diamonds.remove(i);
    }
  }
  
  if (gameState.get("active") == 1) {
    if (tick % 5 == 0) {
      gameState.increment("score");
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
    
  for(int i=obstacles.size()-1; i>=0; i--) {
    Obstacle o = obstacles.get(i);
    o.killBody();
    obstacles.remove(i);
  }
}
boolean hasClass(Object a, Object b, Class c) {
  return (c.isInstance(a) || c.isInstance(b));
}

void beginContact(Contact cp) 
{
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  
  if ((o1==null || o2==null) || !hasClass(o1, o2, Player.class)) {
    return;
  }
   
  if (hasClass(o1, o2, Obstacle.class) && !modifiers.get("godmode")) {
    gameState.set("active", 0);
  }
  
  if (hasClass(o1, o2, Diamond.class)) {
    Diamond d;
    if (o1 instanceof Diamond) {
      d = (Diamond) o1;
    }
    else {
      d = (Diamond) o2;
    }
    gameState.increment("diamondsCollected");
    d.applyForce(forces.get("diamondAnimation"));
    d.collected=true;
  }
}

void endContact(Contact cp)
{
}
