[![Build Status](https://travis-ci.org/rosette-proj/rosette-extractor-yaml.svg)](https://travis-ci.org/rosette-proj/rosette-extractor-yaml) [![Code Climate](https://codeclimate.com/github/rosette-proj/rosette-extractor-yaml/badges/gpa.svg)](https://codeclimate.com/github/rosette-proj/rosette-extractor-yaml) [![Test Coverage](https://codeclimate.com/github/rosette-proj/rosette-extractor-yaml/badges/coverage.svg)](https://codeclimate.com/github/rosette-proj/rosette-extractor-yaml/coverage)

rosette-extractor-yaml
====================

Extracts translatable strings from YAML files for the Rosette internationalization platform.

## Installation

`gem install rosette-extractor-yaml`

Then, somewhere in your project:

```ruby
require 'rosette/extractors/yaml-extractor'
```

### Introduction

This library is generally meant to be used with the Rosette internationalization platform that extracts translatable phrases from git repositories. rosette-extractor-yaml is capable of identifying translatable phrases in YAML files, specifically those that use one of the following translation strategies:

1. Dotted key notation in the style of Rails.

Additional types of data organization are straightforward to support. Open an issue or pull request if you'd like to see support for another strategy.

### Usage with rosette-server

Let's assume you're configuring an instance of [`Rosette::Server`](https://github.com/rosette-proj/rosette-server). Adding dotted key (rails) support would cause your configuration to look something like this:

```ruby
# config.ru
require 'rosette/core'
require 'rosette/extractors/yaml-extractor'

rosette_config = Rosette.build_config do |config|
  config.add_repo('my_awesome_repo') do |repo_config|
    repo_config.add_extractor('yaml/rails') do |extractor_config|
      extractor_config.match_file_extensions(['.yml', '.yaml'])
    end
  end
end

server = Rosette::Server::ApiV1.new(rosette_config)
run server
```

Note that `yaml/dotted-key` is an alias for `yaml/rails` - you can use both interchangeably.

See the documentation contained in [rosette-core](https://github.com/rosette-proj/rosette-core) for a complete list of extractor configuration options in addition to `match_file_extensions`.

### Standalone Usage

While most of the time rosette-extractor-yaml will probably be used alongside rosette-server (or similar), there may arise use cases where someone might want to use it on its own. The `extract_each_from` method on `RailsExtractor` (or `DottedKeyExtractor`) yields `Rosette::Core::Phrase` objects (or returns an enumerator):

```ruby
yaml_source_code = "en:\n  title:\n    Foobarbaz"
extractor = Rosette::Extractors::YamlExtractor::RailsExtractor.new
extractor.extract_each_from(yaml_source_code) do |phrase|
  phrase.meta_key # => "en.title"
  phrase.key      # => "Foobar"
end
```

## Requirements

This project must be run under jRuby. It uses [expert](https://github.com/camertron/expert) to manage java dependencies via Maven. Run `bundle exec expert install` in the project root to download and install java dependencies.

## Running Tests

`bundle exec rake` or `bundle exec rspec` should do the trick.

## Authors

* Cameron C. Dutro: http://github.com/camertron
