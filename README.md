# Chronicle::Shell

Shell importer for [chronicle-etl](https://github.com/chronicle-app/chronicle-etl)

## Available Connectors
### Extractors
- `shell-history` - Extract shell history from bash or zsh

### Transformers
- `shell-history` - Process a shell command

## Usage

```bash
gem install chronicle-etl
chronicle-etl connectors:install shell

chronicle-etl --extractor shell-history --since "2022-02-07" --transformer shell-history --loader table
```
