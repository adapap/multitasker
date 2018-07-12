class Spike
{
  Body body;
  int place;
  Spike(float x, float y, int place)
  {
    this.place=place;
    makeBody(new Vec2(x,y));
    body.setUserData(this);
  }
  
  void show()
  {
    Vec2 pos=box2d.getBodyPixelCoord(body);
    float a = body.getAngle()*-1;
    
    Fixture f = body.getFixtureList();
    PolygonShape ps = (PolygonShape) f.getShape();
    
    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(a);
    fill(0);
    noStroke();
    beginShape();
    for (int i = 0; i < ps.getVertexCount(); i++) {
      Vec2 v = box2d.vectorWorldToPixels(ps.getVertex(i));
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
    popMatrix();
    
    //if(this.place==2)
     this.applyForce(new Vec2(0,400));
  }
  
  void killBody()
  {
    box2d.destroyBody(body);
  }
  
  boolean isDead()
  {
    Vec2 pos=box2d.getBodyPixelCoord(body);
    if(pos.x<-100) 
    {
      killBody();
      return true;
    }
    return false;
  }
  
  void change()
  {
   gameOver=true; 
  }
  
  void makeBody(Vec2 center)
  {
    PolygonShape sd = new PolygonShape();
    Vec2[] vertices = new Vec2[3];
    if(this.place==1)
    {
       vertices[0]=box2d.vectorPixelsToWorld(new Vec2(0,-50));
       vertices[1]=box2d.vectorPixelsToWorld(new Vec2(-5,10));
       vertices[2]=box2d.vectorPixelsToWorld(new Vec2(5,10));
    }
    if(this.place==2)
    {
       vertices[0]=box2d.vectorPixelsToWorld(new Vec2(0,50));
       vertices[1]=box2d.vectorPixelsToWorld(new Vec2(5,-10));
       vertices[2]=box2d.vectorPixelsToWorld(new Vec2(-5,-10));
    }
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

     body.setLinearVelocity(new Vec2(-gamespeed,0));
  }
  
  void applyForce(Vec2 force)
  {
      body.applyForceToCenter(force);
  }
}
