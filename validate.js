/**Store all command line parameters in a separate object */
const args = process.argv.splice(2);

/**
 * Validating the leiden2018 repository
 */
const { URN } = require('./lib/urn');
const { loadDB } = require('./lib/cexdb');
const { validatePaleo } = require('./lib/paleo');
const chalk = require('chalk');
const fs = require('fs');
const marked = require('marked');
const sys = require('sys');
const exec = require('child_process').exec;
const stylesheet = `
*{
    font-family: Arial, Helvetica, sans-serif
    padding-left: 5em;
}
`;

//The persons database
let persons;
//The places database
let places;

/**
 * Loads the DB
 */
loadDB(function (personDB, placeDB) {
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
/**The manuscript we're checking */
let MANUSCRIPT;
const E3 = "Upsilon 1.1";
const VB = "Venetus B";
/**
 * Start the validation of the process
 */
function startValidation() {
    /**Parse all arguments */
    args.forEach(function (arg) {
        //Argument to lower case and trim
        arg = arg.toLowerCase().trim();
        if (isPaleo(arg)) {
            MODE = PALEO;
        } else if (isXML(arg)) {
            MODE = XML;
        } else if (isScholia(arg)) {
            TARGET = SCHOLIA;
        } else if (isMain(arg)) {
            TARGET = MAIN;
        } else if (isE3(arg)) {
            MANUSCRIPT = E3;
        } else if (isVB(arg)) {
            MANUSCRIPT = VB;
        } else {
            console.log(chalk.red("Warning: ") + "Unrecognized argument: " + chalk.bold(arg));
            abort();
        }
    });
    //See if all arguments are set
    if (!MODE || !MANUSCRIPT || !TARGET) {
        if (!MODE) console.log("No mode has been set, possibilities are 'paleo', 'xml', 'index'");
        if (!MANUSCRIPT) console.log("No manuscript has been set, possibilities are 'e3', 'vb'");
        if (!TARGET) console.log("No target has been set, possibilities are 'scholia', 'main'");
        abort();
    }

    //After all args have been parsed, say what we're going to do
    console.log("Validating " + chalk.green(MODE) + " for " + chalk.cyan(TARGET) + " of " + chalk.red(MANUSCRIPT));
    //Now start the actual validation
    validate();
}

/**
 * This starts the actual validation process
 */
function validate() {
    //If this is PALEO, do that and load file depending on target
    if (MODE === PALEO) {
        //Set the baseurl
        let fileUrl = "./paleography/paleo";
        //Add the correct manuscript identifier
        fileUrl += (MANUSCRIPT === E3) ? "e3" : "msB";
        //Add the extra modifier for target
        fileUrl += (TARGET === SCHOLIA) ? "_scholia" : "";
        //Finally add extension
        fileUrl += ".cex";
        if (fs.existsSync(fileUrl)) {
            console.log(fileUrl);
            let report = validatePaleo(fs.readFileSync(fileUrl, { encoding: "utf-8" }));
            makeHTMLReport(report);

        } else {
            console.log("File does not exist!");
            abort();
        }
    }
}

/**
 * Makes the report using the provided markdown files
 */
function makeHTMLReport(markdown) {
    let html = "<html><head><style>" + stylesheet + "</style></head><body>";
    html += marked(markdown);
    html += "</body></html>"
    let man = (MANUSCRIPT === VB) ? "vb" : "e3";
    let fileName = MODE + "-" + TARGET + "-" + man + "-report";
    fs.writeFileSync("./reports/" + fileName + ".html", html);

    exec(getCommandLine() + ' ./reports/' + fileName + ".html");
}


/**
 * Aborts the process
 */
function abort() {
    console.log(chalk.red("Aborting validation..."));
    process.exit();
}

/**
 * See if this is a shorthand for Upsilon 1.1
 * @param {String} s 
 */
function isE3(s) {
    //If this string is a e3 option
    return ["e3", "upsilon", "ups", "ups11", "upsilon1.1", "u"].indexOf(s) > -1;
}

/**
 * See if this is a shorthand for Venetus B
 * @param {String} s 
 */
function isVB(s) {
    //If this string is a vb option
    return ["vb", "venetusb", "venetus-b", "msb", "ms-b"].indexOf(s) > -1;
}

/**
 * Checks if this is a scholia target
 * @param {String} s 
 */
function isScholia(s) {
    /*Checks if this string is a recognized scholia option */
    return ["s", "schol", "scholia", "scholai"].indexOf(s) > -1;
}

/**
 * Checks if this is a main target
 * @param {String} s 
 */
function isMain(s) {
    /*Checks if this string is a recognized main option */
    return ["m", "main", "maintext", "main-text", "mian", "illiad"].indexOf(s) > -1;
}

/**
 * Checks if this is a paleo string
 * @param {String} s 
 */
function isPaleo(s) {
    //If this string is a paleo option
    return ["p", "pal", "paloe", "paleo"].indexOf(s) > -1;
}

/**
 * Checks if this is a xml string
 * @param {String} s 
 */
function isXML(s) {
    //If this string is a paleo option
    return ["x", "xml", "xlm"].indexOf(s) > -1;
}

/**
 * Gets the appropriate command for each platform
 */
function getCommandLine() {
    switch (process.platform) {
        case 'darwin': return 'open';
        case 'win32': return 'start';
        case 'win64': return 'start';
        default: return 'xdg-open';
    }
}
