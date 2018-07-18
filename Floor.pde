class Floor
{
  float x, y, w, h;
  Body body;
  Vec2 pos;
  int offset;
  boolean isWater;
  PImage dirtTexture = loadImage("assets/misc/dirt.png");
  
  Floor(float x, float y, float w, float h, boolean isWater)
  {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    this.offset=0;
    this.isWater=isWater;
    
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    sd.setAsBox(box2dW,box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.shape=sd;
    fd.density=0;
    fd.friction=0;
    fd.restitution=0;
    if (isWater) {
      fd.isSensor=true;
    }
    
    BodyDef bd = new BodyDef();
    if (!isWater) {
      bd.type=BodyType.STATIC;
    }
    else {
      bd.type = BodyType.DYNAMIC;
    }
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    body=box2d.createBody(bd);
    body.createFixture(fd);
    body.setUserData(this);
  }
  
  void show()
  {
    pos = box2d.getBodyPixelCoord(body);
    noStroke();
    rectMode(CENTER);
    if(!isWater)
    {
      imageMode(CENTER);
      for(int i=-100; i<=this.w; i+=50)
      {
       image(dirtTexture,i-this.offset%50,this.y);
      }
      if(gameState.get("active")==1)
      offset += 7;
      if(currentGravity<400) offset-=3;
    }
    else
    {
      pushMatrix();
      translate(pos.x, pos.y);
      if (gameState.get("water") < 2) {
        rotate(radians(-30));
      }
      if (gameState.get("water") > 2 && gameState.get("water") < 6) {
        rotate(radians(30));
      }
      fill(30,144,255,100);
      rect(0,0,this.w,this.h);
      popMatrix();
      applyForce(forces.get("antiGravity"));
    }
  }
  
  void changeLevel(float rate, int dir) {
    if (this.pos == null) {
      return;
    }
    if ((dir == 1 && this.pos.y > 900) || (dir == -1 && this.pos.y < 2000)) {
      body.setLinearVelocity(new Vec2(0, dir * rate));
    }
    else if ((dir == 1 && this.pos.y > 0) || (dir == -1 && this.pos.y < 900)) {
      body.setLinearVelocity(new Vec2(0, dir * 1000));
    }
    else if (gameState.get("water") == 1) {
      body.setLinearVelocity(new Vec2(0, 0));
      gameState.set("water", 2);
    }
    else if (gameState.get("water") == 4) {
      body.setLinearVelocity(new Vec2(0, 0));
      gameState.set("water", 5);
    }
  }
  
  void applyForce(Vec2 force) {
    body.applyForceToCenter(force);
  }
}
