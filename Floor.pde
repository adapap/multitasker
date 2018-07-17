class Floor
{
  float x, y, w, h;
  Body body;
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
    
    BodyDef bd = new BodyDef();
    bd.type=BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    body=box2d.createBody(bd);
    
    FixtureDef fd = new FixtureDef();
    fd.shape=sd;
    fd.density=0;
    fd.friction=0;
    fd.restitution=0;
    if(isWater) fd.isSensor=true;
    body.createFixture(fd);
  }
  
    void show()
  {
    noStroke();
    rectMode(CENTER);
    if(!isWater)
    {
      imageMode(CENTER);
      for(int i=0; i<=this.w; i+=50)
      {
       image(dirtTexture,i-this.offset%50,this.y);
      }
      if(gameState.get("active")==1)
      offset += 7;
    }
    else
    {
      pushMatrix();
      translate(this.x,this.y);
      rotate(radians(-30));
      fill(30,144,255,100);
      rect(0,0,this.w,this.h);
      popMatrix();
    }
  }
}
