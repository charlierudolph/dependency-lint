import { docopt } from 'docopt';
import exitWithError from './util/exit_with_error';
import packageJson from '../package.json';
import run from './run';
import generateConfig from './generate_config';

const usage = `\
Usage:
  dependency-lint [--auto-correct] [--generate-config] [--format <format>]

Options:
  --auto-correct       Moves mislabeled modules and removes unused modules
  --format <format>    Select the formatter: json, minimal (default), summary
  -h, --help           Show this screen
  --generate-config    Generate a configuration file
  -v, --version        Show version\
`;

export default async function() {
  try {
    const options = docopt(usage, { version: packageJson.version });
    const fn = options['--generate-config'] ? generateConfig : run;
    const format = options['--format'] || 'minimal';
    if (!['json', 'minimal', 'summary'].includes(format)) {
      throw new Error(
        `Invalid format: '${format}'. Valid formats: json, minimal, or summary`
      );
    }
    await fn({ autoCorrect: options['--auto-correct'], format });
  } catch (error) {
    exitWithError(error);
  }
}
