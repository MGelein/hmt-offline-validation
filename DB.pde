//The entry with a name and image
class ScholiaEntry {
  URN imgUrn;
  URN nameUrn;

  ScholiaEntry(String u, String i) {
    imgUrn = new URN(i);
    nameUrn = new URN(u);
  }
}

//Holds all scholion urns to a DB urn
class ScholiaDB {
  //The lines that we've read that contain the defs for all URNS
  String[] lines;
  //The list of entries, defined by URN (for the scholion entry) to image URN
  ArrayList<ScholiaEntry> scholia = new ArrayList<ScholiaEntry>();

  //Creates a new DB
  ScholiaDB() {
    load();
  }

  //Start loading the urn DB
  void load() {
    String fileName = "dse/";
    //The manuscript suffix for this manuscript
    fileName += MANUSCRIPT.equals(VB) ? "msB" : "e3";
    fileName += "_scholia.cex";
    lines = readFile(fileName);

    //Now parse the lines
    parseLines();
  }

  //Parse the contents of the file
  void parseLines() {
    //Go through all lines
    for (int i = 1; i < lines.length; i++) {
      parseLine(lines[i]);
    }
  }

  //Parse a single line
  void parseLine(String l) {
    //Split into the separate CEX parts
    String[] parts = l.split("#");
    scholia.add(new ScholiaEntry(parts[0], parts[1]));
  }

  /**
   Find the right image for the provided scholion
   **/
  String getImageForScholion(String scholionUrn) {
    URN scholion = new URN(scholionUrn);
    //Go through all entries and find the correct one
    String result = warning("Unindexed scholion (" + scholionUrn + ")");
    for (ScholiaEntry e : scholia) {
      if(!scholion.valid) {
        result = warning("Malformed scholion URN (" + scholionUrn + ")");
        break;
      }
      if(!e.nameUrn.valid) continue;
      if(e.nameUrn.object.equals(scholion.object)){
        return getImageFromUrn(e.imgUrn, 300);
      }
    }
    //Return the found result, at this point this is an error
    return result;
  }
}

/**
 Database for people
 **/
class PlaceDB {

  //The list of people we have parsed
  ArrayList<Place> places = new ArrayList<Place>();

  /**Load the People Database*/
  PlaceDB() {
    load();
  }  

  /**Loads the remote Github file and parses it*/
  void load() {
    //Loads the lines of the names CEX
    String[] lines = loadStrings("https://raw.githubusercontent.com/homermultitext/hmt-authlists/master/data/hmtplaces.cex");
    //Parse all the lines
    for (String line : lines) {
      String[] parts = line.split("#");
      if (parts.length < 5) continue;
      //Populate all the parts for each person
      Place p = new Place();
      p.urn = parts[0];
      p.label = parts[1];
      p.description = parts[2];
      p.pleiades = parts[3];
      p.status = parts[4];
      if (parts.length > 5) p.redirect = parts[5];
      //Add it to the places db
      places.add(p);
    }
  }

  /**
   Find a urn from the people DB
   **/
  Place find(String urn) {
    //To lower, to increase chance of finding
    urn = urn.toLowerCase();
    for (Place p : places) {
      if (p.urn.equals(urn)) return p;
    }
    //Else, return nothing
    return null;
  }
}
/**
 Database for people
 **/
class PeopleDB {

  //The list of people we have parsed
  ArrayList<Person> persons = new ArrayList<Person>();

  /**Load the People Database*/
  PeopleDB() {
    load();
  }  

  /**Loads the remote Github file and parses it*/
  void load() {
    //Loads the lines of the names CEX
    String[] lines = loadStrings("https://raw.githubusercontent.com/homermultitext/hmt-authlists/master/data/hmtnames.cex");
    //Parse all the lines
    for (String line : lines) {
      String[] parts = line.split("#");
      if (parts.length < 6) continue;
      //Populate all the parts for each person
      Person p = new Person();
      p.urn = parts[0].toLowerCase();
      p.mf = parts[1];
      p.character = parts[2];
      p.label = parts[3];
      p.description = parts[4];
      p.status = parts[5];
      if (parts.length > 6) p.redirect = parts[6];
      //Then add that person to the list
      persons.add(p);
    }
  }

  /**
   Find a urn from the people DB
   **/
  Person find(String urn) {
    //To lower, to increase chance of finding
    urn = urn.toLowerCase();
    for (Person p : persons) {
      if (p.urn.equals(urn)) return p;
    }
    //Else, return nothing
    return null;
  }
}

/**
 Data holder for a person entry
 **/
class Person {
  String urn;
  String mf;
  String character;
  String label;
  String description;
  String status;
  String redirect;

  /**Can we use this person?*/
  boolean isAllowed() {
    return status.equals("accepted") || status.equals("proposed");
  }

  /**
   Renders a single table row for the provided person
   **/
  String render(String reading) {
    return tr(td(reading) + td(urn) + td(label) + td(description));
  }
}

/**
 Data holder for a place entry
 **/
class Place {
  String urn;
  String label;
  String description;
  String pleiades;
  String status;
  String redirect;

  /**Can we use this person?*/
  boolean isAllowed() {
    return status.equals("accepted") || status.equals("proposed");
  }

  /**
   Provides a table row render output for the analysis
   **/
  String render(String reading) {
    String labelName = label;
    //If a stoa containing link is set
    if (pleiades.indexOf("stoa") > -1) {//If the pleiades link is available, make it clickable
      labelName = "<a target='_blank' href='http://" + pleiades + "'>" + labelName + "</a>";
    }
    //Return the markup string
    return tr(td(reading) + td(urn) + td(labelName) + td(description));
  }
}
