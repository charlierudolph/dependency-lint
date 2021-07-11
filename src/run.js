import _ from 'lodash';
import AutoCorrector from './auto_corrector';
import ConfigurationLoader from './configuration_loader';
import { readJson, writeJson } from 'fs-extra';
import JsonFormatter from './formatters/json_formatter';
import Linter from './linter';
import path from 'path';
import fs from 'fs';
import SummaryFormatter from './formatters/summary_formatter';

const { realpath } = fs.promises;

function getFormatter(format) {
  const options = { stream: process.stdout };
  switch (format) {
    case 'minimal':
      return new SummaryFormatter(_.assign({ minimal: true }, options));
    case 'summary':
      return new SummaryFormatter(options);
    case 'json':
      return new JsonFormatter(options);
  }
}

const hasError = results =>
  _.some(results, modules =>
    _.some(
      modules,
      ({ error, errorFixed, errorIgnored }) =>
        error && !(errorFixed || errorIgnored)
    )
  );

export default async function run({ autoCorrect, format }) {
  let fixes;
  const dir = await realpath(process.cwd());
  const packageJsonPath = path.join(dir, 'package.json');
  const packageJson = await readJson(packageJsonPath);
  const config = await new ConfigurationLoader().load(dir);
  const results = await new Linter(config).lint({ dir, packageJson });
  if (autoCorrect) {
    let updatedPackageJson;
    ({ fixes, updatedPackageJson } = new AutoCorrector().correct({
      packageJson,
      results,
    }));
    await writeJson(packageJsonPath, updatedPackageJson, { spaces: 2 });
  }
  getFormatter(format).print({ fixes, results });
  if (hasError(results)) {
    process.exit(1);
  }
}
