class Markup {

  //The target of this paleo analysis
  String target;
  //The manuscript we're analyzing
  String manuscript;
  //The loaded markup file
  XML xml;

  /**
   Creates a new Markup validation instance
   **/
  Markup(String manuscript, String target) {
    this.target = target;
    this.manuscript = manuscript;
  }

  /**
   Loads the file we need for analysis
   **/
  void load() {
    //The baseFile Url
    String fileName = "editions/";
    //What is the folder for the target?
    fileName += target.equals(SCHOLIA) ? "scholia/": "iliad/";
    //The manuscript suffix for this manuscript
    fileName += manuscript.equals(VB) ? "vb" : "e3";
    fileName += target.equals(SCHOLIA) ? "_scholia": "_iliad";
    //Finally add the .xml extension and load
    fileName += ".xml";
    //Load the XML
    xml = readXML(fileName);
  }

  /**
   Start the validation for the Markup for the provided files
   **/
  void validate() {
    //Create a StringBuilder to handle the report
    StringBuilder reportLines = new StringBuilder();
    //First add a title and start the table with a header
    String modeString = MODE.substring(0, 1).toUpperCase() + MODE.substring(1);
    String manuscriptString = (MANUSCRIPT.equals(VB)) ? "<em>Venetus B</em>" : "<em>Upsilon 1.1</em>";
    reportLines.append("<h1>" + modeString + " for " + TARGET + " of " + manuscriptString + "</h1>");
    //reportLines.append("<table class='table table-striped'><tr>");
    //reportLines.append("<th>Observation</th><th>Text</th><th>Image</th><th>Comments</th></tr>");
    
    //Now when the report has been made, save it
    Report r = new Report(reportLines.toString());
    r.save("dse" + MANUSCRIPT + (TARGET.equals(SCHOLIA) ? "_scholia" : "") + ".html");
    r.open();
    //After opening, close this 
    exit();
  }
}
