import colors from 'colors/safe';
import util from 'util';

export default function exitWithError(err) {
  const message = (err != null ? err.stack : undefined) || util.format(err);
  console.error(colors.red(message));
  process.exit(1);
}
