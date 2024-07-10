const { readCSV, writeCSV } = require('./modules/csvHandler');
const { processRecords } = require('./modules/recordProcessor');

function main() {
    const inputFiles = [
        './scripts/out/File_Details.csv',
        './scripts/out/SharePoint_File_Details.csv'
    ];
    const outputFiles = [
        './scripts/out/Processed_File_Details_Local.csv',
        './scripts/out/Processed_File_Details_SharePoint.csv'
    ];

    // Read CSVs
    const localRecords = readCSV(inputFiles[0]);
    const sharepointRecords = readCSV(inputFiles[1]);

    // Process records to flag geodatabase and duplicates
    const updatedLocalRecords = processRecords(localRecords, sharepointRecords, true);
    const updatedSharepointRecords = processRecords(sharepointRecords, localRecords, false);

    // Write updated records to new CSVs
    writeCSV(outputFiles[0], updatedLocalRecords);
    writeCSV(outputFiles[1], updatedSharepointRecords);

    console.log('CSV processing complete. Updated files saved as Processed_File_Details_Local.csv and Processed_File_Details_SharePoint.csv');
}

main();
