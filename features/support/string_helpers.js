export function trimLines(str) {
  return str
    .trim()
    .split('\n')
    .map(line => line.trim())
    .join('\n');
}
