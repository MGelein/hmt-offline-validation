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
  String render(String reading){
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
    if(pleiades.indexOf("stoa") > -1){//If the pleiades link is available, make it clickable
      labelName = "<a target='_blank' href='http://" + pleiades + "'>" + labelName + "</a>";
    }
    //Return the markup string
    return tr(td(reading) + td(urn) + td(labelName) + td(description));
  }
}
