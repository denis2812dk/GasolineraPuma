import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import assert from 'node:assert/strict';

const root = dirname(fileURLToPath(import.meta.url));
const project = readFileSync(join(root, 'FuelControl.xcodeproj/project.pbxproj'), 'utf8');
const objects = new Map([...project.matchAll(/([A-F0-9]{24})(?: \/\*.*?\*\/)? = \{([\s\S]*?)\};/g)]
  .map(match => [match[1], match[2]]));
const registered = new Set();
function visit(id, parent) {
  const body = objects.get(id);
  assert.ok(body, `Missing project object ${id}`);
  const path = body.match(/\bpath = "([^"]+)";/)?.[1];
  const full = path ? resolve(parent, path) : parent;
  if (body.includes('isa = PBXGroup;')) {
    const children = body.match(/children = \(([\s\S]*?)\);/)?.[1] ?? '';
    for (const child of children.match(/[A-F0-9]{24}/g) ?? []) visit(child, full);
  } else if (path?.endsWith('.swift')) {
    assert.ok(existsSync(full), `Missing Swift source ${full}`);
    assert.ok([...objects.values()].some(value => value.includes('isa = PBXBuildFile;') && value.includes(`fileRef = ${id}`)), `Not built: ${path}`);
    registered.add(full);
  }
}
visit('5404FDC2DFCF40C9A25488D1', root);
function walk(dir) {
  return readdirSync(dir, { withFileTypes: true }).flatMap(entry =>
    entry.isDirectory() ? walk(join(dir, entry.name)) : [join(dir, entry.name)]);
}
for (const file of walk(join(root, 'FuelControl')).filter(file => file.endsWith('.swift'))) {
  assert.ok(registered.has(resolve(file)), `Unregistered source: ${file}`);
  const source = readFileSync(file, 'utf8');
  assert.ok(!/URLSession|import (?:Network|Alamofire)|https?:\/\//.test(source), `Network reference: ${file}`);
  assert.ok(!/especial|Especial|TurnosView|ShiftDetailView|employee|startTime|endTime/.test(source), `Out-of-scope legacy reference: ${file}`);
  if (file.includes('Screens')) assert.ok(!source.includes('MockData.'), `Direct mock access: ${file}`);
}
assert.ok(!/TurnosView|ShiftDetailView/.test(project), 'Stale build references');
const sourcesPhase = [...objects.values()].find(body => body.includes('isa = PBXSourcesBuildPhase;'));
for (const [id, body] of objects) {
  if (body.includes('isa = PBXBuildFile;') && /\.swift/.test(body)) {
    assert.ok(sourcesPhase.includes(id), `Build file missing from Sources: ${id}`);
  }
}
console.log(`PASS: ${registered.size} Swift sources registered and present; no direct view mock access, legacy employee screens, or network calls.`);
console.log('Static checks only. Run swift test and xcodebuild on macOS for compilation/runtime validation.');
