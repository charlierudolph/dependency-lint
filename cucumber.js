module.exports = {
  'default': [
    '--format progress',
    '--format rerun:@rerun.txt',
    '--require-module @babel/register'
  ].join(' ')
}
