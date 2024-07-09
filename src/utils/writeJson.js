const fs = require('fs');

const writeJson = (filePath, data) => {
    fs.writeFile(filePath, JSON.stringify(data, null, 2), (err) => {
        if (err) throw err;
        console.log(`Data written to ${filePath}`);
    });
};

module.exports = { writeJson };
