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
    reportLines.append("<th>Locus</th><th>Image</th><th>Page</th></tr>");
    
    //Go through each line and check
    for(int i = 1; i < lines.length; i++){
      String reportLine = "<tr>";
      String line = lines[i];
      //Skip empty lines
      if(line.trim().length() < 1) continue;
      //Split the line in parts and check if we have exactly 3
      String[] cexParts = line.split("#");
      //Check if we have three parts
      if(cexParts.length != 3){
        println("not enough parts", cexParts.length);
        //then skip this line
        continue;
      }
      //Now we know we have enough parts, try to cast the first 3 parts as URN
      URN locusUrn = new URN(cexParts[0]);
      if(! locusUrn.valid) println(i, locusUrn.error);
      URN imgUrn = new URN(cexParts[1]);
      if(! imgUrn.valid) println(i, imgUrn.error);
      URN pageUrn = new URN(cexParts[2]);
      if(! pageUrn.valid) println(i, pageUrn.error);
      
      //Format this row of the urns, start with locus urn
      if(locusUrn.valid){
        reportLine += td(locusUrn.object);
      }else{
        reportLine += td(locusUrn.error);
      }
      
      //Then create an image in the next row
      if(imgUrn.valid){
        reportLine += td(getImageFromUrn(imgUrn, target.equals(SCHOLIA) ? 500: 1000));
      }else{
        reportLine += td(imgUrn.error);
      }
      
      //Next check the textUrn
      if(pageUrn.valid){
        reportLine += td(pageUrn.urn);
      }else{
        reportLine += td(pageUrn.error);
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
