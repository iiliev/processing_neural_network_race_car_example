class Corner{
  PVector position;
  Track track;
    
  Corner( float x, float y, Track t){
    position = new PVector(x,y); 
    track = t;
  }
  
  void displayCorner(){
    stroke(255);
    strokeWeight(2);
    fill(255);
    ellipse(position.x, position.y, track.radius*2, track.radius*2);
    fill(0);
  }

  Rectangle getConnectingRect( Corner other ){
    PVector dir = PVector.sub(position,other.position);
    PVector shoulder = ort( dir );
    shoulder.mult(track.radius);
    PVector point1 = PVector.add(      position,shoulder);
    PVector point2 = PVector.add(other.position,shoulder);
    shoulder.mult(-1);
    PVector point3 = PVector.add(      position,shoulder);
    PVector point4 = PVector.add(other.position,shoulder);
    return new Rectangle( point1, point2, point3, point4 );    
  }
  
  void connectCorner( Corner other ){
    strokeWeight(1);
    stroke(255);
    fill(255);
    Rectangle rect = getConnectingRect( other );
    quad( rect.a.x, rect.a.y, 
          rect.b.x, rect.b.y,
          rect.d.x, rect.d.y,
          rect.c.x, rect.c.y);
  }
  
  boolean pointOnPath( Corner other, PVector point ){
    PVector dir = PVector.sub(position,other.position);
    PVector intercept = PVector.sub(point,position);
    float iMag = intercept.mag();
    if( pow(iMag,2) > pow(track.radius,2) + pow(dir.mag(),2) ) //point is not between the two corners
      return false;
    float angle = PVector.angleBetween(dir,intercept);
    if( angle < HALF_PI )  //point is in the other direction
      return false;
    float dist = iMag * sin( angle );
    if( dist < track.radius )
      return true;
     return false;
  }

  PVector directionToPath( Corner other, PVector point ){
    PVector dir = PVector.sub(position,other.position);
    PVector intercept = PVector.sub(point,position);
    float iMag = intercept.mag();
    float angle = PVector.angleBetween(dir,intercept);
    if( angle < HALF_PI ){  //point is in the other direction
      return null;
    }
    float dist = iMag * cos( angle );
    PVector dirNorm = dir.copy();     //keep dir to see if point is outside limits
    dirNorm.normalize();
    dirNorm.mult(dist);
    PVector result =  PVector.sub( intercept, dirNorm );
    if( pow(iMag,2) > pow(result.mag(),2) + pow(dir.mag(),2) ){ //point is not between the two corners
      return null;
    }    
    return result;
  }
}

class Rectangle{
  PVector a;
  PVector b;
  PVector c;
  PVector d;
  Rectangle( PVector _a, PVector _b, PVector _c, PVector _d ){
    a = _a; b = _b; c = _c; d = _d;
  }
}

class CornerInfo{
  float   angle1;
  float distance;
  float   angle2;
  CornerInfo( float a1, float d, float a2 ){
    angle1   = a1;
    distance =  d;
    angle2   = a2;
  }  
}

class LocationInfo{
  float      angle;     
  float      distance;
  CornerInfo cornerInfo;
  LocationInfo( float a, float d, CornerInfo cI ){
    angle      =  a;
    distance   =  d;
    cornerInfo = cI;
  }
  void print(){
    println( String.format("a: %.2f; d: %.2f; a1: %.2f; d: %.2f; a2: %.2f", 
                            angle,//degrees(angle),
                            distance,
                            cornerInfo.angle1,//degrees(cornerInfo.angle1), 
                            cornerInfo.distance, 
                            cornerInfo.angle2));//degrees(cornerInfo.angle2 )) );
  }  
}

class Track{
  Corner     [] corners;
  Rectangle  [] paths;
  CornerInfo [] cornerInfo;
  float       radius  = 20;
  char        mode = 'c';   //r=run;c=create;t=test

  Track(){
    corners    = null;
    paths      = null;
    cornerInfo = null;
  }
  
  String getModeText(){
    switch(mode){
      case 'c': return "Create";  
      case 'r': return "Run";  
      case 't': return "Test";  
    }
    return "None";
  }
  
  void display(){
    strokeWeight(1);
    stroke(255);
    fill(255);  
    if( mode == 't' )    
      for( int i = 0; i < paths.length; i++ )
        quad( paths[i].a.x, paths[i].a.y, 
              paths[i].b.x, paths[i].b.y,
              paths[i].d.x, paths[i].d.y,
              paths[i].c.x, paths[i].c.y); 

    float offsetConst = radius/2+10;
    for( int i = 0; i < corners.length; i++ ){
      corners[i].displayCorner();
      text( i, corners[i].position.x+offsetConst, corners[i].position.y+offsetConst );  
    }  
  }
    
  boolean isPointOnTrack( PVector point ){
    if(corners.length==0) return false;
    for( int i=0; i < corners.length-1; i++ )
      if( corners[i].pointOnPath(corners[i+1],point))
        return true;
    if( corners[corners.length-1].pointOnPath(corners[0],point) )
      return true;
    for( int i = 0; i < corners.length; i++ ){
      if( PVector.sub(corners[i].position, point).mag() < radius )
        return true;
    } 
    return false;
  }  
  
