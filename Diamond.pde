class Diamond
{
  boolean dead, animate;
  int animSpeed = 90;
  PImage diamondSprite = loadImage("assets/misc/diamond.png");
  
  Body body;
  Vec2 pos;
  float x, y, w, h, alpha;
  
  Diamond(float x, float y)
  { 
    this.dead=false;
    this.animate=false;
    this.alpha=255;
    this.x=x;
    this.y=y;
    makeBody(new Vec2(x,y), 21, 30);
    body.setUserData(this);
    this.applyForce(new Vec2(0, -animSpeed));
  }
  
  void show()
  {
    pos = box2d.getBodyPixelCoord(body);
    float a=body.getAngle()*-1;
    
    imageMode(CENTER);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(a);
    tint(255,this.alpha);
    image(this.diamondSprite, 0, 0);
    popMatrix();
    if (this.animate && this.alpha > 0)
     this.alpha -= 15;
     
    this.applyForce(forces.get("idk?"));
    
    if (gameState.get("tick") % 180 == 0) {
     this.applyForce(new Vec2(0, animSpeed * 2));
    }
    else if (gameState.get("tick") % 180 == 90) {
     this.applyForce(new Vec2(0, animSpeed * -2));
    }
  }
  
  void killBody()
  {
    box2d.destroyBody(body);
  }
  
  boolean isDead()
  {
    pos = box2d.getBodyPixelCoord(body);
    if(pos.x < -100) 
    {
      killBody();
      return true;
    }
    return false;
  }
  
  void makeBody(Vec2 center, float w, float h)
  {
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    sd.setAsBox(box2dW,box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.isSensor = true;
    fd.shape=sd;
    fd.density=0;
    fd.friction=0;
    fd.restitution=0;
    
    BodyDef bd = new BodyDef();
    bd.type=BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    
    body=box2d.createBody(bd);
    body.createFixture(fd);
    
    body.setLinearVelocity(new Vec2(-gameState.get("speed"), 0));
  }
  
  void applyForce(Vec2 force)
  {
      body.applyForceToCenter(force);
  }
}
