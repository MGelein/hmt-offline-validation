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

//The String used to create the HTML document head
String HTML_HEAD = "<html><head><link rel='stylesheet' href='http://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css'>" +
"<style>body{background-image: url(https://www.interwing.nl/hmt/urn/css/bg.jpg); background-size:cover; background-attachment: fixed;}" +
"div{border-radius: 1em; margin-top: 2em; padding: 1em;}</style>" +
"</head><body class='container'><div class='col-xs-12' style='background-color:white;'>";
String HTML_TAIL = "</div></body></html>";

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

/**
Reads a file relative to the directory this is run from
**/
String[] readFile(String url){
  return loadStrings(dataPath("../" + url));
}

/**
Generates an Image URL from the specified URN
**/
String getImageFromUrn(URN urn, int size){
  //No valid url is possible if the urn is null, or is not valid
  if(urn == null || !urn.valid) return "";
  //The base url, use this for replacing stuff.
  String baseUrl = "http://www.homermultitext.org/iipsrv?OBJ=IIP,1.0&FIF=/project/homer/pyramidal/deepzoom/";
  baseUrl += "hmt/COLLECTION/OBJECT.tif&RGN=REGION&WID=" + size +"&CVT=JPEG";
  String collection = urn.getCollectionForUrl();
  String object = urn.getObjectWithoutModifier();
  String region = (urn.modifier == null) ? "" : urn.modifier;
  //Now find replace the original baseUrl
  baseUrl = baseUrl.replaceAll("COLLECTION", collection);
  baseUrl = baseUrl.replaceAll("OBJECT", object);
  baseUrl = baseUrl.replaceAll("REGION", region);
  //Return the constructed URL
  return "<img src='" + baseUrl + "'>";
}

/**
Surrounds the provided string in a <td> tag
**/
String td(String s){
  return "<td>" + s + "</td>";
}
