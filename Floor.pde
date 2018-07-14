class Floor
{
  float x, y, w, h;
  Body b;
  
  Floor(float x, float y, float w, float h)
  {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    
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
    fill(200);
    noStroke();
    rectMode(CENTER);
    rect(this.x, this.y, this.w, this.h);
  }
}
