int nextY( boolean reset ){
  if (reset) yMetric = 0;
  yMetric += 20;
  return yMetric;
}

void printBasicStats(){
  fill(0);
  text(String.format("FPS: %.2f; frames: %d", frameRate, frameCounter)               , 10, nextY( true  ));
  text(String.format("Mode: %s", track.getModeText())                                , 10, nextY( false ));
  
}

PVector ort( PVector orig ){
  PVector result = new PVector(0,0);
  result.x = -orig.y;
  result.y = orig.x;
  result.normalize();
  return result;
}

float angle(PVector v1, PVector v2) {  //PVector.angleBetween returns results between 0..Pi
  float a = atan2(v2.y, v2.x) - atan2(v1.y, v1.x);
  if (a >   PI) a -= TWO_PI;   //map to -PI..PI
  if (a <= -PI) a += TWO_PI;
  return a;
}

void finishRace(){
  for( int i = 0; i < cars.length; i++ )
    cars[i].setForceFinished();
}

void makeLastCarReference(){
  cars[cars.length-1].rules = new RulesVD3ANN();
  cars[cars.length-1].rules.initializeBasic();
  cars[cars.length-1].clr = 255; //make it white
  cars[cars.length-1].isReferenceCar = true;
}

Car getReferenceCar( int corner ){
  Car car = new Car(track, corner );
  car.rules = new RulesVD3ANN();
  car.rules.initializeBasic();
  car.clr = 255;
  car.isReferenceCar = true;
  return car;
}
