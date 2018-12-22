function prependUnlessPresent(str, prefix) {
  if (str.indexOf(prefix) === -1) {
    return [prefix, str].join(': ');
  } else {
    return str;
  }
}

export default function prependToError(err, prefix) {
  err.message = prependUnlessPresent(err.message, prefix);
  return err;
}
