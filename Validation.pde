GUI gui = new GUI();

/**
Entry point of the code
**/
void setup(){
  //Sets the size of the screen (1280x720)
  size(1280, 720);
  
  TextButton b = new TextButton(new PVector(50, 50), color(255, 125, 125), "Hello World");
  b.addMouseListener(new MouseListener(){
    public void clicked(){
      println("yeah");
    }
  });
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

void mousePressed(){
  //Forward the mouseClick to all GUIObjects
  gui.mouseClick();
}
