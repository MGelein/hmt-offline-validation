/**Store all command line parameters in a separate object */
const args = process.argv.splice(2);

/**
 * Validating the leiden2018 repository
 */
const {URN} = require('./lib/urn');
const {loadDB} = require('./lib/cexdb');
const {validatePaleo} = require('./lib/paleo');
const chalk = require('chalk');


//The persons database
let persons;
//The places database
let places;

/**
 * Loads the DB
 */
loadDB(function(personDB, placeDB){
    //assigning the databases
    persons = personDB;
    places = placeDB;
    //call the start of the process
    startValidation();
});

/**The mode of operation */
let MODE;
const PALEO = "paleo";
const XML = "xml";
/**The target of operation */
let TARGET;
const SCHOLIA = "scholia";
const MAIN = "main";
/**
 * Start the validation of the process
 */
function startValidation(){
    /**Parse all arguments */
    args.forEach(function(arg){
        //Argument to lower case and trim
        arg = arg.toLowerCase().trim();
        if(isPaleo(arg)){
            MODE = PALEO;
        }else if(isXML(arg)){
            MODE = XML;
        }else if(isScholia(arg)){
            TARGET = SCHOLIA;
        }else if(isMain(arg)){
            TARGET = MAIN;
        }else{
            console.log(chalk.red("Warning: ") + "Unrecognized argument: " + chalk.bold(arg));
            console.log(chalk.red("Aborting validation..."));
            process.exit();
        }
    });
    //After all args have been parsed, say what we're going to do
    console.log("We're going to be validating " + MODE + " for " + TARGET);
}

/**
 * Checks if this is a scholia target
 * @param {String} s 
 */
function isScholia(s){
    /*Checks if this string is a recognized scholia option */
    return ["s", "schol", "scholia", "scholai"].indexOf(s) >  -1;
}

/**
 * Checks if this is a main target
 * @param {String} s 
 */
function isMain(s){
    /*Checks if this string is a recognized main option */
    return ["m", "main", "maintext", "main-text", "mian", "illiad"].indexOf(s) >  -1;
}

/**
 * Checks if this is a paleo string
 * @param {String} s 
 */
function isPaleo(s){
    //If this string is a paleo option
    return ["p", "pal", "paloe", "paleo"].indexOf(s) > -1;
}

/**
 * Checks if this is a xml string
 * @param {String} s 
 */
function isXML(s){
    //If this string is a paleo option
    return ["x", "xml", "xlm"].indexOf(s) > -1;
}