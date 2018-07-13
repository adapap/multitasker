class Player
{
  Body body;
  float w, h, x, y, r;
  int count_=0;
  boolean left=false, right=false;
  
  Player(float x, float y, float w, float h, float r)
  {
    this.w=w; this.x=x;
    this.h=h; this.y=y;
    makeBody(new Vec2(x,y), r);
    body.setUserData(this);
    this.left=false; this.right=false;
    this.r=r;
  }
  
  void show()
  {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = -body.getAngle();
    
    imageMode(CENTER);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(a);
    noFill(); stroke(0); strokeWeight(2);
    //ellipse(0, 0, 2 * r, 2 * r);

    if(count_<10)
     image(dino1,0,0);
    else
     image(dino2,0,0);

     
    popMatrix();
    if(!gameOver)
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
  
  void makeBody(Vec2 center, float r)
  {
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
  
  void move()
  {
    int dir = right ? 1 : -1;
    this.applyForce(new Vec2(0, dir * 20000));
  }
  
  void applyForce(Vec2 force)
  {
    if(floor(body.getLinearVelocity().y) == 0)
      body.applyForceToCenter(force);
  }
  
}
