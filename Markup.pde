class Markup {

  //The target of this paleo analysis
  String target;
  //The manuscript we're analyzing
  String manuscript;
  //The loaded markup file
  XML xml;

  //List of rs readings
  ArrayList<RSReading> rsReadings = new ArrayList<RSReading>();
  //List of personal Name readings
  ArrayList<PersNameReading> persReadings = new ArrayList<PersNameReading>();
  //List of place Name readings
  ArrayList<PlaceNameReading> placeReadings = new ArrayList<PlaceNameReading>();
  //List of XML Hierarchy or otherwise xml errors
  ArrayList<XMLError> xmlErrors = new ArrayList<XMLError>();

  /**
   Creates a new Markup validation instance
   **/
  Markup(String manuscript, String target) {
    this.target = target;
    this.manuscript = manuscript;
    loadLevels();
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
    //First do the XML analysis
    xmlAnalysis(xml, "");

    //Create a StringBuilder to handle the report
    StringBuilder reportLines = new StringBuilder();
    //First add a title and start the table with a header
    String modeString = MODE.substring(0, 1).toUpperCase() + MODE.substring(1);
    String manuscriptString = (MANUSCRIPT.equals(VB)) ? "<em>Venetus B</em>" : "<em>Upsilon 1.1</em>";
    reportLines.append("<h1>" + modeString + " for " + TARGET + " of " + manuscriptString + "</h1>");
    reportLines.append("<p>This document contains the report about the markup. This information is structured into the following categories.</p>");
    reportLines.append("<ul><li>Personal Names.</li><li>Place Names.</li><li>RS type ethnic.</li></ul>");

    /**
     PERSONAL NAMES
     **/
    reportLines.append("<h3>Personal Names</h3>"); 
    reportLines.append("<table class='table table-striped'><tr>");
    reportLines.append("<th>Reading</th><th>URN</th><th>Resolved</th><th>Description</th></tr>");
    for (PersNameReading r : persReadings) {
      reportLines.append(r.render());
    }
    //Close the table
    reportLines.append("</table>");

    /**
     PLACE NAMES
     **/
    reportLines.append("<h3>Place Names</h3>"); 
    reportLines.append("<table class='table table-striped'><tr>");
    reportLines.append("<th>Reading</th><th>URN</th><th>Resolved</th><th>Description</th></tr>");
    for (PlaceNameReading r : placeReadings) {
      reportLines.append(r.render());
    }
    //Close the table
    reportLines.append("</table>");

    /**
     RS ETHNIC
     **/
    reportLines.append("<h3>RS Ethnic</h3>"); 
    reportLines.append("<table class='table table-striped'><tr>");
    reportLines.append("<th>Reading</th><th>URN</th><th>Resolved</th><th>Description</th></tr>");
    for (RSReading r : rsReadings) {
      reportLines.append(r.render());
    }
    //Close the table
    reportLines.append("</table>");

    /**
     MISC ERROR
     **/
    if (xmlErrors.size() > 0) {
      reportLines.append("<h3 class='text-danger bg-danger'>XML Errors</h3>");
      reportLines.append("<table class='table table-striped'><tr>");
      reportLines.append("<th>XMLTag</th><th>Warning</th></tr>");
      for (XMLError e : xmlErrors) {
        reportLines.append(e.render());
      }
      //Close the table
      reportLines.append("</table>");
    }
    reportLines.append("<h4>More Info</h4>");
    reportLines.append("<p>For more guidance on allowed XML tags (TEI), please see this <a href='https://github.com/homermultitext/hmt-textmodel/wiki/TEI-elements'>link</a></p>");

    //Now when the report has been made, save it
    Report r = new Report(reportLines.toString());
    r.save("markup" + MANUSCRIPT + (TARGET.equals(SCHOLIA) ? "_scholia" : "") + ".html");
    r.open();
    //After opening, close this 
    exit();
  }

  /**
   Handles the analysis of the XML node. This has been offloaded to a separate
   function because it is fucking annoying to do any XML handlling in JAVA/Processing :(
   **/
  void xmlAnalysis(XML xmlNode, String path) {
    //Check to see if this xmlNode has children, if so, analyse them too
    XML[] children = xmlNode.getChildren();
    //Also analyse all the children
    for (XML child : children) xmlAnalysis(child, path + "/" + xmlNode.getName());
    //Now that we have forwarded all shit, check this one if it is a tag we're interested in
    switch(xmlNode.getName()) {
    case "rs":
      if (xmlNode.getString("type").equals("ethnic")) {
        rsReadings.add(new RSReading(xmlNode));
      }
      break;
    case "persName":
      persReadings.add(new PersNameReading(xmlNode));
      break;
    case "placeName":
      placeReadings.add(new PlaceNameReading(xmlNode));
      break;
    default:
    //For normal nodes, check if they are correctly implemented
      checkHierarchy(xmlNode, path);
    }
  }

  void checkHierarchy(XML node, String path) {
    String tagName = node.getName().toLowerCase();
    //If using an illegal tag, provide a warning
    if (!isAllowed(tagName)) {//Illegal tag, output a warning
      xmlErrors.add(new XMLError(path + "/" + tagName, "Illegal tag: <code>" + tagName + "</code>"));
      return;//Break here, we don't have any useful info anymore
    } else {
      //Allowed tag
      if (!checkTagLevel(node)) {
        xmlErrors.add(new XMLError(path + "/" + tagName, "Incorrect Hierarchy (invalid nesting) : <code>" + tagName + "</code>"));
      }
    }
  }
}

