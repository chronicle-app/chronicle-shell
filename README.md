# Chronicle::Shell
[![Gem Version](https://badge.fury.io/rb/chronicle-shell.svg)](https://badge.fury.io/rb/chronicle-shell)

Shell importer for [chronicle-etl](https://github.com/chronicle-app/chronicle-etl)

## Available Connectors
### Extractors
- `shell:history` - Extract shell history from bash or zsh

### Transformers
- `shell:command` - Turn a shell command into Chronicle Schema

## Usage and examples

```bash
# install chronicle-etl and then this plugin
gem install chronicle-etl
chronicle-etl plugins:install shell

# output commands since Feb 7 as json
chronicle-etl --extractor shell:history --transformer shell:history --since "2022-02-07" --loader json

# Show recent commands sorted by frequency of use
chronicle-etl --extractor shell:history --limit 500 --fields command --silent | sort | uniq -c | sort -nr
```
