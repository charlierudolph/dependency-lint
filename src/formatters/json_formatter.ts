import _ from 'lodash';
import errorMessages from './error_messages';

export default class JsonFormatter {
  // stream - writable stream to send output
  constructor({ stream }) {
    this.stream = stream;
  }

  // Prints the result to its stream
  print({ fixes, results }) {
    if (!fixes) {
      fixes = {};
    }
    const data = _.mapValues(results, (modules, type) =>
      _.map(modules, function(module) {
        const fixed = _.includes(fixes[type], module.name);
        const error = errorMessages[module.error];
        return _.assign({}, module, { error, fixed });
      })
    );
    return this.stream.write(JSON.stringify(data, null, 2), 'utf8');
  }
}