boolean checkTagLevel(XML node) {
  String tag = node.getName().toLowerCase();
  String parentTag = node.getParent().getName().toLowerCase();
  int tagLevel = getTagLevel(tag);
  if(tagLevel >= 10) return true;//>10 means that those tags are not really important for hierarchy
  int parentLevel = getTagLevel(parentTag);
  return parentLevel > tagLevel;
}

int getTagLevel(String tag){
  if (levelF.indexOf(tag) > -1) return 10;
  if (levelE.indexOf(tag) > -1) return 9;
  if (levelD.indexOf(tag) > -1) return 8;
  if (levelC.indexOf(tag) > -1) return 7;
  if (levelB.indexOf(tag) > -1) return 6;
  if (levelA.indexOf(tag) > -1) return 5;
  return 11;
}

ArrayList<String> levelA = new ArrayList<String>();
ArrayList<String> levelB = new ArrayList<String>();
ArrayList<String> levelC = new ArrayList<String>();
ArrayList<String> levelD = new ArrayList<String>();
ArrayList<String> levelE = new ArrayList<String>();
ArrayList<String> levelF = new ArrayList<String>();

boolean isAllowed(String tag) {
  if (levelF.indexOf(tag) > -1) return true;
  if (levelE.indexOf(tag) > -1) return true;
  if (levelD.indexOf(tag) > -1) return true;
  if (levelC.indexOf(tag) > -1) return true;
  if (levelB.indexOf(tag) > -1) return true;
  if (levelA.indexOf(tag) > -1) return true;
  return false;
}

void addToLevel(String level, String... tags) {
  for (String tag : tags) {
    switch(level) {
    case "A":
      levelA.add(tag);
      break;
    case "B": 
      levelB.add(tag);
      break;
    case "C": 
      levelC.add(tag);
      break;
    case "D": 
      levelD.add(tag);
      break;
    case "E": 
      levelE.add(tag);
      break;
    case "F":
      levelF.add(tag);
      break;
    }
  }
}

String warning(String s) {
  return "<span class='text-danger bg-danger'>" + s + "</span>";
}

/**
 Dataholder, parses RS XML node
 **/
class RSReading {
  String reading;
  String urn;
  Place place;

  //Creates a new RS reading
  RSReading(XML node) {
    reading = node.getContent();
    urn = node.getString("n");
    place = places.find(urn);
  }

  /**
   Renders this into a single table row
   **/
  String render() {
    //If no place was found, return empty
    if (place == null) return tr(td(reading) + td(urn) + td(warning("Not Resolved")) + td(warning("No Description")));
    //If a place was found, use its render function
    return place.render(reading);
  }
}

class XMLError {
  String warning;
  String desc;

  XMLError(String d, String w) {
    warning = w;
    desc = d;
  }

  String render() {
    return tr(td("<code>" + desc + "</code>") + td(warning));
  }
}

/**
 Dataholder, parses persName XML node
 **/
class PersNameReading {
  String reading;
  String urn;
  Person person;

  //Creates a new personal name reading
  PersNameReading(XML node) {
    reading = node.getContent();
    urn = node.getString("n");
    person = persons.find(urn);
  }

  /**
   Renders this into a single table row
   **/
  String render() {
    //If no place was found, return empty
    if (person == null) return tr(td(reading) + td(urn) + td(warning("Not Resolved")) + td(warning("No Description")));
    //If a place was found, use its render function
    return person.render(reading);
  }
}

/**
 Dataholder, parses placeName XML Node
 **/
class PlaceNameReading {
  String reading;
  String urn;
  Place place;

  //Creates a new placeName reading
  PlaceNameReading(XML node) {
    reading = node.getContent();
    urn = node.getString("n");
    place = places.find(urn);
  }

  /**
   Renders this into a single table row
   **/
  String render() {
    //If no place was found, return empty
    if (place == null) return tr(td(reading) + td(urn) + td(warning("Not Resolved")) + td(warning("No Description")));
    //If a place was found, use its render function
    return place.render(reading);
  }
}

/**
 Loads the different tag levels
 **/
void loadLevels() {
  addToLevel("A", "unclear", "gap", "sic");
  addToLevel("B", "foreign", "num", "w");
  addToLevel("C", "add", "del", "abbr", "expan", "sic", "corr", "orig", "reg");
  addToLevel("D", "persName", "placeName", "rs", "title");
  addToLevel("E", "q", "cit", "ref");
  addToLevel("F", "body", "teiHeader", "#text", "editor", "titlestmt", "publicationstmt", "sourcedesc", "filedesc", "teiheader", "text", "floatingText", "div", "l", "p", "item", "figDesc", "note");
}
