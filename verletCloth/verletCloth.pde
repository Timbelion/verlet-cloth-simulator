

int numberOfPoints = 400, numberOfSticks;
int lastMouseX, lastMouseY, mouseDragx, mouseDragy;
boolean mouseDown = false;

point[] points;
stick[] sticks;

void setup(){
  size(1280, 720);
  int high = int(sqrt(numberOfPoints));
  int low = int(sqrt(numberOfPoints)-1);
  numberOfSticks = low * high * 2;
  
  points = new point[numberOfPoints];
  sticks = new stick[numberOfSticks];
  
  int x = 500, y = 50;
  int stickIndex = 0;
  for (int i=0; i<high; i++){
    for (int j=0; j<high; j++){
      int index = j + i*high;
      if ((index >= 0 && index < high) || index == numberOfPoints-1 || index == numberOfPoints-high) 
      {
        points[index] = new point(x, y, x, y, 1, 0.9, true);
      }
      else {
        points[index] = new point(x, y, x, y, 1, 0.9, false);
      }
      
      x+=10;
    }
    x=500;
    y+=10;
  }
  
  for (int i=0; i<high; i++){
    for (int j=0; j<low; j++){
      int index = j + i*high;
      sticks[stickIndex] = new stick(points[index], points[index+1], pointsLength(points[index], points[index+1]));
      stickIndex++;
    }
  }
  
  for (int i=0; i<high; i++){
    for (int j=0; j<low; j++){
      int index = j*high + i;
      //print(index + " ");
      sticks[stickIndex] = new stick(points[index], points[index+high], pointsLength(points[index], points[index+high]));
      stickIndex++;
    }
   // println("");
  }
}

void draw() {
  background(255);
  fill(0);
  text("FPS: " + frameRate, 20, 20);
  text("gravity: " + points[0].gravity, 20, 40);
  text("damping: " + points[0].friction, 20, 60);
  text("points: " + numberOfPoints, 20, 80);
  text("edges: " + numberOfSticks, 20, 100);
  calculateMouseMove();
  updatePoints();
  updateSticks();
  constrainPoints();
  renderSticks();
  renderPoints();
}

void updatePoints(){
  for (int i=0; i<points.length; i++){
    point p = points[i];
    float mouseDistance = 0;
    if (!p.isStatic){      
      float velx = (p.x - p.oldx) * p.friction;
      float vely = (p.y - p.oldy) * p.friction;
      p.oldx = p.x; 
      p.oldy = p.y;
      float diffx = mouseX - p.x;
      float diffy = mouseY - p.y;
      mouseDistance = sqrt(diffx * diffx + diffy * diffy);
      p.x = p.x + velx;
      p.y = p.y + vely + p.gravity;
      p.x += (mouseDragx / mouseDistance) * 8;
      p.y += (mouseDragy / mouseDistance) * 8;
    }
    
  }
}

void constrainPoints(){
  for (int i=0; i<points.length; i++){
    point p = points[i];
    float velx = (p.x - p.oldx) * p.friction;
    float vely = (p.y - p.oldy) * p.friction;
    
    if (p.x >= width) {p.x = width; p.oldx = p.x + velx;}
    else if (p.x <= 0) {p.x = 0; p.oldx = p.x + velx;}
    else if (p.y >= height) {p.y = height; p.oldy = p.y + vely;}
    else if (p.y <= 0) {p.y = 0; p.oldy = p.y + vely;}
  }
}

void renderPoints(){
  for (int i=0; i<points.length; i++){
    point p = points[i];
    fill(0);
    circle(p.x, p.y, 4);
  }
}

void updateSticks(){
  for (int i=0; i<sticks.length; i++){
    stick s = sticks[i];
    float diffx = s.p1.x - s.p2.x;
    float diffy = s.p1.y - s.p2.y;
    float newLen = sqrt(diffx * diffx + diffy * diffy);
    float difference = s.len - newLen;
    s.tension = abs(difference);
    float per = difference / newLen / 2;
    float offsetx = diffx * per;
    float offsety = diffy * per;
    if (s.tension < 80){
      if (!s.p1.isStatic){ 
        s.p1.x += offsetx;
        s.p1.y += offsety;
      }
      if (!s.p2.isStatic){
        s.p2.x -= offsetx;
        s.p2.y -= offsety;
      }
    }
  }
}

void renderSticks(){
  for (int i=0; i<sticks.length; i++){
    stick s = sticks[i];
    if (s.tension < 80){
      stroke(lerpColor(color(0, 0, 255), color(255, 0, 0), map(s.tension, 0, 30, 0, 1)));
      line(s.p1.x, s.p1.y, s.p2.x, s.p2.y);
    }
  }
}

float pointsLength(point p1, point p2){
  float diffx = p1.x - p2.x;
  float diffy = p1.y - p2.y;
  return sqrt(diffx * diffx + diffy * diffy);
}

void mousePressed(){
  mouseDown = true;
  lastMouseX = mouseX; lastMouseY = mouseY;
}

void mouseReleased(){
  mouseDown = false;
  mouseDragx = 0;
  mouseDragy = 0;
}

void calculateMouseMove(){
  if (mouseDown){
    stroke(0);
    line(mouseX, mouseY, lastMouseX, lastMouseY);
    
    mouseDragx = mouseX - lastMouseX;
    mouseDragy = mouseY - lastMouseY;
    
    lastMouseX = mouseX; lastMouseY = mouseY;
  }
}
