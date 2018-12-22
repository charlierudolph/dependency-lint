import { execFile } from 'child_process';
import path from 'path';
import { trimLines } from '../support/string_helpers';
import { When, Then } from 'cucumber';
import stripAnsi from 'strip-ansi';
import { expect } from 'chai';

When(
  /^I run it(?: with (--auto-correct|--generate-config))?(?: (?:with|and) the "([^"]*)" format)?$/,
  function(option, format, done) {
    const file = path.join(__dirname, '..', '..', 'bin', 'dependency-lint.js');
    const args = ['--format', format || 'json'];
    if (option) {
      args.push(option);
    }
    const options = { cwd: this.tmpDir };
    execFile(file, args, options, (error, stdout, stderr) => {
      this.error = error;
      this.stdout = stdout;
      this.stderr = stderr;
      done();
    });
  }
);

Then(/^I see the output$/, function(output) {
  expect(trimLines(stripAnsi(this.stdout))).to.eql(trimLines(output));
});

Then(/^I see no output$/, function() {
  expect(this.stdout).to.eql('');
});

Then(/^I see the error$/, function(error) {
  expect(trimLines(stripAnsi(this.stderr))).to.contain(trimLines(error));
});

Then(/^it exits with a non-zero status$/, function() {
  this.errorExpected = true;
  expect(this.error).to.exist();
});

Then(/^it reports no "([^"]*)"$/, function(key) {
  const modules = JSON.parse(this.stdout)[key];
  expect(modules).to.eql([]);
});

Then(/^it reports the "([^"]*)":$/, function(key, table) {
  const modules = JSON.parse(this.stdout)[key];
  const attributesList = table.hashes();
  expect(modules.length).to.eql(attributesList.length);
  attributesList.forEach(function(attributes, index) {
    const module = modules[index];
    expect(module.name).to.eql(attributes.NAME);
    expect(module.error).to.eql(
      attributes.ERROR === '<none>' ? undefined : attributes.ERROR
    );
    expect(module.errorIgnored).to.eql(
      attributes['ERROR IGNORED'] === 'true' ? true : undefined
    );
    expect(module.files).to.eql(
      attributes.FILES ? attributes.FILES.split(', ') : []
    );
    expect(module.fixed).to.eql(attributes.FIXED === 'true');
    expect(module.scripts).to.eql(
      attributes.SCRIPTS ? attributes.SCRIPTS.split(', ') : []
    );
  });
});