  PVector shortestDirectionToTrack( PVector point ){
    ArrayList<PVector> directions = new ArrayList<PVector>();
    for( int i=0; i < corners.length-1; i++ )                  //check the segments
      directions.add( corners[i].directionToPath(corners[i+1],point));
    directions.add( corners[corners.length-1].directionToPath(corners[0],point) );
    for( int i=0; i < corners.length-1; i++ )                  //check the segments
      directions.add( PVector.sub( point, corners[i].position ) );
    float minDistance = Float.MAX_VALUE;
    PVector currentBest = null; //<>//
    for( PVector d : directions )
      if( d != null && d.mag() < minDistance ){ //<>//
        minDistance = d.mag();
        currentBest = d;
      }
    return currentBest;    
  }
    
  void displayBorders(){
    strokeWeight(1);
    for(int i = 0; i <= width; i+=20)
      for(int j = 0; j <= height; j+=20){
        PVector point = new PVector( i, j );
        if( isPointOnTrack( point ))
          fill( color(255,0,0) ); //red
        else
          fill( color(0,0,255) ); //blue
        ellipse(i, j, 6, 6);
      }
  }  
    
  void load(File file) {
    if (file == null) return;
    JSONObject json = loadJSONObject(file.getAbsolutePath());
    radius = json.getFloat("radius");
    JSONArray jsonCorners = json.getJSONArray("corners");
    corners = new Corner[jsonCorners.size()];
    for (int i = 0; i < jsonCorners.size(); i++) {
      JSONObject jsonCorner = jsonCorners.getJSONObject(i); 
      Corner corner = new Corner( jsonCorner.getFloat("pos_x"), jsonCorner.getFloat("pos_y"), this );
      corners[i]=corner;
    }
    paths = new Rectangle[corners.length];
    for( int i = 0; i < corners.length; i++ ){
      paths[i] = corners[i].getConnectingRect( corners[getNextCorner(i)] );
    }
    fillCornerInfo();
  }  
  
  int getNextCorner( int current ){
    if( current == corners.length-1 )
      return 0;
    return current + 1;
  }
 
  void printCI( int i, CornerInfo ci ){
    println( String.format("%d: a1: %.2f; d: %.2f; a2: %.2f", i, ci.angle1, ci.distance, ci.angle2 ) );
  }

  float getDistanceFromStart( Car car ){
    float result = 0;
    for( int i = 0; i < car.currentCorner - 2; i++ )
      result += cornerInfo[i].distance;
    if( car.currentCorner > 0 )
      result += cornerInfo[cornerInfo.length-1].distance; //this is the distance from start to corner 1
    result += PVector.sub(car.position,corners[car.currentCorner].position).mag(); //position from current corner to car
    return result;
  }

  void fillCornerInfo(){
    cornerInfo = new CornerInfo[corners.length];
    for( int i=0; i < corners.length; i++ ){
      cornerInfo[i] = getCornerInfo(i);
      //printCI(i, cornerInfo[i]); 
    }
  }
  
  CornerInfo getCornerInfo( int cornerI ){
    Corner firstCorner = corners[cornerI];

    int cornerIndex = getNextCorner( cornerI );
    Corner secondCorner = corners[cornerIndex];

    cornerIndex = getNextCorner( cornerIndex );
    Corner thirdCorner = corners[cornerIndex];

    cornerIndex = getNextCorner( cornerIndex );
    Corner fourthCorner = corners[cornerIndex];

    float distance = PVector.sub(secondCorner.position,thirdCorner.position).mag();

    PVector firstVector  = PVector.sub( firstCorner.position,secondCorner.position);
    PVector secondVector = PVector.sub(secondCorner.position, thirdCorner.position);
    PVector thirdVector  = PVector.sub( thirdCorner.position,fourthCorner.position);

    float firstAngle  = angle(firstVector,secondVector);
    float secondAngle = angle(secondVector,thirdVector);
    return new CornerInfo( firstAngle, distance, secondAngle );
  }
  
  LocationInfo getLocationInfo( Car car ){
    CornerInfo ci = cornerInfo[car.currentCorner];
    PVector shortestDist = PVector.sub(corners[getNextCorner(car.currentCorner)].position,car.position);
    float ang = angle( PVector.fromAngle(car.angle), shortestDist );
    return new LocationInfo( ang, shortestDist.mag(), ci );
  }
  
  Integer locateCar( Car car ){
    int thisCornerI = car.currentCorner;
    int nextCornerI = getNextCorner( thisCornerI );
    if( PVector.sub(corners[thisCornerI].position, car.position).mag() < radius ){ //it's on the first circle
      return thisCornerI;
    }
    if( PVector.sub(corners[nextCornerI].position, car.position).mag() < radius ){ //it's on the next circle
      return nextCornerI;
    }
    if( corners[thisCornerI].pointOnPath(corners[nextCornerI],car.position) ){
      return thisCornerI;
    }
    if( corners[nextCornerI].pointOnPath(corners[getNextCorner(nextCornerI)],car.position) ){
      return nextCornerI;
    }    
    return null;  //point is not on track
  }

}
