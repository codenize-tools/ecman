# Ecman

[EasyCron](https://www.easycron.com/) as Code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ecman'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ecman

## Usage

```ruby
export EASYCRON_TOKEN=...
ecman export ecman.rb
vi ecman.rb
ecman export ecman.rb
ecman apply ecman.rb --dry-run
ecman apply ecman.rb
```

## Help

```
Commands:
  ecman apply FILE      # apply
  ecman export [FILE]   # export
  ecman help [COMMAND]  # Describe available commands or one specific command
  ecman version         # show version

Options:
  [--token=TOKEN]
                           # Default: df6cf51f673b2bd91ce19f893df0a049
  [--target=TARGET]
  [--color], [--no-color]
                           # Default: true
  [--debug], [--no-debug]
```

## DSL example

```ruby
cron_job "example.com" do
  cron_expression "0 0 * * *"
  url "http://example.com"
  email_me 0
  log_output_length 0
end
cron_job "www.example.com" do
  cron_expression "0 0 * * *"
  url "http://www.example.com"
  email_me 0
  log_output_length 0
end
```

## Similar tools

- [Codenize.tools](https://codenize.tools/)
