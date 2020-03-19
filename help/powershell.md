# PowerShell

## "Grep"

`Select-String` (alias `sls`) is the `grep` analogue.

`Write-Host` cannot be captured, or filtered with `Select-String`, without redirection.
For example, if you want to filter the output of `scoop list`, you must redirect the "Information" stream, like so:

```
scoop list 6>&1 | sls vim
```

See https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-6

