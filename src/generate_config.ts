import { readFile, writeFile } from 'fs-extra';
import packageJson from '../package.json';
import path from 'path';

export default async function generateConfig() {
  const src = path.join(__dirname, '..', 'config', 'default.yml');
  const dest = path.join(process.cwd(), 'dependency-lint.yml');
  const defaultConfig = await readFile(src, 'utf8');
  const fileContents = `\
# See ${packageJson.homepage}/blob/v${packageJson.version}/docs/configuration.md
# for a detailed explanation of the options

${defaultConfig}\
`;
  await writeFile(dest, fileContents);
  return console.log('Configuration file generated at "dependency-lint.yml"');
}
