color RED = color(255, 125, 125);
color GREEN = color(125, 255, 125);
color BLUE = color(125, 125, 255);

final String PALEO = "paleo";
final String MARKUP = "markup";
final String INDEX = "index";
String MODE;

final String SCHOLIA = "scholia";
final String MAINTEXT = "maintext";
String TARGET;

final String E3 = "e3";
final String VB = "vb";
String MANUSCRIPT;

GUI gui = new GUI();
Screen screen = new Screen();

/**
Entry point of the code
**/
void setup(){
  //Sets the size of the screen (640x360)
  size(600, 130);
  
  //First choose what mode you're going to do
  screen.showModeButtons();
}

/**
Drawing every frame
**/
void draw(){
  //White background every frame
  background(255);
  //Update the gui
  gui.update();
  
  //Now also draw the gui
  gui.render();
}

void keyPressed(){
  screen.parseHotkey(key);
}

void mousePressed(){
  //Forward the mouseClick to all GUIObjects
  gui.mouseClick();
}

/**Shorthand form to make a new vector, useful in long constructor calls*/
PVector v(float x, float y){
  return new PVector(x, y);
}

String[] readFile(String url){
  return loadStrings(dataPath("../" + url));
}
