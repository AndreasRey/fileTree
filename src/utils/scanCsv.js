const fs = require('fs');
const csv = require('csv-parser');

const scanCsv = (filePath, callback) => {
    const records = [];

    fs.createReadStream(filePath)
        .pipe(csv())
        .on('data', (row) => {
            // Normalize field names to lowercase and update 'File Path' to 'fullpath'
            const normalizedRow = {};
            for (const key in row) {
                let normalizedKey = key.toLowerCase().replace(/ /g, '_');
                if (normalizedKey === 'file_path') {
                    normalizedKey = 'fullpath';
                }
                normalizedRow[normalizedKey] = row[key];
            }
            records.push(normalizedRow);
        })
        .on('end', () => {
            console.log('CSV file successfully processed');
            callback(records);
        });
};

module.exports = { scanCsv };
