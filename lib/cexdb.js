const request = require('request');
/**Immediately start initializing */

//Person hash table by their URN
var persons;
function getPersonDB(cb) {
    persons = {};
    request.get
    ("https://raw.githubusercontent.com/homermultitext/hmt-authlists/master/data/hmtplaces.cex", function(error, response, data){
        var table = cexJSON(data, "#!citedata");
        table.forEach(function(person){
            persons[person.urn] = {
                label: person.label,
                desc: person.description,
                status: person.status
            }
        });
        //Forward the callback
        getPlaceDB(cb);
    });
}

var places;
function getPlaceDB(cb) {
    places = {};
    request.get
    ("https://raw.githubusercontent.com/homermultitext/hmt-authlists/master/data/hmtplaces.cex", function(error, response, data){
        var table = cexJSON(data, "#!citedata");
        table.forEach(function(place){
            places[place.urn] = {
                label: place.label,
                desc: place.description,
                pleiades: place.pleiades,
                status: place.status
            }
        });
        //Call the callback when done
        cb(persons, places);
    });
}

/**
 * Parses the provided file as a string starting from the provided header.
 * Returns a JSON result
 * @param {String} file 
 * @param {String} header 
 */
function cexJSON(file, header) {
    var lines = file.split('\n');
    var foundIndex = -1;
    var endIndex = -1;
    var table = [];
    for (var i = 0; i < lines.length; i++) {
        //Try to find the starting header
        if (lines[i].indexOf(header) == 0) {
            foundIndex = i;
            continue;
        }
        //Next section start
        if (lines[i].indexOf('#!') == 0 && foundIndex > -1) {
            endIndex = i;
            break;
        }
    }

    //If we haven't found another topic, read untill end
    if (endIndex == -1) endIndex = lines.length;

    //Read the headerline and parse it into the object
    var headerNames = lines[foundIndex + 1].split('#');

    //Go through all the lines and parse them into the object
    for (var i = foundIndex + 2; i < endIndex; i++) {
        //Skip this line if empty
        if (lines[i].trim().length < 1) continue;
        //Create an empty entry
        var entry = {};
        //Split the line into parts
        var items = lines[i].split('#');
        //Go through every item and enter them
        for (var j = 0; j < items.length; j++) {
            entry[headerNames[j]] = items[j];
        }
        //Now add the entry to the list
        table.push(entry);
    }
    return table;
}

exports.places = places;
exports.persons = persons;
exports.cexJSON = cexJSON;
/**
 * Calls the callback when all the DB have been loaded.
 * The callback returns two db's persons and places
 */
exports.loadDB = function(callback){
    getPersonDB(callback);
}