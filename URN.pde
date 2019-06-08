class URN{
  String error = "";
  //Assume this didn't parse
  boolean valid = false;
  //The complete urn string, unparsed
  String urn;
  //The schema of the urn, this should be urn
  String schema;
  //The namespace of this urn, always Cite2Urn
  String namespace;
  //The project of this urn, always hmt
  String project;
  //The collection this object is a part of. Can be f.e. paleo, or e3bifolio
  String collection;
  //The object that is meant by this urn, can be an image, a page, or a verse
  String object;
  //The modifier of the urn, can also be a region in a image urn, or a letter in a text urn
  String modifier;
  
  /**
  Tries to parse the provided String as a Cite2Urn
  **/
  URN(String s){
    //Assign the full urn
    urn = s.toLowerCase();
    //Split the urn into it's parts
    String[] parts = urn.split(":");
    
    //It must be exactly 5 parts
    if(parts.length != 5){
      error = "A Cite2Urn or CTS Urn should always consist of 5 parts, this one consists of " + parts.length + " parts: " + urn;
      return;
    }
    
    //Now check if the first part is indeed urn
    if(! parts[0].equals("urn")){
      error = "A Cite2Urn or CTS Urn should always start with 'urn'";
      return;
    }else{
      schema = "urn";
    }
    
    //Second part should always be cite2, since that is the default namespace
    if(! parts[1].equals("cite2") && ! parts[1].equals("cts")){
      error = "A Cite2Urn or CTS Urn should always have a namespace of 'cite2' or 'cts' > " + parts[1];
      return;
    }else{
      namespace = parts[1];
    }
    
    //Third part should always be hmt or greekLit, since that is the project we're working for
    if(! parts[2].equals("hmt") && ! parts[2].equals("greeklit")){
      error = "A Cite2Urn or CTSUrn in this project should always have a project definition of 'hmt' or 'greekLit' >" + parts[2];
      return;
    }else{
      project = "hmt";
    }
    
    //Fourth part is the collection
    collection = parts[3];
    //Fifth part is the object and also region
    object = parts[4];
    if(object.indexOf("@") > -1){//If a modifier is defined, load it
      modifier = object.substring(object.indexOf("@") + 1);
    }
    
    //At the end, set to valid
    valid = true;
    
    //urn:cite2:hmt:vbbifolio.v1:vb_137v_138r@0.2222,0.2483,0.01087,0.01685
    //urn:cite2:hmt:paleo.v1:leiden_vb_1
    //URN:NS:PROJECT:COLLECTION:OBJECT@REGION
    
    //urn:cts:greekLit:tlg0012.tlg001.msB:10.387@η
  }
  
  /**
  Returns the topmost colleciton without any subcollections
  **/
  String getCollectionForUrl(){
    if(collection == null) return "";
    return collection.replaceAll("\\.", "/");
  }
  
  /**
  Returns the object without modifier
  **/
  String getObjectWithoutModifier(){
    if(modifier == null) return object;
    return object.replaceAll("@" + modifier, "");
  }
  
  //What to do when asked to print this  
  String toString(){
    return urn;
  }
  
  //Tests if the provided URN is internally the same
  boolean isIdentical(URN u){
    if(u == null || !u.valid) return false;
    return u.schema.equals(schema) && u.namespace.equals(namespace) 
    && u.project.equals(project) && u.collection.equals(collection) 
    && u.object.equals(object) && u.modifier.equals(modifier);
  }
}
