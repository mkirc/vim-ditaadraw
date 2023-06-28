# vim-ditaadraw

A simple plugin for ditaa integration with markdown.

## Usage

Consider this simple ascii diagram:


`````
```ditaa
+---------+
|         |
|         |
|         |
+---------+
```
`````

With the cursor inside the code block
or on the lines with the backticks
hit `localleader + dr` (think "ditaa recompile") and **vim-ditaadraw**
sends the code block to a tempfile and runs `ditaa` on it.

A dialog in the vim command line will ask you for a description.

The output file will be created in the same directory as the
markdown file and named `description.svg`. After successfully
creating the new file, **vim-ditaadraw** will append the line

`![description](description.svg "description")`

after the code block.

If you just want to change an existing diagram, the plugin
detects the line after the code block and asks if you want
to keep the description or set a new one.

## Installation

**vim-ditaadraw** can be installed for example via
[vim-plug](https://github.com/junegunn/vim-plug),
by inserting the line

```
Plug 'mkirc/vim-ditaadraw'
```

into the vim-plug block inside your `vimrc`.

## Requirements

* vim 8+

* [ditaa 0.11](https://github.com/stathissideris/ditaa/releases/tag/v0.11.0)

(I'd reccomend ditaa 0.11 for more preset shapes and svg support,
lower-version releases also work, but you have to adjust `l:ditaa_args` in
`ditaadraw#RunDitaa`. Setting the args from `vimrc` is of course possible, but
not implemented. If you think it should be supported, let me know)

## TODO

* [] fall back to `.png` for lower ditaa versions

* [] detect imgs with `description` already present and ask what to do

* integrate with vim :h

