abstract static class Obstacle {
  Body body;
  Vec2 pos;
  PImage sprite;
  float alpha;
  int score;
  
  static float lastObstaclePos = 0;
  static float threshold = 200;
  
  static int spikeIsCeiling = 1;
  static int lastProjectileTick = 0;

  static boolean canSpawn(float xpos) {
    return xpos - lastObstaclePos >= threshold;  
  }
  
  abstract void show();
  
  boolean isDead() {
    pos = box2d.getBodyPixelCoord(body);
    if(pos.x < -100) 
    {
      killBody();
      return true;
    }
    return false;
  }

  void fade() {
    if (pos.x <= gameWidth && this.alpha < 255) {
      this.alpha += min(15, 255 - this.alpha);
    }
      
    if (pos.x <= 140 && this.alpha > 0) {
      this.alpha -= min(25, this.alpha);
    }
  }
  
  void killBody() {
    box2d.destroyBody(body);
  }
  
  void applyForce(Vec2 force) {
    body.applyForceToCenter(force);
  }
}

public class Projectile extends Obstacle {
  float xVelocity, yVelocity, r;
  
  Projectile(float x, float y, float velocity, float a, float r) {
    this.xVelocity = velocity * cos(a);
    this.yVelocity = velocity * sin(a);
    this.r = r;
    this.score = 5;
    makeBody(new Vec2(x, y));
    body.setUserData(this);
  }
  
  void show() {
    pos = box2d.getBodyPixelCoord(body);
    float a = -body.getAngle();
    
    imageMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(a);
    noFill(); stroke(0); strokeWeight(1);
    
    ellipse(0, 0, 2 * r, 2 * r);
    applyForce(forces.get("antiGravity"));
     
    popMatrix();
  }
  
  void makeBody(Vec2 center)
  {
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);
    
    FixtureDef fd = new FixtureDef();
    fd.shape=cs;
    fd.isSensor=true;
    fd.density=0;
    fd.friction=0;
    fd.restitution=0;
    
    BodyDef bd = new BodyDef();
    bd.type=BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    
    body=box2d.createBody(bd);
    body.createFixture(fd);
    body.setLinearVelocity(new Vec2(xVelocity, yVelocity));
  }
}

public class Spike extends Obstacle
{
  int orientation;
  int offset;
  int groupSize;
  Spike(float x, float y, int groupSize, int orientation) {
    this.orientation = orientation;
    this.groupSize = groupSize;
    this.offset = 0;
    this.sprite = loadImage("assets/obstacles/spike" + groupSize + ".png");
    this.score = 2 * groupSize;
    makeBody(new Vec2(x,y));
    body.setUserData(this);
  }
  
  void show() {
    pos = box2d.getBodyPixelCoord(body);
    
    rectMode(CENTER);
    pushMatrix();
    float yOffset = -7.5;
    float aOffset = 0;
    if (this.orientation==2) {
      yOffset *= -1;
      aOffset = PI;
    }
    translate(pos.x, pos.y + yOffset);
    fill(0);
    tint(255, this.alpha);

    float imageX = 20 * groupSize / 4;
    float imageY = -12.5;
    rotate(aOffset);
    imageMode(CENTER);
    image(sprite, imageX, imageY);
    
    tint(255, 255);
    popMatrix();

    this.applyForce(forces.get("antiGravity"));
    fade();
  }
  
  void makeBody(Vec2 center)
  {
    PolygonShape sd = new PolygonShape();
    Vec2[] vertices = new Vec2[4];
    int dir = this.orientation == 1 ? 1 : -1;
    // To-do: trapezoid render
    vertices[0]=box2d.vectorPixelsToWorld(new Vec2(dir * 0, dir * 10));
    vertices[1]=box2d.vectorPixelsToWorld(new Vec2(dir * 5, dir * -35));
    vertices[2]=box2d.vectorPixelsToWorld(new Vec2(dir * (groupSize * 10 - 5), dir * -35));
    vertices[3]=box2d.vectorPixelsToWorld(new Vec2(dir * (groupSize * 10), dir * 10));
    sd.set(vertices, vertices.length);
    
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    body = box2d.createBody(bd);
     
    FixtureDef fd = new FixtureDef();
    fd.isSensor = true;
    fd.shape=sd;
    fd.density=0;
    fd.friction=0;
    fd.restitution=0;

    body.createFixture(fd);
    body.setLinearVelocity(new Vec2(-gameState.get("speed"), 0));
  }
}
