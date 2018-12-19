# Select

[![IRC][IRC Badge]][IRC]

###### [Usage](#usage) | [Documentation](#commands) | [Contributing](CONTRIBUTING)

> [Kakoune] extension to select things.

## Installation

### [Pathogen]

``` kak
pathogen-infect /home/user/repositories/github.com/alexherbo2/select.kak
```

## Usage

```
select-keep-(not)-matching {list} {command}
```

- `list`: Element list
- `command`: Command to execute.  The selection is available in the parameter list, accessible through `$@` in shells or `%arg(@)` in commands.

### Example

``` kak
define-command test %{
  select-keep-not-matching 'foo' 'bar' 'baz' 'qux' %{ select-keep-matching %arg(@) %{
    echo %arg(@)
  }}
  execute-keys 'qux'
}
```

## Commands

- `select-keep-matching` `list` `command`: Keep selections that match the given regex and execute command
- `select-keep-not-matching` `list` `command`: Clear selections that match the given regex and execute command

[Kakoune]: http://kakoune.org
[IRC]: https://webchat.freenode.net?channels=kakoune
[IRC Badge]: https://img.shields.io/badge/IRC-%23kakoune-blue.svg
[Pathogen]: https://github.com/alexherbo2/pathogen.kak
