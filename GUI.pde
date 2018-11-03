/**
A button with some text on it
**/
class TextButton extends Button{
  //The text on the button
  String text;
  int textSize = 30;
  float margin = 8;
  
  TextButton(PVector pos, color bgColor, String text){
    super(pos, new PVector(), bgColor);
    this.text = text;
    textSize(textSize);
    this.dim = calcDim();
  }
  
  PVector calcDim(){
    PVector vec = new PVector();
    vec.y = textSize + 2 * margin;
    vec.x = textWidth(text) + 2 * margin + 2;
    return vec;
  }
  
  /**Render the textButton*/
  void render(){
    //Render the button base
    super.render();
    //Now render the text on it
    textSize(textSize);
    fill(0, 200);
    if(!outlineMode) text(text, pos.x + margin + 2, pos.y + textSize + margin);
    fill(255);
    if(outlineMode) fill(mainColor);
    text(text, pos.x - 2 + margin + 2, pos.y - 2 + textSize + margin);
  }
}

/**
A simple button class
**/
class Button extends GUIObject{
  //The color of the button
  color mainColor;
  color darkColor;
  color lightColor;
  boolean outlineMode = true;
  
  Button(PVector pos, PVector dim, color bgColor){
    //Set position and size to match.
    this.pos = pos.copy();
    this.dim = dim.copy();
    this.mainColor = bgColor;
    this.darkColor = lerpColor(bgColor, color(0), 0.1);
    this.lightColor = lerpColor(bgColor, color(255), 0.3);
  }
  
  /**
  Overwrites the default mouseListener
  **/
  void addMouseListener(MouseListener ml){
    mouseListener = ml;
  }
  
  /**Synonym for addMouseListener*/
  void setMouseListener(MouseListener ml){
    addMouseListener(ml);
  }
  
  /**
  Renders the button
  **/
  void render(){
    //First draw the shadow
    noStroke();
    fill(0, 100);
    if(!outlineMode) rect(pos.x + 4, pos.y + 4, dim.x, dim.y);
    //Draw the main button
    strokeWeight(2);
    stroke(darkColor);
    fill((underMouse ? lightColor : mainColor));
    if(outlineMode) fill(underMouse ? lightColor : 255);
    rect(pos.x, pos.y, dim.x, dim.y);
  }
  
  //No updating for a standard button?
  void update(){}
}

/**
This is the GUI Manager
**/
class GUI implements IUpdate, IRender{
  //All the objects for the GUI stuff
  ArrayList<GUIObject> objects = new ArrayList<GUIObject>();
  //The objects that need to be removed
  ArrayList<GUIObject> toRemove = new ArrayList<GUIObject>();

  /**
  Renders all objects
  **/
  void render(){
    for(GUIObject o : objects) o.render();
  }
  
  /**
  Updates all objects and keeps track of all list management
  **/
  void update(){
    //Update all objects
    for(GUIObject o : objects) o.update();
    
    //Remove any objects that need to be removed
    if(toRemove.size() > 0) {
      for(GUIObject o : toRemove) objects.remove(o);
      toRemove.clear();
    }
    
    //Do hover stuff
    for(GUIObject o: objects){
      if(o.contains(mouseX, mouseY)){
        o.mouseIsOver();
      }else{
        o.mouseIsOut();
      }
    }
  }
  
  /**Fires mouseListener for any objects that are currently Undermouse*/  
  void mouseClick(){
    for(GUIObject o : objects){
      if(o.underMouse) o.mouseListener.clicked();
    }
  }
  
  /**
  Adds a new object to the GUI
  **/
  void addObj(GUIObject o){
    objects.add(o);
  }
  
  /**
  Adds the specified object to the list of oject to be removed.s
  **/
  void removeObj(GUIObject o){
    toRemove.add(o);
  }
}

/**
Superclass for all GUIObject
**/
abstract class GUIObject implements IUpdate, IRender{
  
  //Position of the GUIObject
  PVector pos;
  //Dimension of the GUIObject
  PVector dim;
  //If this object is under the mouse
  boolean underMouse = false;
  //The default mouseListener does not do anything
  MouseListener mouseListener;
  
  /**
  Creates a new GUIObject
  **/
  GUIObject(){
    //Adds a new object to the guiManager
    gui.addObj(this);
    pos = new PVector();
    dim = new PVector();
    //Empty default mouseListener
    mouseListener = new MouseListener(){
      void clicked(){
      }
    };
  }
  
  /**
  Returns if the provided x and y coord are within
  this object's bounding box
  **/
  boolean contains(float x, float y){
     return x > pos.x && x < pos.x + dim.x && y > pos.y && y < pos.y + dim.y;
  }
  
  /**Called when the mouse hovers over*/
  void mouseIsOver(){
    if(!underMouse){//If the mouse wasn't here yet, call mouseOver
      mouseOver();
    }
    underMouse = true;
  }
  
  //Called to do mouseOver functionality
  void mouseOver(){};
  
  /**Checks to make sure mouse is set to not cover*/
  void mouseIsOut(){
    if(underMouse){
      mouseOut();
    }
    underMouse = false;
  }
  
  /**Called when the mouse leaves the object again*/
  void mouseOut(){}
  
  /**Update this GUIObject*/
  abstract void update();
  /**Render this GUIObject*/
  abstract void render();
}

/**Creates a new mouseListener*/
abstract class MouseListener{
  /**Called when this object is clicked*/
  abstract void clicked();
}
