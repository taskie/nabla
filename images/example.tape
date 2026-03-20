Output images/example.gif
Require nablex
Set Shell bash

Set FontSize 18
Set FontFamily "JetBrains Mono"
Set Width 960
Set Height 540
Set Padding 20
Set Margin 20
Set MarginFill "#CCCCCC"
Set BorderRadius 10

Hide
Type 'cp tests/fixtures/example.txt .'
Enter
Ctrl+L
Show

Sleep 2s

Type "echo foo"
Sleep 0.5s
Enter
Sleep 2s

Type "echo foo | sed 's/foo/bar/g'"
Sleep 0.5s
Enter
Sleep 2s

Type "echo foo | nablex sed 's/foo/bar/g'"
Sleep 0.5s
Enter
Sleep 2s

Type "echo foo | nablex sed 's/foo/bar/g' | delta"
Sleep 0.5s
Enter
Sleep 3s

Ctrl+L

Sleep 1s

Type "cat example.txt"
Sleep 0.5s
Enter
Sleep 2s

Type "sed 's/e/E/g' example.txt"
Sleep 0.5s
Enter
Sleep 2s

Type "nablex sed 's/e/E/g' ::: example.txt"
Sleep 0.5s
Enter
Sleep 2s

Type "nablex sed 's/e/E/g' ::: example.txt | delta"
Sleep 0.5s
Enter
Sleep 2s

Type "nablex sed 's/e/E/g' ::: example.txt | patch -p0"
Sleep 0.5s
Enter
Sleep 2s

Type "cat example.txt"
Sleep 0.5s
Enter
Sleep 3s

Ctrl+L

Hide
Type 'rm -f example.txt'
Enter
