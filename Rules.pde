class Rules{
  float velLimit  =   8.1;
  float dstLimit  =  600.;
  float angLimit  =   PI; //180 degrees

  float[]  velocityT;
  float[]    anglesT;
  float[]      distT;
  
  Rules(){}
  void initializeBasic(){}
  void initializeRandom(){}
  void initializeSafe(){}

  void joltRules( HashMap<String,Command> ruleMap){
    for(String key: ruleMap.keySet())
      if( (int)random(0,3) == 0 )           //33% chance to mutate
        ruleMap.get(key).flipOne();
  }

  void jolt(){}
  
  //String getKey( float v, float a0, float d0, float a1 ){ return ""; }
  
  float getTier( float[] fl, float var ){
    for( int i = 0; i < fl.length; i++ )
      if( var <= fl[i] )
        return fl[i];
    throw new RuntimeException(String.format("Above max tier: %.2f; var: %.2f",fl[fl.length-1],var));
  }

  String singleKey( float arg ){
    return arg == Float.MAX_VALUE ? "m" : String.format("%.2f",arg);
  }
  
  Command getCommand( LocationInfo  li, PVector velocity ){ return null; }

  Command useCommand( HashMap<String,Command> rules, String key ){
    Command command = rules.get(key);
    command.setUsed();
    return command;
  }
  
  HashMap<String,Command> combineRulesMap( HashMap<String,Command> rules1, HashMap<String,Command> rules2 ){
    HashMap<String,Command> result = new HashMap<String,Command>();
    for (Map.Entry me : rules1.entrySet()) {
      Command newCommand   = new Command();
      Command thisCommand  = (Command)me.getValue();
      Command otherCommand = (Command)rules2.get(me.getKey());
      if( int( random(0,2) ) == 0 )  thisCommand.copyAcc (newCommand);//pick acceleration
      else                          otherCommand.copyAcc (newCommand);
      if( int( random(0,2) ) == 0 )  thisCommand.copyTurn(newCommand);//pick angle
      else                          otherCommand.copyTurn(newCommand);
      result.put((String)me.getKey(), newCommand);
    }    
    return result;
  }
  
  HashMap<String,Command> deepCopyAndMutate( HashMap<String,Command> rules ){
    HashMap<String,Command> result = new HashMap<String,Command>();
    for (Map.Entry me : rules.entrySet()){
      Command command = ((Command)me.getValue()).copy();
      float probability = random( 0, 50 );                //2% chance to mutate, flipOne() has another probability
      if( command.isUsed() && probability < 1 )
        result.put((String)me.getKey(), command.flipOne()); //mutate
      else
        result.put((String)me.getKey(), command);           //don't mutate
    }
    return result;
  }
      
  Rules combine( Rules other ){ return other; }
  
  Rules              mutate(){ return this; }
  Rules mutateSingleInPlace(){ return this; }
 
  void putRandomCommand( HashMap<String,Command> ruleMap, String key ){
    ruleMap.put( key, new Command( random(1) > .5 ? true : false,
                                   random(1) > .5 ? true : false,
                                   random(1) > .5 ? true : false,
                                   random(1) > .5 ? true : false ));
  }
  
  JSONArray rulesToJSON( HashMap<String,Command> ruleMap){
    JSONArray  jsonRuleMap = new JSONArray();
    int counter = 0;
    for(String key: ruleMap.keySet()){
      //println(key);
      JSONObject jsonRule = new JSONObject();
      Command val = ruleMap.get(key);
      jsonRule.setString("key",key);
      jsonRule.setInt("acc" ,val.isAccelerating()?1:0);
      jsonRule.setInt("brk" ,val.     isBraking()?1:0);
      jsonRule.setInt("rght",val.isTurningRight()?1:0);
      jsonRule.setInt("lft" ,val. isTurningLeft()?1:0);
      jsonRule.setInt("usd" ,val.        isUsed()?1:0);  //write but don't read for now
      jsonRuleMap.setJSONObject(counter,jsonRule);
      counter++;
    }
    return jsonRuleMap;
  }

  HashMap<String,Command> rulesFromJSON( JSONArray jsonRuleMap){
    HashMap<String,Command> ruleMap = new HashMap<String,Command>();
    for(int i = 0; i < jsonRuleMap.size(); i++){
      JSONObject rule = jsonRuleMap.getJSONObject(i);
      String key = rule.getString("key");
      Command val = new Command( rule.getInt("acc" )==1 ? true : false,
                                 rule.getInt("brk" )==1 ? true : false,
                                 rule.getInt("rght")==1 ? true : false,
                                 rule.getInt("lft" )==1 ? true : false );
      ruleMap.put(key,val);
    }
    return ruleMap;
  }

  String getClassName(){
    return getClass().getName().split("\\$")[1];
  }

  void checkClassName( String className ){
    if( !className.equals(getClassName()) )
      throw new RuntimeException( "Class names don't match: " + className + " " + getClassName () );
  }

  JSONObject toJSON(){ return new JSONObject(); }
  void fromJSON( JSONObject json ){}
  void printR(){}

}
