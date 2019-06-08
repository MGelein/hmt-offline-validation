class Markers{
    //The target of this paleo analysis
  String target;
  //The manuscript we're analyzing
  String manuscript;
  //The loaded index lines
  String[] lines;
  
  /**
  Creates a new Indexing analysis for this repo
  **/
  Markers(String manuscript, String target){
    this.target = target;
    this.manuscript = manuscript;
  }
  
  /**
  Loads the markers file into memory
  **/
  void load(){
    //The baseFile Url
    String fileName = "scholion-markers/";
    //The manuscript suffix for this manuscript
    fileName += manuscript.equals(VB) ? "msB" : "e3";
    //Finally add the .cex extension and load
    fileName += ".cex";
    lines = readFile(fileName);
  }
  
  /**
  Starts the actual validation process
  **/
  void validate(){
    //The scholia database, this contains image urn lookup
    schol = new ScholiaDB();
    //Store the reportlines in this instance
    StringBuffer reportLines = new StringBuffer();
    //First add a title and start the table with a header
    String modeString = MODE.substring(0, 1).toUpperCase() + MODE.substring(1);
    String manuscriptString = (MANUSCRIPT.equals(VB)) ? "<em>Venetus B</em>" : "<em>Upsilon 1.1</em>";
    reportLines.append("<h1>" + modeString + " for " + manuscriptString + "</h1>");
    reportLines.append("<p>This document contains indexing of the scholia markers.</p>");
    
    //Add the report lines
    reportLines.append("<h3>Scholion Markers</h3>"); 
    reportLines.append("<table class='table table-striped'><tr>");
    reportLines.append("<th>Marker Reading</th><th>Marker Image</th><th>Marker Text</th><th>Scholion Image</th></tr>");
    
    //Go through all lines of the document
    for(int i = 1; i < lines.length; i++){
      //Make a new MarkerReading, parse the existing line into an object
      MarkerReading m = new MarkerReading(lines[i]);
      //Generate the HTML representation
      reportLines.append(m.getHTML());
    }
    
    //Now when the report has been made, save it
    Report r = new Report(reportLines.toString());
    r.save("scholion-markers" + MANUSCRIPT + ".html");
    r.open();
    //After opening, close this 
    exit();
  }
}

/**
Holds a signle marker reading
**/
class MarkerReading{
  //The markerString
  String marker;
  //the markerImage part
  URN markerImage;
  //The id of the scholion
  URN scholionId;
  //The text that it is linked to
  URN linkedText;
  //The image text in html
  String imgText;
  
  //Parse a new readng line
  MarkerReading(String line){
    //Split a line into parts
    String[] parts = line.split("#");
    //Remove the XML num from the tag
    marker = parts[0].replaceAll("<num>","");
    marker = marker.replaceAll("</num>","");
    //Create the URN's
    markerImage = new URN(parts[1]);
    scholionId = new URN(parts[2]);
    //Get the image text
    imgText = schol.getImageForScholion(parts[2]);
    linkedText = new URN(parts[3]);
  }
  
  /**
  Returns the HTML representation of this marker reading
  **/
  String getHTML(){
    //Create a builder to construct this
    StringBuilder b = new StringBuilder();
    b.append(td(marker));
    b.append(td(getImageFromUrn(markerImage, 100)));
    b.append(td(linkedText.modifier + sup(linkedText.getObjectWithoutModifier())));
    b.append(td(imgText));
    //Return the finished string html representation
    return tr(b.toString());
  }
}
