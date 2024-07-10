const fs = require('fs');
const { parse, stringify } = require('csv/sync');

// Function to read CSV
function readCSV(filePath) {
    let data = fs.readFileSync(filePath, 'utf8');
    // Remove BOM if it exists
    if (data.charCodeAt(0) === 0xFEFF) {
        data = data.slice(1);
    }
    return parse(data, {
        columns: true,
        skip_empty_lines: true,
        quote: '"', // Configure to use double quotes
    });
}

// Function to write CSV
function writeCSV(filePath, data) {
    const output = stringify(data, {
        header: true,
        quote: '"', // Configure to use double quotes
    });
    fs.writeFileSync(filePath, output, 'utf8');
}

module.exports = {
    readCSV,
    writeCSV
};