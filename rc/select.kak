declare-option -hidden bool select_multiple_selections true

declare-user-mode select

define-command select- -params .. -docstring 'Enter in Select mode using the given list and command to execute' %{
  # [N]: Buffer name
  set-register N "*%sh(printf '%s' ""$@"" | shasum -a 512 | head -c 7)*"
  edit -scratch %reg(N)
  # Paste arguments
  set-register dquote %arg(@)
  execute-keys '<a-P>'
  # [C]: Command
  set-register C %val(main_reg_dot)
  execute-keys '<a-space>'
  execute-keys ')'
  # [A]: Arguments
  set-register A %reg(.)
  set-register dquote %reg(A)
  # Split arguments with new line
  execute-keys '%<a-d><a-P>)<a-;>Zi<ret><esc>gg<a-d>z'
  # Mappings
  map window select 's' -docstring 'Select (Keep matching)' ':<space>select-select<ret>'
  map window select 'r' -docstring 'Reject (Keep not matching)' ':<space>select-reject<ret>'
  map window select '<ret>' -docstring 'Validate' ':<space>select-validate<ret>'
  map window select '<tab>' -docstring 'Toggle multi-selection mode' ':<space>select-toggle-multiple-selections<ret>'
  map window select 'd' -docstring 'Delete (Main)' ':<space>select-delete<ret>'
  map window select 'u' -docstring 'Undo (All)' ':<space>select-undo<ret>'
  map window select 'j' -docstring 'Down' ':<space>select-move-down<ret>'
  map window select 'k' -docstring 'Up' ':<space>select-move-up<ret>'
  # Select
  select-mode-enter
  # Issue: ModeChange hook doesn’t handle User modes
  # https://github.com/mawww/kakoune/issues/2672
  hook window NormalIdle '' %{
    delete-buffer
    # Hide potential previous messages when canceling
    echo
  }
}

# Public

define-command -hidden select-select %{
  select-filter '<a-k>' 'Select'
}

define-command -hidden select-reject %{
  select-filter '<a-K>' 'Reject'
}

define-command -hidden select-validate %{ evaluate-commands %sh{
  if test $kak_opt_select_multiple_selections = true; then
    printf 'select-validate- %%reg(.)\n'
  else
    printf 'select-validate- %%val(main_reg_dot)\n'
  fi
}}

define-command -hidden select-toggle-multiple-selections %{ evaluate-commands %sh{
  if test $kak_opt_select_multiple_selections = true; then
    printf '
      set-option current select_multiple_selections false
      set-face window SecondarySelection default,default
      set-face window SecondaryCursor default,default
      set-face window SecondaryCursorEol default,default
      select-mode-enter
    '
  else
    printf '
      set-option current select_multiple_selections true
      unset-face window SecondarySelection
      unset-face window SecondaryCursor
      unset-face window SecondaryCursorEol
      select-mode-enter
    '
  fi
}}

define-command -hidden select-delete %{
  execute-keys 'Z<space><a-x><a-d>z<a-;>'
  select-mode-enter
}

define-command -hidden select-undo %{
  execute-keys '%<a-d>"A<a-P>)<a-;>Zi<ret><esc>gg<a-d>z'
  select-mode-enter
}

define-command -hidden select-move-down %{
  select-execute-keys ')'
}

define-command -hidden select-move-up %{
  select-execute-keys '('
}

# Private

define-command -hidden select-mode-enter -params .. %{
  echo -markup {Information} %arg(@)
  enter-user-mode select
}

define-command -hidden select-execute-keys -params .. %{
  execute-keys %arg(@)
  select-mode-enter
}

define-command -hidden select-validate- -params .. %{
  delete-buffer
  define-command -override -hidden select-command -params .. %reg(C)
  select-command %arg(@)
}

define-command -hidden select-filter -params .. %{
  set-register dquote %reg(.)
  prompt %arg(2) %{
    # Restore selections
    execute-keys '%<a-d><a-P>)<a-;>Zi<ret><esc>gg<a-d>z'
    set-register / %val(text)
    execute-keys "%arg(1)<ret>"
    # Update selections
    execute-keys 'y%<a-d><a-P>)<a-;>Zi<ret><esc>gg<a-d>z'
    # Select
    select-mode-enter
  } -on-change %{ evaluate-commands -save-regs 'C' %{
    set-register C %val(client)
    evaluate-commands -buffer %reg(N) %{
      try %{
        # Restore selections
        execute-keys '%<a-d><a-P>)<a-;>Zi<ret><esc>gg<a-d>z'
        set-register / %val(text)
        execute-keys "%arg(1)<ret>"
        # Update selections
        execute-keys 'y%<a-d><a-P>)<a-;>Zi<ret><esc>gg<a-d>z'
        # Update view
        evaluate-commands -client %reg(C) \
          evaluate-commands select %val(selections_desc)
      } catch %{
        execute-keys '%d'
      }
    }
  }} -on-abort %{
    execute-keys '%<a-d><a-P>)<a-;>Zi<ret><esc>gg<a-d>z'
    # Select
    select-mode-enter
  }
}
