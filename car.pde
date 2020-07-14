class Car{
  boolean accelerating = false, turningLeft = false, turningRight = false, braking = false;
  PVector position;
  PVector velocity;
  float drag = .96;    //.96 //the larger the weaker the drag; .92 worked for RulesDA
  float angle = -HALF_PI;  //point it wherever you want
  float angularVelocity = 0;
  float angularDrag = 0.9;
  float power = 0.40;      //.1
  float turnSpeed = 0.01;
  float brake_power = 0.9; //0.95; //the larger the weaker the brakes
  float r = 5;

  boolean crashed;
  boolean finished;
  boolean forceFinished;
  Track   track;
  Rules   rules;
  int     currentCorner;
  int     timer;
  float   distancePassed;
  float   distanceFromStart;
  int     clr;
  int     id;
  boolean isReferenceCar;
  ArrayList<PVector> trace;
  boolean recordTrace;
  
  Car( Track t, int corner ){
    track    = t;
    r = 5.0;    //rendering parameter
    rules = null;
    clr = int(random(255));
    id    = 0;
    isReferenceCar    = false;
    recordTrace       = false;
    atCorner(corner);
  }

  void atCorner( int corner ){
    int nextCorner = track.getNextCorner( corner );
    position = track.corners[corner].position.copy();
    position.x += random(-5,5);
    position.y += random(-5,5);
    velocity     = new PVector(0, 0);
    currentCorner     = corner;
    PVector betweenCorners = PVector.sub(track.corners[nextCorner].position,track.corners[corner].position); 
    angle = angle(betweenCorners,new PVector(-1,0));   //where the car points to initially   
    crashed       = false;
    finished      = false;
    forceFinished = false;
    timer             = 0;
    distancePassed    = 0;
    distanceFromStart = 0;
    trace             = new ArrayList<PVector>();
  }

  void processLocation(){
    Integer segmentIndex = track.locateCar(this);
    if( segmentIndex == null ){ //car is not on track
      setCrashed();
      return;
    }
    if( segmentIndex < currentCorner ){ //we are back at the start/finish
      setFinished();
    }
    currentCorner = segmentIndex;
    
    if( rules == null ) return; //we are driving by hand
    LocationInfo li = track.getLocationInfo(this);
    
    Command command = rules.getCommand( li, velocity );    
    //println(String.format("Car %d; Corner: %d; %s; %s, acc: %.2f; trn: %.2f", id, currentCorner, rules.lastKey, rules.lastRuleSet, command.x, command.y ));    
    
    if( command.isAccelerating() )
      accelerating = true;
    else if( command.isBraking() )
      braking = true;
    if( command.isTurningRight() )
      turningRight = true;
    else if( command.isTurningLeft() )
      turningLeft = true;
  }
  
  void update() {
    if( crashed || finished ) return;    
    timer    = frameCounter;

    if (accelerating) {
      PVector delta = PVector.fromAngle(angle);
      delta.mult(power);
      velocity.add(delta);
    } else if (braking) {
      velocity.mult(brake_power);
    }
    if (turningLeft) {
      angularVelocity -= turnSpeed;
    }
    if (turningRight) {
      angularVelocity += turnSpeed;
    }
    position.add(velocity);
    distancePassed += velocity.mag();
    velocity.mult(drag);
    angle += angularVelocity;
    angularVelocity *= angularDrag;
    accelerating = false; turningLeft = false; turningRight = false; braking = false;

    if( recordTrace )
      trace.add(position.copy());
  }
  
  void setCrashed(){
    crashed = true;
    velocity.mult(0);
  }
  
  void setFinished(){
    finished = true;
    velocity.mult(0);
  }

  void setForceFinished(){
    forceFinished = true;
    velocity.mult(0);
  }

  void render() {
    stroke(0);
    strokeWeight(1);
    pushMatrix();
    fill(clr);
    translate(position.x, position.y);
    rotate(angle + radians(90));
    //rect(0, 0, 20, 10);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
    if( recordTrace ){
      beginShape();                                  //Draw trail
      stroke(clr);
      strokeWeight(1);
      noFill();
      for(PVector v1: trace) vertex(v1.x,v1.y);
      endShape();
    }
  }
  
  void save(String fileName) {
    if( fileName == null ) return;
    JSONObject jsonRules = rules.toJSON();
    JSONObject json = new JSONObject();
    json.setJSONObject("rules",jsonRules);
    saveJSONObject(json, "data/"+fileName+".json");
  }
  
  void load(File file) {
    if (file == null) return;
    JSONObject json = loadJSONObject(file.getAbsolutePath());
    rules.fromJSON(json.getJSONObject("rules"));
  }
  
}
