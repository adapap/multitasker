class Player
{
  Body body;
  Vec2 pos;
  int dir;
  float x, y, r;
  boolean left, right, spawned;
  ArrayList<PImage> animFrames = new ArrayList<PImage>();
  
  Player()
  {
    for (int i=1; i<4; i++) {
      animFrames.add(loadImage("assets/player/dino" + i + ".png"));
    }
    this.spawned = false;
    this.dir = 0;
    this.left = false;
    this.right = false;
    this.reset();
  }
  
  void reset() {
    if (this.spawned) {
      killBody();
    }
    this.x = 200;
    this.y = height - 85;
    this.r = 35;
    makeBody(new Vec2(this.x, this.y), this.r);
    body.setUserData(this);
    this.left=false;
    this.right=false;
    this.spawned = true;
  }
  
  void show()
  {
    pos = box2d.getBodyPixelCoord(body);
    float a = -body.getAngle();
    
    imageMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(a);
    noFill(); stroke(0); strokeWeight(2);

    int tick = gameState.get("tick");
    int frameIndex = floor(tick % 30 / 10);
    image(animFrames.get(frameIndex), 0, 0);
     
    popMatrix();
    move();
  }
  
  void killBody() {
    box2d.destroyBody(this.body);
  }
  
  void makeBody(Vec2 center, float r) {
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);
    
    FixtureDef fd = new FixtureDef();
    fd.shape=cs;
    fd.density=1;
    fd.friction=0;
    fd.restitution=0;
    
    BodyDef bd = new BodyDef();
    bd.type=BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    
    body=box2d.createBody(bd);
    body.createFixture(fd);
  }
  
  void move() {
    float leftBound = 100;
    float rightBound = 900;
    Vec2 vel = body.getLinearVelocity();

    if (dir == 1 && pos.x < rightBound) {
      vel.x = dir * 50;
    }
    else if (dir == -1 && pos.x > leftBound) {
      vel.x = dir * 50;
    }
    else {
      vel.x = 0;
    }

    body.setLinearVelocity(vel);
  }
  
  void applyForce(Vec2 force) {
    if(floor(pos.y) == 634)
      body.applyForceToCenter(force);
  }
  
}
