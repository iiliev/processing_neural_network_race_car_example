import java.text.MessageFormat;
import javax.swing.JOptionPane;

int               yMetric =  0;
Track track = new Track();
Car[]   cars;
int     frameCounter = 0;
boolean running      = false; 

void setup() {
  size(800,800);
  track.load(new File(sketchPath("data/t1.json")));
  track.mode = 't';
  init();
  noLoop();
}

void draw() {
  background(color(200,200,200));
  track.display();
  for( int i = 0; i < cars.length; i++ ){
    cars[i].processLocation();
    cars[i].update();
    cars[i].render();
  }
  printBasicStats();
  frameCounter++;
}

void keyPressed() {
  if( key == 'm' ){
    track.mode = track.mode=='c' ? 't' : 'c';
  } else if (key == 'l'){                           // 'l'    Load track
    selectInput("Select a track to load:", "loadTrack", dataFile(sketchPath()));
  } else if (key == 's'){                                  // 's'    Toggle loop/noLoop
    if( running ){ noLoop(); running = false; } 
    else         {   loop(); running =  true; }
  } else if (key == 'f'){                                  // 'f'    finish race
    finishRace();
  } else if (key == CODED && keyCode == RIGHT) {
    cars[0].turningRight = true;
  } else if (key == CODED && keyCode == LEFT) {
    cars[0].turningLeft = true;
  } else if (key == CODED && keyCode ==   UP) {
    cars[0].accelerating = true;
  } else if (key == CODED && keyCode == DOWN) {
    cars[0].braking = true;
  }
}
