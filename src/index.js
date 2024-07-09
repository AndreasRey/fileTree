const { scanCsv } = require('./utils/scanCsv');
const { writeJson } = require('./utils/writeJson');
const path = require('path');

const csvFilePath = path.join(__dirname, '../scripts/out/File_Details.csv');
const jsonOutputPath = path.join(__dirname, '../scripts/out/File_Details.json');
const duplicatesOutputPath = path.join(__dirname, '../scripts/out/File_Duplicates.json');

const callback = (record, allRecords) => {
  console.log(record)
    // Find duplicates by name and extension
    const duplicates = allRecords.filter(r => r.name === record.name && r.extension === record.extension);
    return duplicates.length > 1;
};

scanCsv(csvFilePath, (records) => {
    // Write the full JSON file
    writeJson(jsonOutputPath, records);

    // Generate the file names with duplicate flag
    const fileNamesWithDuplicates = records.map(record => ({
        fileName: `${record.name}${record.extension}`,
        isDuplicate: callback(record, records)
    }));

    writeJson(duplicatesOutputPath, fileNamesWithDuplicates);

    console.log('JSON files generated successfully.');
});
