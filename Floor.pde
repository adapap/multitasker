class Floor
{
  float x, y, w, h;
  boolean blank;
  Body b;
  int offset;
  PImage dirtTexture = loadImage("assets/misc/dirt.png");
  
  Floor(float x, float y, float w, float h, boolean blank)
  {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    this.offset=0;
    this.blank=blank;
    
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    sd.setAsBox(box2dW,box2dH);
    
    BodyDef bd = new BodyDef();
    bd.type=BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    b=box2d.createBody(bd);
    
    b.createFixture(sd, 1);
  }
  
    void show()
  {
    noStroke();
    rectMode(CENTER);
    imageMode(CENTER);
    for(int i=0; i<=this.w; i+=50)
    {
     if(!this.blank)
      image(dirtTexture,i-this.offset%50,this.y);
    }
    if(gameState.get("active")==1)
    offset += 7;
  }
}
