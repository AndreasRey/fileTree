const _ = require('lodash');

function processRecords(records, otherRecords, isLocal) {
  // Map to store parent folder info
  const parentFolderMap = new Map();
  const fileNameMap = new Map();
  const otherFileNameMap = new Map();

  records.forEach(record => {
      const name = _.toLower(record.name);
      const fullPath = record.fullpath;

      // Initialize geodatabase field and duplicate field
      record.geodatabase = '';
      record.duplicate = false;

      // Check for main geodatabase folders
      if (record.type === 'folder' && name.endsWith('.gdb')) {
          record.geodatabase = 'main';
          parentFolderMap.set(fullPath, 'main');
      }

      // Check for zipped geodatabase files
      if (record.type === 'file' && name.endsWith('.zip') && name.includes('.gdb')) {
          record.geodatabase = 'zipped';
      }

      // Handle duplicates (case-insensitive)
      if (fileNameMap.has(name)) {
          fileNameMap.get(name).push(record);
      } else {
          fileNameMap.set(name, [record]);
      }
  });

  // Create a map for other records to check for cross dataset matches
  otherRecords.forEach(record => {
      const name = _.toLower(record.name);
      if (otherFileNameMap.has(name)) {
          otherFileNameMap.get(name).push(record);
      } else {
          otherFileNameMap.set(name, [record]);
      }
  });

  // Flag files within main geodatabase folders as content
  records.forEach(record => {
      const parentFolderFull = record.parentfolderfull;
      if (parentFolderMap.get(parentFolderFull) === 'main') {
          record.geodatabase = 'content';
      }
  });

  // Update records to flag duplicates
  fileNameMap.forEach((files, name) => {
      if (files.length > 1) {
          files.forEach(file => {
              file.duplicate = true;
          });
      }
  });

  // Check for matches in the other dataset
  records.forEach(record => {
      const name = _.toLower(record.name);
      if (otherFileNameMap.has(name)) {
          if (isLocal) {
              record.match_in_sharepoint = true;
          } else {
              record.match_in_drive = true;
          }
      } else {
          if (isLocal) {
              record.match_in_sharepoint = false;
          } else {
              record.match_in_drive = false;
          }
      }
  });

  return records;
}

module.exports = {
  processRecords
};
