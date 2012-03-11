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

function! HighlightConflicts()
    syntax region conflictOurs   start="^<\{7}<\@!.*$"hs=e+1   end="^\([=|]\)\{7}\1\@!"me=s-1 keepend containedin=TOP contains=conflictOursMarker
    syntax region conflictBase   start="^|\{7}|\@!.*$"hs=e+1   end="^=\{7}=\@!"me=s-1         keepend containedin=TOP contains=conflictBaseMarker
    syntax region conflictTheirs start="^=\{7}=\@!.*$"hs=e+1   end="^>\{7}>\@!.*$"me=e+1,he=s-1         keepend containedin=TOP contains=conflictSeparatorMarker,conflictTheirsMarker

    syntax match conflictOursMarker             "^<\{7}<\@!.*$" contained contains=conflictOursMarkerSymbol
    syntax match conflictOursMarkerSymbol       "^<\{7}"        contained
    syntax match conflictBaseMarker             "^|\{7}|\@!.*$" contained contains=conflictBaseMarkerSymbol
    syntax match conflictBaseMarkerSymbol       "^|\{7}"        contained
    syntax match conflictSeparatorMarker        "^=\{7}=\@!.*$" contained contains=conflictSeparatorMarkerSymbol
    syntax match conflictSeparatorMarkerSymbol  "^=\{7}"        contained
    syntax match conflictTheirsMarker           "^>\{7}>\@!.*$" contained contains=conflictTheirsMarkerSymbol
    syntax match conflictTheirsMarkerSymbol     "^>\{7}"        contained
endfunction
highlight def link conflictOurs  DiffAdd
highlight def link conflictBase  DiffChange
highlight def link conflictTheirs DiffText
highlight def link conflictOursMarkerSymbol         NonText
highlight def link conflictBaseMarkerSymbol         NonText
highlight def link conflictSeparatorMarkerSymbol    NonText
highlight def link conflictTheirsMarkerSymbol       NonText
highlight def conflictOursMarker        gui=bold guifg=#bada9f
highlight def conflictBaseMarker        gui=bold guifg=#e5d5ac
highlight def conflictSeparatorMarker   gui=bold guifg=#a0a0a0
highlight def conflictTheirsMarker      gui=bold guifg=#8cbee2

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
