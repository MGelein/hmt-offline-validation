/**
The Report class is the base for all HTML reports that need to be written.
**/
class Report{
  //The data split by newlines
  String[] lines;
  String url;
  
  Report(String data){
    //Split the data by newlines and populate it like that
    lines = data.split("\n");
  }
  
  Report(String[] dataLines){
    lines = dataLines;
  }
  
  /**
  Saves the string with the name specified by the provided
  parameter, but always in the reports folder
  **/
  void save(String url){
    String fileName = dataPath("../reports/" + url);
    this.url = fileName;
    String[] totalLines = new String[lines.length + 2];
    totalLines[0] = HTML_HEAD;
    for(int i = 1; i < lines.length + 1; i++){
      totalLines[i] = lines[i - 1];
    }
    totalLines[totalLines.length - 1] = HTML_TAIL;
    saveStrings(fileName, totalLines);
  }
  
  /**
  Opens the file if it has been saved already
  **/
  void open(){
    if(url != null) launch(url);
  }
}
