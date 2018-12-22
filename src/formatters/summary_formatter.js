import _ from 'lodash';
import colors from 'colors/safe';
import errorMessages from './error_messages';

export default class SummaryFormatter {
  // stream - writable stream to send output
  constructor({ minimal, stream }) {
    this.minimal = minimal;
    this.stream = stream;
  }

  // Prints the result to its stream
  print({ fixes, results }) {
    if (!fixes) {
      fixes = {};
    }
    for (let type in results) {
      let modules = results[type];
      if (this.minimal) {
        modules = _.filter(
          modules,
          ({ error, errorIgnored }) => error && !errorIgnored
        );
      }
      if (modules.length === 0) {
        continue;
      }
      this.write(`${type}:`);
      for (let module of modules) {
        const fixed = _.includes(fixes[type], module.name);
        this.write(this.moduleOutput(module, fixed), 1);
      }
      this.write('');
    }
    if (!this.minimal || this.errorCount(results) !== 0) {
      this.write(this.summaryOutput(results));
    }
  }

  moduleOutput({ error, errorIgnored, files, name, scripts }, fixed) {
    if (error) {
      const message = errorMessages[error];
      if (errorIgnored) {
        return colors.yellow(`- ${name} (${message} - ignored)`);
      } else {
        const header = fixed
          ? colors.magenta(`✖ ${name} (${message} - fixed)`)
          : colors.red(`✖ ${name} (${message})`);
        return header + colors.gray(this.errorSuffix({ files, scripts }));
      }
    } else {
      return `${colors.green('✓')} ${name}`;
    }
  }

  indent(str, count) {
    let prefix = '';
    _.times(count, () => (prefix += '  '));
    return prefix + str;
  }

  write(data, indent) {
    if (indent == null) {
      indent = 0;
    }
    data =
      data
        .split('\n')
        .map(str => this.indent(str, indent))
        .join('\n') + '\n';
    return this.stream.write(data, 'utf8');
  }

  errorCount(results) {
    let count = 0;
    for (let title in results) {
      const modules = results[title];
      for (let { error, errorIgnored } of modules) {
        if (error && !errorIgnored) {
          count += 1;
        }
      }
    }
    return count;
  }

  errorSuffix(usage) {
    let suffix = '';
    for (let type in usage) {
      const list = usage[type];
      if (list && list.length > 0) {
        suffix += `\n${this.indent(`used in ${type}:`, 2)}`;
        for (let item of list) {
          suffix += `\n${this.indent(item, 3)}`;
        }
      }
    }
    return suffix;
  }

  summaryOutput(results) {
    const errors = this.errorCount(results);
    let prefix = colors.green('✓');
    if (errors > 0) {
      prefix = colors.red('✖');
    }
    let msg = `${prefix} ${errors} error`;
    if (errors !== 1) {
      msg += 's';
    }
    return msg;
  }
}
