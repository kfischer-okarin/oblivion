# Oblivion

[![ci](https://circleci.com/gh/kfischer-okarin/oblivion.svg?style=svg)](https://app.circleci.com/pipelines/github/kfischer-okarin/oblivion?branch=master) [![codecov](https://codecov.io/gh/kfischer-okarin/oblivion/branch/master/graph/badge.svg)](https://codecov.io/gh/kfischer-okarin/oblivion)


Oblivion minimizes and obfuscates Ruby source code by:
* randomly but consistently renaming private methods, local variables and unexposed instance variables
* Replacing all whitespace with semicolons

## Limitations

At the moment two types of inputs are supported:
* Single Ruby source code files without dependencies
* [DragonRuby Game Toolkit](https://dragonruby.itch.io/dragonruby-gtk) projects

## Usage

Install the gem

```
gem install oblivion
```

### Uglify a Ruby file

```
oblivion ruby my_million_dollar_algorithm.rb > ready_for_publishing.rb
```

### Uglify a DragonRuby game project

```
oblivion dragonruby games/light_souls
```
