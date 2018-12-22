import _ from 'lodash';
import { outputFile, outputJson, readFile, readJson } from 'fs-extra';
import yaml from 'js-yaml';

export async function addToJsonFile(filePath, toAdd) {
  let obj;
  try {
    obj = await readJson(filePath);
  } catch (error) {
    obj = {};
  }
  _.assign(obj, toAdd);
  await outputJson(filePath, obj);
}

export async function addToYmlFile(filePath, toAdd) {
  let content;
  try {
    content = await readFile(filePath, 'utf8');
  } catch (error) {
    content = '{}';
  }
  const obj = yaml.safeLoad(content);
  _.mergeWith(obj, toAdd, function(objValue, srcValue) {
    if (_.isArray(srcValue)) {
      return srcValue;
    }
  });
  await outputFile(filePath, yaml.safeDump(obj));
}
