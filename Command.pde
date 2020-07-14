import java.util.BitSet;   

class Command{
  int rght = 0;
  int lft  = 1;
  int acc  = 2;
  int brk  = 3;
  int usd  = 4;
  BitSet command;
  
  Command(){
    command = new BitSet(5);  
  }
  
  Command( boolean a, boolean b, boolean r, boolean l ){
    command = new BitSet(5);
    set( a, b, r, l );
    command.set(usd,false);
  }
  
  Command( boolean a, boolean b, boolean r, boolean l, boolean u ){
    command = new BitSet(5);
    set( a, b, r, l );
    command.set(usd,u);
  }
  
  Command( float[] in ){
    command = new BitSet(5);
    boolean a = in[0]==0 ? false : true;
    boolean b = in[1]==0 ? false : true;
    boolean r = in[2]==0 ? false : true;
    boolean l = in[3]==0 ? false : true;
    set( a, b, r, l );
    command.set(usd,false);
  }
  
  void set( boolean a, boolean b, boolean r, boolean l ){
    if     (r) turnRight();
    else if(l)  turnLeft();
    else          noTurn();
    if     (a) accelerate();
    else if(b)      brake();
    else            noAcc();    
  }
  
  boolean isTurningRight(){
    return command.get(rght);
  }
  
  boolean isTurningLeft(){
    return command.get(lft);
  }
  
  boolean isAccelerating(){
    return command.get(acc);
  }
  
  boolean isBraking(){
    return command.get(brk);
  }
  
  boolean isUsed(){
    return command.get(usd);
  }

  void printC(){
    print("Actions: ");
    if( isAccelerating() ) print(  "accelerating, ");
    if( isBraking()      ) print(       "braking, ");
    if( isTurningRight() ) print( "turning right, ");
    if( isTurningLeft()  ) print(  "turning left, ");
    if( isUsed()         ) print(          "used, ");
    println();
  }
  
  void setUsed(){
    command.set(usd,true);  
  }
  
  void accelerate(){
    command.set( acc, true );
    command.set( brk, false);
  }
  
  void brake(){
    command.set( acc, false );
    command.set( brk, true  );
  }
  
  void noAcc(){
    command.set( acc, false);
    command.set( brk, false);
  }
  
  void turnRight(){
    command.set(  lft, false );
    command.set( rght, true  );
  }
  
  void turnLeft(){
    command.set(  lft, true );
    command.set( rght, false  );
  }
  
  void noTurn(){
    command.set(  lft, false );
    command.set( rght, false );
  }
  
  void turnRandom(){
    int what = (int)random(0,3);
    switch( what ){
      case 0: turnRight(); break;  
      case 1: turnLeft (); break;  
      case 2: noTurn   (); break;  
    }
  }
  void accRandom(){
    int what = (int)random(0,3);
    switch( what ){
      case 0: accelerate(); break;  
      case 1: brake     (); break;  
      case 2: noAcc     (); break;  
    }
  }
  
  void randomize(){
    turnRandom();
    accRandom();
  }
  
  void flipTurn(){
    if( isTurningRight() )
      turnLeft();
    else if( isTurningLeft() )
      turnRight();
  }
  
  void flipTurnRandom(){
    int what = (int)random(0,2);
    if( isTurningRight() )
      if( what == 0) turnLeft(); else noTurn();
    else if( isTurningLeft() )
      if( what == 0) turnRight(); else noTurn();
    else
      if( what == 0) turnRight(); else turnLeft();
  }
  
  void flipAccRandom(){
    int what = (int)random(0,2);
    if( isAccelerating() )
      if( what == 0) brake(); else noAcc();
    else if( isBraking() )
      if( what == 0) accelerate(); else noAcc();
    else
      if( what == 0) accelerate(); else brake();
  }
  
  Command flipOne(){
    float what = random(0,2.5);        //playing with chance to flip Acc or flip a turn
    if( what > 1 ) flipAccRandom ();
    else            flipTurnRandom();
    return this;
  }
  
  Command copy(){
    return new Command( isAccelerating(), isBraking(), isTurningRight(), isTurningLeft(), isUsed() );  
  }
  
  void copyTurn( Command other ){
    other.command.set(rght, command.get(rght)); 
    other.command.set( lft, command.get( lft)); 
  }
  
  void copyAcc( Command other ){
    other.command.set(acc, command.get(acc)); 
    other.command.set(brk, command.get(brk)); 
  }
}
