void init(){
  //initCars(30);
  //initCarsFromFile(5,new File(sketchPath("data/NN6x25x14x4_best_car_0.json")));
  //initSingle();
  initBasic();
}

void initCars( int count ){
  cars = new Car[count];
  for( int i = 0; i < cars.length; i++ ){
    cars[i] = new Car( track, 0 );
    cars[i].rules = new RulesVD3ANN(); 
    cars[i].rules.initializeSafe();
    println(i);
    //cars[i].rules.initializeRandom();
    cars[i].id = i;
  }  
  //makeLastCarReference();
}

void initCarsFromFile( int count, File file ){
  if (file == null) return;
  JSONObject json = loadJSONObject(file.getAbsolutePath());  
  cars = new Car[count];
  for( int i = 0; i < cars.length; i++ ){
    cars[i] = new Car( track, 0 );
    cars[i].rules = new RulesVD3ANN();
    cars[i].rules.fromJSON(json.getJSONObject("rules"));
    //cars[i].recordTrace = true;
    //cars[i].recordPerformance = true;
    //if( i != 0 )
    //  cars[i].rules = cars[i].rules.mutate(); //keep the first one the same
    cars[i].id = i;
  }  
  //makeLastCarReference();
}

void initSingle(){
  cars = new Car[1];
  cars[0] = new Car(track, 0);
  cars[0].rules = new RulesVD3ANN();
  cars[0].rules.initializeSafe();
  cars[0].clr = 0;
  //cars[0].recordTrace = true;
  cars[0].id = 0;
}

void initBasic(){
  cars = new Car[2];

  cars[0] = new Car(track, 0); //car to drive manually
  cars[0].clr = 0;
  cars[0].id = 0;
  
  cars[1] = new Car(track, 0);
  cars[1].rules = new RulesVD3ANN();
  //cars[1].rules.initializeBasic();
  cars[1].rules.initializeSafe();
  cars[1].clr = 100;
  cars[1].id = 1;
}
