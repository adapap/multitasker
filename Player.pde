class Player
{
  Body body;
  Vec2 pos;
  float x, y, r;
  boolean left=false, right=false;
  boolean spawned = false;
  ArrayList<PImage> animFrames = new ArrayList<PImage>();
  
  Player()
  {
    for (int i=1; i<4; i++) {
      animFrames.add(loadImage("assets/player/dino" + i + ".png"));
    }
    this.reset();
  }
  
  void reset() {
    if (this.spawned) {
      killBody();
    }
    this.x = 100;
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
    
    //ellipse(0, 0, 2 * r, 2 * r);

    int tick = gameState.get("tick");
    int frameIndex = floor(tick % 30 / 10);
    image(animFrames.get(frameIndex), 0, 0);
     
    popMatrix();
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
    int dir = right ? 1 : -1;
    this.applyForce(new Vec2(0, dir * 20000));
  }
  
  void applyForce(Vec2 force) {
    if(floor(pos.y) == 634)
      body.applyForceToCenter(force);
  }
  
}
