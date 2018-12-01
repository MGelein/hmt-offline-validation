class Index{
  
  //The target of this paleo analysis
  String target;
  //The manuscript we're analyzing
  String manuscript;
  //The loaded index lines
  String[] lines;
  
  /**
  Creates a new Indexing analysis for this repo
  **/
  Index(String manuscript, String target){
    this.target = target;
    this.manuscript = manuscript;
  }
  
  /**
  Loads the file we need for analysis
  **/
  void load(){
    //The baseFile Url
    String fileName = "dse/";
    //The manuscript suffix for this manuscript
    fileName += manuscript.equals(VB) ? "msB" : "e3";
    //Do we need to add extra for scholia?
    if(target.equals(SCHOLIA)){
      fileName += "_scholia";
    }else{
      fileName += "_dse";
    }
    //Finally add the .cex extension and load
    fileName += ".cex";
    lines = readFile(fileName);
    
    for(String l : lines) println(l);
  }
  
  /**
  Starts the actual paleographical analysis
  **/
  void validate(){
    //Create a StringBuilder to handle the report
    StringBuilder reportLines = new StringBuilder();
    //First add a title and start the table with a header
    String modeString = MODE.substring(0, 1).toUpperCase() + MODE.substring(1);
    String manuscriptString = (MANUSCRIPT.equals(VB)) ? "<em>Venetus B</em>" : "<em>Upsilon 1.1</em>";
    reportLines.append("<h1>" + modeString + " for " + TARGET + " of " + manuscriptString + "</h1>");
    reportLines.append("<table class='table table-striped'><tr>");
    reportLines.append("<th>Observation</th><th>Text</th><th>Image</th><th>Comments</th></tr>");
    
    //Go through each line and check
    for(int i = 1; i < lines.length; i++){
      String reportLine = "<tr>";
      String line = lines[i];
      //Skip empty lines
      if(line.trim().length() < 1) continue;
      //Split the line in parts and check if we have exactly 4
      String[] cexParts = line.split("#");
      //Check if we have four parts
      if(cexParts.length != 4 && cexParts.length != 3){
        println("not enough parts", cexParts.length);
        //then skip this line
        continue;
      }
      //Now we know we have enough parts, try to cast the first 3 parts as URN
      URN obsUrn = new URN(cexParts[0]);
      if(! obsUrn.valid) println(i, obsUrn.error);
      URN textUrn = new URN(cexParts[1]);
      if(! textUrn.valid) println(i, textUrn.error);
      URN imgUrn = new URN(cexParts[2]);
      if(! imgUrn.valid) println(i, imgUrn.error);
      
      //Format this row of the urns, start with Obs urn
      if(obsUrn.valid){
        reportLine += td(obsUrn.object);
      }else{
        reportLine += td(obsUrn.error);
      }
      
      //Next check the textUrn
      if(textUrn.valid){
        reportLine += td(textUrn.modifier);
      }else{
        reportLine += td(textUrn.error);
      }
      
      //Then create an image in the next row
      if(imgUrn.valid){
        reportLine += td(getImageFromUrn(imgUrn, 200));
      }else{
        reportLine += td(imgUrn.error);
      }
      
      //If there is a comment, append it, if not, don't
      if(cexParts.length >= 4){
        reportLine += td(cexParts[3]);
      }else{
        reportLine += td("");
      }
      
      //Close of this table row and add to other report lines
      reportLine += "</tr>";
      reportLines.append(reportLine);
    }
    
    //Now when the report has been made, save it
    Report r = new Report(reportLines.toString());
    r.save("dse" + MANUSCRIPT + (TARGET.equals(SCHOLIA) ? "_scholia" : "") + ".html");
    r.open();
    //After opening, close this 
    exit();
  }
}
