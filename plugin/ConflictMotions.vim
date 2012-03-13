" ConflictMotions.vim: summary
"
" DEPENDENCIES:
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	12-Mar-2012	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_ConflictMotions') || (v:version < 700)
    finish
endif
let g:loaded_ConflictMotions = 1

call CountJump#Motion#MakeBracketMotion('', 'x', 'X', '^<\{7}<\@!', '^>\{7}>\@!', 0)
call CountJump#Motion#MakeBracketMotion('', 'z', '', '^\([<=>|]\)\{7}\1\@!', '', 0)

call CountJump#TextObject#MakeWithCountSearch('', 'x', 'a', 'V', '^<\{7}<\@!', '^>\{7}>\@!')
call CountJump#TextObject#MakeWithCountSearch('', 'x', 'i', 'V', '^\([<=|]\)\{7}\1\@!', '^\([=>|]\)\{7}\1\@!')
call CountJump#TextObject#MakeWithCountSearch('', 'z', 'a', 'V', '^\([<=|]\)\{7}\1\@!', '\ze\n\([=|]\)\{7}\1\@!\|^>\{7}>\@!')

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
