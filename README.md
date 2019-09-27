# Select

[![IRC][IRC Badge]][IRC]

###### [Usage](#usage) | [Documentation](#commands) | [Contributing](CONTRIBUTING)

> [Kakoune] extension to select things.

[![asciicast](https://asciinema.org/a/219413.svg)](https://asciinema.org/a/219413)

## Projects

Some other projects relying on Select:

- [Portal]
- <s>[Yank Ring]</s> (2019-01-28)

## Installation

### [Pathogen]

``` kak
pathogen-infect /home/user/repositories/github.com/alexherbo2/select.kak
```

## Usage

```
select- {list} {command}
```

- `list`: Element list
- `command`: Command to execute.  The selection is available in the parameter list, accessible through `$@` in shells or `%arg(@)` in commands.

### Example

``` kak
define-command test %{
  select- 'foo' 'bar' 'baz' 'qux' %{
    echo %arg(@)
  }
}
```

## Commands

### Select

- <kbd>s</kbd>: Select (Keep matching)
- <kbd>r</kbd>: Reject (Keep not matching)
- <kbd>Return</kbd>: Validate
- <kbd>Tab</kbd>: Toggle multi-selection mode
- <kbd>d</kbd>: Delete (Main)
- <kbd>u</kbd>: Undo (All)
- <kbd>j</kbd>: Down
- <kbd>k</kbd>: Up
- <kbd>q</kbd>: Quit

### Command

- `select-` `list` `command`: Enter in Select mode using the given list and command to execute

[Kakoune]: https://kakoune.org
[IRC]: https://webchat.freenode.net/#kakoune
[IRC Badge]: https://img.shields.io/badge/IRC-%23kakoune-blue.svg
[Pathogen]: https://github.com/alexherbo2/pathogen.kak
[Portal]: https://github.com/alexherbo2/portal.kak
[Yank Ring]: https://github.com/alexherbo2/yank-ring.kak
