class RulesVD3ANN extends Rules {
  float velLimit  =   8.1;
  float mutationRate = .2; //.1;   
  NeuralNetwork posPosPosRules;
  NeuralNetwork posPosNegRules;
  NeuralNetwork posNegPosRules;
  NeuralNetwork posNegNegRules;
  
  RulesVD3ANN(){}

  void initializeRandom(){
    posPosPosRules = new NeuralNetwork(new int[]{6,12,7,4});  
    posPosNegRules = new NeuralNetwork(new int[]{6,12,7,4});  
    posNegPosRules = new NeuralNetwork(new int[]{6,12,7,4});  
    posNegNegRules = new NeuralNetwork(new int[]{6,12,7,4});  
  }

  void initializeSafe(){
    posPosPosRules = new NeuralNetwork("NN6x12x7x4_weights"); //first angle positive, second positive, third positive
    posPosNegRules = new NeuralNetwork("NN6x12x7x4_weights"); //first angle positive, second positive, third negative
    posNegPosRules = new NeuralNetwork("NN6x12x7x4_weights"); //first angle positive, second negative, third positive
    posNegNegRules = new NeuralNetwork("NN6x12x7x4_weights"); //first angle positive, second negative, third negative  
  }
 
  void jolt(){}

  float scaleVel( float vel ){
    float velLimit  =   10.;
    if( vel > velLimit ) return 1;
    return vel/velLimit;
  }
  
  float scaleDst( float dst ){
    float dstLimit  =  600.;
    return dst/dstLimit;
  }
  
  float scaleAng( float ang ){
    float angLimit  =   PI;
    return ang/angLimit;
  }

  Command getCommand( LocationInfo  li, PVector velocity ){
    boolean a0Positive = li.           angle  > 0;
    boolean a1Positive = li.cornerInfo.angle1 > 0;
    boolean a2Positive = li.cornerInfo.angle2 > 0;
        
    float a0PosVal = a0Positive ? li           .angle  : -li           .angle ;
    float a1PosVal = a1Positive ? li.cornerInfo.angle1 : -li.cornerInfo.angle1;
    float a2PosVal = a2Positive ? li.cornerInfo.angle2 : -li.cornerInfo.angle2;
    float[] input = new float[]{  scaleVel(velocity.mag()), 
                                  scaleAng(a0PosVal), 
                                  scaleDst(li.distance), 
                                  scaleAng(a1PosVal), 
                                  scaleDst(li.cornerInfo.distance), 
                                  scaleAng(a2PosVal)};
    boolean flipSign = !a0Positive; //otherwise we are losing the sign after next manipulation
    if( !a0Positive ){            
      a0Positive = !a0Positive;  
      a1Positive = !a1Positive;
      a2Positive = !a2Positive;
    }
    
    String lastRuleSet = a0Positive && a1Positive ? "pp" : "pn";
    lastRuleSet = a2Positive ? lastRuleSet+"p" : lastRuleSet+"n";
    
    Command result;
    
    switch( lastRuleSet ){
      case "ppp": result = new Command(posPosPosRules.predict(input).bin().data[0]); break; 
      case "ppn": result = new Command(posPosNegRules.predict(input).bin().data[0]); break; 
      case "pnp": result = new Command(posNegPosRules.predict(input).bin().data[0]); break; 
      case "pnn": result = new Command(posNegNegRules.predict(input).bin().data[0]); break; 
      default: throw new RuntimeException(String.format("Wrong lastRuleSet: %s",lastRuleSet));
    }
    
    if( flipSign )          
      result.flipTurn();
    return result;
  }

  Rules mutateSingleInPlace(){ return this; }
  
  JSONObject toJSON(){ 
    JSONObject jsonPosPosPosRules = posPosPosRules.toJSON();
    JSONObject jsonPosPosNegRules = posPosNegRules.toJSON();
    JSONObject jsonPosNegPosRules = posNegPosRules.toJSON();
    JSONObject jsonPosNegNegRules = posNegNegRules.toJSON();    
    JSONObject json = new JSONObject(); 
    json.setJSONObject("posPosPosRules",jsonPosPosPosRules);
    json.setJSONObject("posPosNegRules",jsonPosPosNegRules);
    json.setJSONObject("posNegPosRules",jsonPosNegPosRules);
    json.setJSONObject("posNegNegRules",jsonPosNegNegRules);
    json.setString("className",getClassName());
    return json;
  }
  
  void fromJSON( JSONObject json ){
    checkClassName( json.getString("className"));
    posPosPosRules = new NeuralNetwork(json.getJSONObject("posPosPosRules"));
    posPosNegRules = new NeuralNetwork(json.getJSONObject("posPosNegRules"));
    posNegPosRules = new NeuralNetwork(json.getJSONObject("posNegPosRules"));
    posNegNegRules = new NeuralNetwork(json.getJSONObject("posNegNegRules"));      
  }
}
