# Chronicle::Shell
[![Gem Version](https://badge.fury.io/rb/chronicle-shell.svg)](https://badge.fury.io/rb/chronicle-shell)

Shell importer for [chronicle-etl](https://github.com/chronicle-app/chronicle-etl)

## Usage and examples

```bash
# install chronicle-etl and then this plugin
gem install chronicle-etl
chronicle-etl plugins:install shell

# output commands since 2 weeks ago
$ chronicle-etl --extractor shell:command --schema chronicle --since 2w --loader json

# Show recent commands sorted by frequency of use
$ chronicle-etl --extractor shell:command --loader table --limit 500 --fields command --silent | sort | uniq -c | sort -nr
```

## Available Connectors
### Extractors
- `shell:command` - Extract shell history from bash or zsh