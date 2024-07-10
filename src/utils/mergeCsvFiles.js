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

// Function to merge two CSV files
function mergeCsvFiles(file1, file2, outputFile) {
    const records1 = readCSV(file1);
    const records2 = readCSV(file2);

    // Merge the two sets of records
    const mergedRecords = [...records1, ...records2];

    // Write the merged records to the output file
    writeCSV(outputFile, mergedRecords);

    console.log(`CSV files merged successfully. Output saved to ${outputFile}`);
}

// Example usage
const file1 = '../scripts/out/File_Details_Local.csv';
const file2 = '../scripts/out/Processed_File_Details_SharePoint.csv';
const outputFile = '../scripts/out/Merged_File_Details.csv';

mergeCsvFiles(file1, file2, outputFile);