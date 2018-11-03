GUI gui = new GUI();

/**
Entry point of the code
**/
void setup(){
  //Sets the size of the screen (1280x720)
  size(1280, 720);
  
  Button b = new Button(new PVector(50, 50), new PVector(200, 100), color(255, 125, 125));
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
