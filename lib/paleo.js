const { URN } = require('./urn');

const BAD_URN = "<span class='badmatch text-warning'>Malformed URN</span>";
/**
 * Validates the given string file, returns an MD report
 */
exports.validatePaleo = function (file) {
    //Divide the file up in lines and drop the first line (the header);`
    file = file.replace('\r', '');
    var lines = file.split("\n");
    lines.splice(0, 1);

    //Create the empty report string;
    var report = "# Verification of Paleography\n";
    //Add the table header
    report += "| Record | Reading | Image |\n| :------------- | :------------- | :------------- |\n"
    //Now loop through all the lines and evaluate all parts
    var parts = []; var reportLine;
    for (var i = 0; i < lines.length; i++) {
        //Skip empty lines
        if (lines[i].trim().length == 0) continue;
        lines[i] = lines[i].replace(/\s/g, '');
        //Make the default line
        reportLine = "| RECORD | READING | IMAGE |\n";
        //Split the columns
        parts = lines[i].split("#");
        console.log(parts);
        //If there are not 4 parts, please stop
        if (parts.length != 4 && parts.length != 3 && parts.length != 5) {
            reportLine.replace("READING", "Wrong number of columns in line " + (i + 2));
            report += reportLine;
            //Continue with the next line
            continue;
        }

        //Try to parse the record URN
        var recordURN = new URN(parts[0]);
        if (recordURN) {
            reportLine = reportLine.replace("RECORD", recordURN.urnString);
        } else {
            reportLine = reportLine.replace("RECORD", BAD_URN);
        }

        //Try to parse the record URN
        var readingURN = new URN(parts[1]);
        if (readingURN) {
            reportLine = reportLine.replace("READING", readingURN.getModifier());
        } else {
            reportLine = reportLine.replace("READING", BAD_URN);
        }

        //Try to parse the image URN
        var imageURN = new URN(parts[3]);
        if (imageURN) {
            if (imageURN.valid) {
                reportLine = reportLine.replace("IMAGE", "![" + recordURN.parts[4] + "](" + getImageURLFromURN(imageURN) + ")");
            } else {
                reportLine = reportLine.replace("IMAGE", BAD_URN);
            }
        } else {
            reportLine = reportLine.replace("IMAGE", BAD_URN);
        }


        //Add the line to the report
        report += reportLine;
    }

    return report;
}


/**
 * Tries to parse a URN into a <img> element
 * @param {URN} urn a urn string data boject
 */
function getImageURLFromURN(urn) {
    /*E3
    http://www.homermultitext.org/iipsrv?OBJ=IIP,1.0&FIF=/project/homer/pyramidal/deepzoom/hmt/e3bifolio/v1/E3_131v_132r.tif&RGN=0.2342,0.3244,0.008962,0.01552&WID=100&CVT=JPEG
    */
    /**MSB
     * http://www.homermultitext.org/iipsrv?OBJ=IIP,1.0&FIF=/project/homer/pyramidal/deepzoom/hmt/vbbifolio/v1/vb_135v_136r.tif&RGN=0.2163,0.2336,0.01345,0.02415&WID=100&CVT=JPEG
     */
    //Base image location
    var url = "http://www.homermultitext.org/iipsrv?OBJ=IIP,1.0&FIF=/project/homer/pyramidal/deepzoom/hmt/%MANUSCRIPT%/v1/%FOLIO%.tif&RGN=REGION&WID=100&CVT=JPEG";

    //Split the URN into the necessary parts
    var region = urn.getModifier();
    var folioName = urn.parts[4].replace("@" + region, '');
    var manuscript = urn.parts[3].replace('.v1', '');

    //Replace the region
    url = url.replace("REGION", region.trim());
    url = url.replace("%FOLIO%", folioName.trim());
    url = url.replace("%MANUSCRIPT%", manuscript.trim());

    //Now return the finished url
    return url;
}