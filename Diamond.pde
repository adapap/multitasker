class Diamond
{
  Body body;
  float x, y, w, h, alpha;
  boolean dead, animate;
  int count_, animation_speed=90;
  Vec2 pos;
  Diamond(float x, float y)
  { 
    this.dead=false; this.animate=false;
    this.count_=0;
    this.alpha=255;
    this.x=x; this.y=y;
    makeBody(new Vec2(x,y),21,30);
    body.setUserData(this);
    this.applyForce(new Vec2(0,-animation_speed));
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
    image(diamond,0,0);
    tint(255,255);
    popMatrix();
    if(this.animate && this.alpha>0)
     this.alpha-=15;
     
    this.applyForce(new Vec2(0,400));
    
    if(count_%180==0)
     this.applyForce(new Vec2(0,animation_speed*2));
    else if((count_-90)%180==0)
     this.applyForce(new Vec2(0,animation_speed*-2));
    count_++;
  }
  
  void killBody()
  {
    box2d.destroyBody(body);
  }
  
  boolean isDead()
  {
      pos=box2d.getBodyPixelCoord(body);
    if(pos.x<-100) 
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
    
    body.setLinearVelocity(new Vec2(-gamespeed,0));
  }
  
  void applyForce(Vec2 force)
  {
      body.applyForceToCenter(force);
  }
}
