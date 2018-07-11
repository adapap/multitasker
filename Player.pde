class Player
{
  Body body;
  float w, h, x, y;
  int count_=0;
  boolean left=false, right=false;
  
  Player(float x, float y, float w, float h)
  {
    this.w=w; this.x=x;
    this.h=h; this.y=y;
    makeBody(new Vec2(x,y),this.w,this.h);
    body.setUserData(this);
    this.left=false; this.right=false;
  }
  
  void show()
  {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a=body.getAngle()*-1;
    
    rectMode(CENTER);
    imageMode(CENTER);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(a);
    //fill(255,0,0);
    noStroke();
    if(count_<10)
     image(dino1,0,0);
    else
     image(dino2,0,0);
    popMatrix();
    count_++;
    if(count_>20)
     count_=0;
  }
  
  void change()
  {
   gameOver=true; 
  }
  
  boolean check()
  {
    Vec2 pos=box2d.getBodyPixelCoord(body);
    return (pos.x<-w/2.0);
  }
  
  void makeBody(Vec2 center, float w, float h)
  {
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    sd.setAsBox(box2dW,box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.shape=sd;
    fd.density=1;
    fd.friction=1;
    fd.restitution=0;
    
    BodyDef bd = new BodyDef();
    bd.type=BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    
    body=box2d.createBody(bd);
    body.createFixture(fd);
    
    //body.setLinearVelocity(new Vec2(random(10,20),random(40,50)));
    //body.setAngularVelocity(0);
  }
  
  void move()
  {
    if(right)
     this.applyForce(new Vec2(10000,0));
    if(left)
     this.applyForce(new Vec2(-10000,0));
  }
  
  void applyForce(Vec2 force)
  {
    if(floor(body.getLinearVelocity().y)==0)
      body.applyForceToCenter(force);
  }
  
}
