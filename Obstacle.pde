static class Obstacle {
  static float lastObstaclePos = 0;
  static float threshold = 50;
  
  static int spikeIsCeiling = 1;
  
  static boolean canSpawn(float xpos) {
    return xpos - lastObstaclePos >= threshold;  
  }
}

class Spike
{
  Body body;
  Vec2 pos;
  int orientation;
  float alpha;
  boolean readyToFadeIn = false,
          readyToFadeOut = false,
          doneFadingIn = false,
          doneFadingOut = false;
  PImage sprite = loadImage("assets/obstacles/spike.png");
  Spike(float x, float y, int orientation)
  {
    this.orientation = orientation;
    makeBody(new Vec2(x,y));
    body.setUserData(this);
  }
  
  void show()
  {
    pos = box2d.getBodyPixelCoord(body);
    float a = -body.getAngle();
    
    //Fixture f = body.getFixtureList();
    //PolygonShape ps = (PolygonShape) f.getShape();
    
    rectMode(CENTER);
    pushMatrix();
    float a_off=0;
    float y_off=-20;
    if(this.orientation==2)
    {
      a_off=PI;
      y_off*=-1;
    }
    translate(pos.x, pos.y+y_off);
    rotate(a+a_off);
    fill(0);
    noStroke();
    tint(255, this.alpha);
    image(sprite, 0, 0);
    tint(255, 255);
    popMatrix();
    
    //if(this.orientation==2)
    this.applyForce(forces.get("antiGravity"));
    this.inAndOut();
  }
  
  void inAndOut()
  {
    if(pos.x <= width && !doneFadingIn)
     readyToFadeIn=true;
    
    if(readyToFadeIn)
      this.alpha += 15;
      
    if(this.alpha >= 255 && readyToFadeIn)
    {
      this.alpha=255;
      readyToFadeIn=false;
      doneFadingIn=true;
    }
    
    if(pos.x<=80 && !doneFadingOut)
     readyToFadeOut=true;
     
    if(readyToFadeOut)
     this.alpha-=25;
  }
  
  void killBody() {
    box2d.destroyBody(body);
  }
  
  boolean isDead() {
    pos = box2d.getBodyPixelCoord(body);
    if(pos.x < -100) 
    {
      killBody();
      return true;
    }
    return false;
  }
  
  void makeBody(Vec2 center)
  {
    PolygonShape sd = new PolygonShape();
    Vec2[] vertices = new Vec2[3];
    int dir = this.orientation == 1 ? 1 : -1;
    vertices[0]=box2d.vectorPixelsToWorld(new Vec2(dir * 0, dir * -50));
    vertices[1]=box2d.vectorPixelsToWorld(new Vec2(dir * -5, dir * 10));
    vertices[2]=box2d.vectorPixelsToWorld(new Vec2(dir * 5, dir * 10));
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
  
  void applyForce(Vec2 force) {
      body.applyForceToCenter(force);
  }
}
