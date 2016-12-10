import org.puredata.processing.PureData;

PureData pd;

//Constants
int numberOfRedPoints = 16;
int maxNumberOfPoints = 1000;
int radiusOfWhitePoints = 1;
int radiusOfRedPoints = 3;
int radiusOfYellowPoints = 5;

//Variables
int[][] points;
int[] redPoints;
int numberOfPoints;
int currentPosition;
int nextPosition;

boolean drawing = false;
boolean moving = false;

TimeLine moveTimer;
TimeLine stopTimer;

void setup() {
  frameRate(100);
  size(800, 800);
  points = new int[maxNumberOfPoints][2];
  redPoints = new int[numberOfRedPoints];
  numberOfPoints = 0;

  moveTimer = new TimeLine(300);
  stopTimer = new TimeLine(50);

  pd = new PureData(this, 44100, 0, 2);
  // pd.unpackAndOpenPatch("test.tar", "test.pd");
  // pd.unpackAndOpenPatch("test3.tar", "test3.pd");
  // pd.unpackAndOpenPatch("test4.tar", "test4.pd");
  pd.openPatch("test4.pd");

  pd.start();
}
void draw() {
  background(0);
  debug();
  display();

  if ( drawing ) {
    addPoint();
  }
  else {
    displayMovingPoint();
  }
}
void exit(){
  endOSC();
  super.exit();//let processing carry with it's regular exit routine
}

/*
START DRAWING*/
void mousePressed() {
  drawing = true;
  clearPoints();
  endOSC();

  // pd.sendFloat("pitch", (float)mouseX / (float)width); // Send float message to symbol "pitch" in Pd.
  // pd.sendFloat("volume", (float)mouseY / (float)height);
}
/*
END DRAWING*/
void mouseReleased() {
  drawing = false;
  currentPosition = 0;
  nextPosition = 1;
  updateRedPoints();
  moving = true;
  moveTimer.startTimer();
  startOSC();
}


//Other Function
void addPoint() {
  if ( numberOfPoints < maxNumberOfPoints ) {
    points[numberOfPoints][0] = mouseX;
    points[numberOfPoints][1] = mouseY;
    numberOfPoints++;
  }
}
void updateRedPoints() {
  float k = 1.0 / numberOfRedPoints;
  for (int i = 0; i < numberOfRedPoints; i++) {
    redPoints[i] = floor( lerp(0, numberOfPoints, i * k) );
  }
}
void clearPoints() {
  numberOfPoints = 0;
}
void display() {
  for (int i = 0; i < numberOfPoints; i++) {
    noStroke();
    fill(255);
    ellipse(points[i][0], points[i][1],
            2 * radiusOfWhitePoints, 2 * radiusOfWhitePoints);
  }

  if ( !drawing ) {
    for (int i = 0; i < numberOfRedPoints; i++) {
      noStroke();
      fill(255, 0, 0);
      ellipse(points[redPoints[i]][0],
              points[redPoints[i]][1],
              2 * radiusOfRedPoints,
              2 * radiusOfRedPoints);
    }


  }
}
void displayMovingPoint() {
  float x = points[redPoints[nextPosition]][0];
  float y = points[redPoints[nextPosition]][1];

  if ( moving ) {
    if ( moveTimer.liner() < 1 ) {
      x = lerp ( points[redPoints[currentPosition]][0],
                       points[redPoints[nextPosition]][0],
                       moveTimer.liner() );
      y = lerp ( points[redPoints[currentPosition]][1],
                       points[redPoints[nextPosition]][1],
                       moveTimer.liner() );
    }
    else {
      //println("send signal!");
      sendOSC();
      stopTimer.startTimer();
      moving = false;
    }
  }
  else {
    if ( stopTimer.liner() == 1 ) {
      positionUpdate();
      moving = true;
      moveTimer.startTimer();
    }
  }

  noStroke();
  fill(255, 255, 0);
  ellipse(x, y,
         2 * radiusOfYellowPoints, 2 * radiusOfYellowPoints);
}
void positionUpdate() {
  currentPosition = ( currentPosition + 1 ) % numberOfRedPoints;
  nextPosition = ( currentPosition + 1 ) % numberOfRedPoints;
}
void sendOSC() {
  // OscMessage msg = new OscMessage("/point");
  float x = map( points[redPoints[nextPosition]][0],
                 0, width, 0, 1);
  float y = map( points[redPoints[nextPosition]][1],
                 height, 0, 0, 1); //from low to high
  // msg.add( x );
  // msg.add( y );
  // oscP5.send(msg, other);
  println("x:" + str(x) + " y:" + str(y));
  pd.sendFloat("x", (float)x);
  pd.sendFloat("y", (float)y);
}
void startOSC() {
  // OscMessage msg = new OscMessage("/start");
  // oscP5.send(msg, other);
  pd.sendFloat("start", (float)1.0);

}
void endOSC() {
  // OscMessage msg = new OscMessage("/end");
  // oscP5.send(msg, other);
  pd.sendFloat("end", (float)0.0);
}
void debug() {
  // println("moveTimer: state=" + str(moveTimer.state) + " liner=" + str(moveTimer.liner()));
  // println("stopTimer: state=" + str(stopTimer.state) + " liner=" + str(stopTimer.liner()));
  // println("currentPosition : " + str(currentPosition));
  // println("frameRate : " + str(frameRate));

  // println("red points index :");
  // printArray(redPoints);


}
