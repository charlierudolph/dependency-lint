module.exports = {
  'default': [
    '--compiler coffee:coffee-script/register',
    '--format progress',
    '--format rerun:@rerun.txt',
    '--strict'
  ].join(' ')
}
