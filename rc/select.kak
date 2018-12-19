define-command select-keep-matching -params .. -docstring 'Keep selections that match the given regex and execute command' %{
  select-implement '<a-k>' 'Select' %arg(@)
}

define-command select-keep-not-matching -params .. -docstring 'Clear selections that match the given regex and execute command' %{
  select-implement '<a-K>' 'Reject' %arg(@)
}

define-command -hidden select-implement -params .. %{
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
  # [F]: Filter
  set-register F %val(main_reg_dot)
  execute-keys '<a-space>'
  # [P]: Prompt
  set-register P %val(main_reg_dot)
  execute-keys '<a-space>'
  # [A]: Arguments
  set-register A %reg(.)
  set-register dquote %reg(A)
  # Split arguments with new line
  execute-keys '%<a-d><a-P>Zi<ret><esc>gg<a-d>z'
  prompt %reg(P) %{
    # Restore selections
    execute-keys '%<a-d><a-P>Zi<ret><esc>gg<a-d>z'
    set-register / %val(text)
    execute-keys "%reg(F)<ret>"
    # [S]: Selection
    set-register S %reg(.)
    delete-buffer %reg(N)
    define-command -override -hidden select-command -params .. %reg(C)
    select-command %reg(S)
  } -on-change %{ evaluate-commands -save-regs 'C' %{
    set-register C %val(client)
    evaluate-commands -buffer %reg(N) %{
      try %{
        # Restore selections
        execute-keys '%<a-d><a-P>Zi<ret><esc>gg<a-d>z'
        set-register / %val(text)
        execute-keys "%reg(F)<ret>"
        # Update selections
        execute-keys 'y%<a-d><a-P>Zi<ret><esc>gg<a-d>z'
        # Update view
        evaluate-commands -client %reg(C) \
          evaluate-commands select %val(selections_desc)
      } catch %{
        execute-keys '%d'
      }
    }
  }} -on-abort %{
    delete-buffer
  }
}
