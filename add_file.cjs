// One-off utility: register new Swift source file(s) into project.pbxproj.
// Usage: node add_file.cjs FuelControl/Components/HeroHeaderCard.swift [more files...]
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const PBX = path.join(__dirname, 'FuelControl.xcodeproj', 'project.pbxproj');
// Normalize to LF while editing (the file may have been checked out with
// CRLF line endings); written back as LF, which git/Xcode both handle fine.
let text = fs.readFileSync(PBX, 'utf8').replace(/\r\n/g, '\n');

function uuid() {
  let id;
  do { id = crypto.randomBytes(12).toString('hex').toUpperCase(); }
  while (text.includes(id));
  return id;
}

const filesToAdd = process.argv.slice(2);
if (filesToAdd.length === 0) {
  console.error('Pass at least one file path, e.g. FuelControl/Components/Foo.swift');
  process.exit(1);
}

for (const relPath of filesToAdd) {
  const parts = relPath.split('/').filter(p => p !== 'FuelControl');
  const fileName = parts[parts.length - 1];
  const groupName = parts.length > 1 ? parts[parts.length - 2] : 'FuelControl';

  // Find the group block: `<UUID> /* <groupName> */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n ... );`
  const groupRe = new RegExp(`([0-9A-F]{24}) /\\* ${groupName} \\*/ = \\{\\n\\t\\t\\tisa = PBXGroup;\\n\\t\\t\\tchildren = \\(\\n([\\s\\S]*?)\\t\\t\\t\\);`);
  const groupMatch = text.match(groupRe);
  if (!groupMatch) {
    console.error(`Could not find PBXGroup named "${groupName}" for ${relPath}`);
    process.exit(1);
  }

  const fileRefId = uuid();
  const buildFileId = uuid();

  // 1. Insert into the group's children list FIRST, using the match located
  //    against the text as it currently stands (recomputed per-file so later
  //    iterations see earlier insertions too).
  const insertPoint = groupMatch.index + groupMatch[0].indexOf('children = (\n') + 'children = (\n'.length;
  text = text.slice(0, insertPoint) + `\t\t\t\t${fileRefId},\n` + text.slice(insertPoint);

  // 2. Add PBXFileReference
  const fileRefLine = `\t\t${fileRefId} /* ${fileName} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "${fileName}"; sourceTree = "<group>"; };\n`;
  text = text.replace('/* End PBXFileReference section */', fileRefLine + '/* End PBXFileReference section */');

  // 3. Add PBXBuildFile
  const buildFileLine = `\t\t${buildFileId} /* ${fileName} in Sources */ = {isa = PBXBuildFile; fileRef = ${fileRefId} /* ${fileName} */; };\n`;
  text = text.replace('/* End PBXBuildFile section */', buildFileLine + '/* End PBXBuildFile section */');

  // 4. Insert into PBXSourcesBuildPhase files list
  const sourcesRe = /(PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = \(\n)/;
  text = text.replace(sourcesRe, `$1\t\t\t\t${buildFileId} /* ${fileName} in Sources */,\n`);

  console.log(`Registered ${relPath} -> fileRef=${fileRefId} buildFile=${buildFileId} in group "${groupName}"`);
}

fs.writeFileSync(PBX, text, 'utf8');
