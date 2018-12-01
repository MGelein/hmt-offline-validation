class Screen {
  //Mode Buttons
  TextButton paleoButton;
  TextButton xmlButton;
  TextButton indexButton;

  //Target buttons
  TextButton scholiaButton;
  TextButton mainButton;

  //Manuscript buttons
  TextButton e3Button;
  TextButton vbButton;
  
  //The stage of the questionairre we're in
  int stage = 0;

  void parseHotkey(char c){
    if(stage == 0){
      if(c == 'p') paleoButton.mouseListener.clicked();
      if(c == 'x' || c == 'm') xmlButton.mouseListener.clicked();
      if(c == 'i') indexButton.mouseListener.clicked();
    }else if(stage == 1){
      if(c == 's') scholiaButton.mouseListener.clicked();
      if(c == 'm' || c == 'i') mainButton.mouseListener.clicked();
    }else if(stage == 2){
      if(c == 'e' || c == 'u') e3Button.mouseListener.clicked();
      if(c == 'v' || c == 'b') vbButton.mouseListener.clicked();
    }//Else ignore
  }

  /**
   Creates and initializes the mode buttons
   **/
  void showModeButtons() {
    stage = 0;
    paleoButton = new TextButton(v(10, 40), RED, "Paleography (p)");
    paleoButton.setMouseListener(new MouseListener() {
      public void clicked() {
        MODE = PALEO;
        removeModeButtons();
      }
    }
    );
    xmlButton = new TextButton(v(220, 40), BLUE, "XML Markup (x/m)");
    xmlButton.setMouseListener(new MouseListener() {
      public void clicked() {
        MODE = MARKUP;
        removeModeButtons();
      }
    }
    );
    indexButton = new TextButton(v(440, 40), GREEN, "Indexing (i)");
    indexButton.setMouseListener(new MouseListener() {
      public void clicked() {
        MODE = INDEX;
        removeModeButtons();
      }
    }
    );
  }

  void removeModeButtons() {
    paleoButton.die();
    xmlButton.die();
    indexButton.die();

    showTargetButtons();
  }

  /**
   Shows target (Scholia/maintext) selection
   **/
  void showTargetButtons() {
    stage = 1;
    scholiaButton = new TextButton(v(100, 40), RED, "Scholia (s)");
    scholiaButton.addMouseListener(new MouseListener() {
      public void clicked() {
        TARGET = SCHOLIA;
        removeTargetButtons();
      }
    }
    );
    mainButton = new TextButton(v(350, 40), BLUE, "Maintext (m/i)");
    mainButton.addMouseListener(new MouseListener() {
      public void clicked() {
        TARGET = MAINTEXT;
        removeTargetButtons();
      }
    }
    );
  }

  //Removes the target buttons and shows the manuscript seleciton button
  void removeTargetButtons() {
    scholiaButton.die();
    mainButton.die();

    showManuscriptButtons();
  }

  /**Shows the buttons for manuaeript selection*/
  void showManuscriptButtons() {
    stage = 2;
    e3Button = new TextButton(v(90, 40), RED, "Upsilon 1.1 (u/e)");
    e3Button.addMouseListener(new MouseListener(){
      public void clicked(){
        MANUSCRIPT = E3;
        removeManuscriptButtons();
      }
    });
    vbButton = new TextButton(v(340, 40), BLUE, "Venetus B (v/b)");
    vbButton.addMouseListener(new MouseListener(){
      public void clicked(){
        MANUSCRIPT = VB;
        removeManuscriptButtons();
      }
    });
  }
  
  //Removes the manuscript buttons and prepares for validation
  void removeManuscriptButtons(){
    e3Button.die();
    vbButton.die();
    
    validate();
  }
  
  /**
  Start the actual validation by forwarding the work to the appropriate module
  **/
  void validate(){
    if(MODE.equals(PALEO)){
      Paleo p = new Paleo(MANUSCRIPT, TARGET);
      p.load();
      p.validate();
    }else if(MODE.equals(INDEX)){
      Index i = new Index(MANUSCRIPT, TARGET);
      i.load();
      //i.validate();
    }
  }
}


interface IUpdate {
  /**Updates this object*/
  void update();
}

interface IRender {
  /**Renders this object*/
  void render();
}
