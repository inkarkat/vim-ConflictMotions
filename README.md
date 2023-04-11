CONFLICT MOTIONS
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin defines movement commands and text objects to go to and operate on
conflicting lines, as indicated by many revision control systems, like
Subversion, Git, etc. The source code management system inserts conflict
markers such as &lt;&lt;&lt;&lt;&lt;&lt;&lt;, =======, and &gt;&gt;&gt;&gt;&gt;&gt;&gt; on merges to indicate that the
automatic resolution failed; this plugin helps you with locating and resolving
these conflicts.

### SEE ALSO

To be alerted to the existence of conflict markers and to visually
differentiate the conflicted lines, you can use the highlighting, warnings and
custom buffer status provided by the companion ConflictDetection.vim plugin
([vimscript #4129](http://www.vim.org/scripts/script.php?script_id=4129)).

### RELATED WORKS

- conflict-marker.vim (https://github.com/rhysd/conflict-marker.vim)
  highlights conflicts and provides quite similar motions (utilizing
  matchit.vim for jumps within a conflict), and similar commands to resolve a
  conflict.
- The ConflictToDiff plugin ([vimscript #621](http://www.vim.org/scripts/script.php?script_id=621)) can split a (it says CVS, but
  also works for other tools) conflict file back into the two conflicting
  versions and a merge target, and offers commands to merge them.
- unimpaired.vim ([vimscript #1590](http://www.vim.org/scripts/script.php?script_id=1590)) has (among many other, largely unrelated)
  [n / ]n mappings that jump between conflict markers (like [x / ]x).
- linediff.vim ([vimscript #3745](http://www.vim.org/scripts/script.php?script_id=3745)) opens a conflict (or generically any selected
  ranges) as a diff in a separate tab page, allows edits to be synced back,
  and can pick one section and replace the entire conflict with it (like
  :ConflictTake).

USAGE
------------------------------------------------------------------------------

    ]x                      Go to [count] next start of a conflict.
    ]X                      Go to [count] next end of a conflict.
    [x                      Go to [count] previous start of a conflict.
    [X                      Go to [count] previous end of a conflict.

    ]=                      Go to [count] next conflict marker.
    [=                      Go to [count] previous conflict marker.
                            Mnemonic: = is in the separator between our and their
                            changes.

    ax                      "a conflict" text object, select [count] conflicts,
                            including the conflict markers.

    a=                      "a conflict section" text object, select [count]
                            sections (i.e. either ours, theirs, or base) including
                            the conflict marker above, and in the case of "theirs"
                            changes, also the ending conflict marker below.

    i=                      "inner conflict section" text object, select current
                            section (i.e. either ours, theirs, or base) without
                            the surrounding conflict markers.

    :ConflictTake           From the conflict the cursor is in, remove the markers
                            and keep the section the cursor is inside.
    :ConflictTake [none this ours base theirs both all query] [...]
    :ConflictTake [-.<|>+*?][...]
                            From the conflict the cursor is in, remove the markers
                            and keep the passed section(s) (in the order they are
                            specified).
                                none, - = delete the entire conflict
                                both    = ours theirs               (+ = <>)
                                all     = ours [base] theirs        (* = <|>)
                                query   = ask which sections to take
                            Note: | must be escaped as \|.
    :[range]ConflictTake [none this ours base theirs both all range query] [...]
    :[range]ConflictTake [-.<|>+*:?][...]
                            When the cursor is inside a conflict, and the [range]
                            covers part of that conflict:
                            From the conflict the cursor is in, remove the markers
                            and keep the passed range (without contained markers)
                            (and any passed sections in addition; include the
                            "range" / ":" argument to put the range somewhere
                            other than the end).
                            Otherwise, when a large range (like %) is passed:
                            For each conflict that starts in [range], remove the
                            markers and keep the passed section(s) / ask which
                            section(s) should be kept. You can answer the question
                            with either the symbol or the choice's starting
                            letter. An uppercase letter will apply the choice to
                            all following conflicts.

    <Leader>xd              Delete the entire current conflict / all conflicts in
                            the selection.
    <Leader>x<              Keep our changes, delete the rest.
    <Leader>x|              Keep the change base, delete the rest.
    <Leader>x>              Keep their changes, delete the rest.
    <Leader>x+              Keep both our and their changes, delete the rest.
    <Leader>x*              Keep our, the change base, and their changes.
    <Leader>x?              Ask which sections to take.

    <Leader>x.              Keep the current conflict section, delete the rest.
    {Visual}<Leader>x.      From the conflict the cursor is in, remove the markers
                            and keep the selected lines (without contained markers).
                            For each conflict that starts in the selection, remove
                            the markers and ask which section(s) should be kept.

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-ConflictMotions
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim ConflictMotions*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the CountJump plugin ([vimscript #3130](http://www.vim.org/scripts/script.php?script_id=3130)).
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.029 or
  higher.
- repeat.vim ([vimscript #2136](http://www.vim.org/scripts/script.php?script_id=2136)) plugin (optional)
- visualrepeat.vim ([vimscript #3848](http://www.vim.org/scripts/script.php?script_id=3848)) plugin (optional)

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

To change the default motion mappings, use:

    let g:ConflictMotions_ConflictBeginMapping = 'x'
    let g:ConflictMotions_ConflictEndMapping = 'X'
    let g:ConflictMotions_MarkerMapping = '='

To also change the [ / ] prefix to something else, follow the instructions for
CountJump-remap-motions. (This requires CountJump 1.60.)

To change the default text object mappings, use:

    let g:ConflictMotions_ConflictMapping = 'x'
    let g:ConflictMotions_SectionMapping = '='

To also change the i / a prefix to something else, follow the instructions for
CountJump-remap-text-objects. (This requires CountJump 1.60.)

If you don't want the mappings for :ConflictTake:

    let g:ConflictMotions_TakeMappingPrefix = ''

To redefine the mappings, either clear the prefix and use the
&lt;Plug&gt;(ConflictMotionsTake...) mapping targets, or adapt via the prefix and
mapping configuration, e.g.:

    let g:ConflictMotions_TakeMappingPrefix = '<Leader>='
    let g:ConflictMotions_TakeMappings = [['d', 'None'], ['x', 'This'], ['o', 'Ours'], ['b', 'Base'], ['t', 'Theirs']]

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-ConflictMotions/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### 2.11    02-Feb-2020
- FIX: Need to convert the passed range into net lines, as we're gonna turn
  off folding.
- Adapt: :ConflictTake does not recognize that it has no range passed since
  Vim 8.1.1241. Thanks to lilydjwg for submitting a patch. Need to default
  -range to -1 and check &lt;count&gt; == -1 instead of &lt;line2&gt;.
- ENH: Add default mappings &lt;Leader&gt;x+, &lt;Leader&gt;x\*, &lt;Leader&gt;x?

__You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.029!__

##### 2.10    21-Jul-2014
- ENH: Define both normal and visual mode mappings for all mappings, not the
  exclusive either-or. The new visual mode mappings will select the
  corresponding section in all conflicts found in the selected range.
  (Application on a partially selected conflict is denied by an error since
  version 2.02.)
- ENH: Enable repeat of all mappings, also (with visualrepeat.vim) across
  modes. Thanks to Maxim Gonchar for the suggestion.
- Handle folded ranges overlapping the conflicts. Thanks to Maxim Gonchar for
  reporting this. When querying which conflict sections to keep, open folds so
  that if possible the entire conflict is visible, but at least the section
  markers.
- Re-allow combining range inside conflict with section argument, but only for
  the :ConflictTake command, not the mappings.

##### 2.02    19-Jul-2014
- Regression: Version 2.01 introduced a bad offset calculation, potentially
  resulting in left-over conflicts, e.g. on :%ConflictTake.
- Do not allow combination of a range inside a conflict with a section
  argument, as the two contradict each other. Print an error instead.

##### 2.01    31-May-2014
- BUG: "E16: Invalid range" error when taking a conflict section of a hunk at
  the end of the file. Use ingo#lines#PutBefore(). Thanks to Kballard for
  reporting this on the Vim Tips Wiki and suggesting the fix.
- BUG: Taking conflicts where a single hunk spans the entire buffer adds a
  blank line. Use ingo#lines#Replace(), which now handles this. Thanks to
  Kballard for reporting this on the Vim Tips Wiki.
- The CountJump operator-pending mapping will beep when the inner conflict
  section is empty, but for taking such a section, the beep is unexpected.
  Detect this special case and skip the CountJump text object then. Thanks to
  Kballard for reporting this on the Vim Tips Wiki.
- Abort on error of :ConflictTake.
- Use ingo#register#KeepRegisterExecuteOrFunc().

__You need to update to
  ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.019!__

##### 2.00    23-Apr-2013
- FIX: Don't create the default mapping for
  &lt;Plug&gt;(ConflictMotionsTakeSelection) in select mode; it should insert a
  literal &lt;Leader&gt; there.
- Add the :ConflictTake command to resolve a conflict by picking a section(s).
- Add dependency to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)).

##### 1.10    06-Sep-2012
- The [z / ]z mappings disable the built-in mappings for moving over the current
open fold. Oops! Change default to [= / ]= / i= / a=. (= as for the characters
in the separator between our and their change).

##### 1.00    28-Mar-2012
- First published version.

##### 0.01    12-Mar-2012
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2012-2023 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
