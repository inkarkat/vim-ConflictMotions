" ConflictMotions.vim: Motions to and inside SCM conflict markers.
"
" DEPENDENCIES:
"   - ingolines.vim autoload script
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   2.00.001	30-Oct-2012	file creation
let s:save_cpo = &cpo
set cpo&vim

function! ConflictMotions#Complete( ArgLead, CmdLine, CursorPos )
    return filter(['none', 'this', 'ours', 'base', 'theirs', 'both', 'all', '-', '.', '<', '|', '>', '+', '*'], 'v:val =~ "\\V" . escape(a:ArgLead, "\\")')
endfunction
function! s:CanonicalizeArgs( arguments, startLnum, endLnum )
    let l:result = []
    for l:what in a:arguments
	if l:what ==? 'both' || l:what ==# '+'
	    let l:result += ['ours', 'theirs']
	elseif l:what ==? 'all' || l:what ==# '*'
	    " The base section is optional; only capture it when it's there.
	    if search('^|\{7}|\@!', 'bnW', a:startLnum)
		let l:result += ['ours', 'base', 'theirs']
	    else
		let l:result += ['ours', 'theirs']
	    endif
	else
	    call add(l:result, l:what)
	endif
    endfor

    return l:result
endfunction
function! s:ErrorMsg( text )
    let v:errmsg = a:text
    echohl ErrorMsg
    echomsg v:errmsg
    echohl None
endfunction
function! s:CaptureSection()
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers.
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')
	silent execute printf('normal yi%s', g:ConflictMotions_SectionMapping)
	let l:section = @"
    call setreg('"', l:save_reg, l:save_regmode)
    let &clipboard = l:save_clipboard

    return l:section
endfunction
function! ConflictMotions#Take( takeStartLnum, takeEndLnum, arguments )
    let l:currentLnum = line('.')
    let l:hasTakeRange = (a:takeEndLnum != 1)

    execute printf("normal Va%s\<C-\>\<C-n>", g:ConflictMotions_ConflictMapping)
    let [l:startLnum, l:endLnum] = [line("'<"), line("'>")]
    if l:startLnum == l:endLnum
	" Capture failed; the cursor is not inside a conflict.
	" The mapping already beeped for us.
	call s:ErrorMsg('Not inside conflict')
	return
    elseif l:hasTakeRange && (a:takeStartLnum < l:startLnum || a:takeEndLnum > l:endLnum)
	execute l:currentLnum   | " Restore original cursor line.
	call s:ErrorMsg('Range outside conflict')
	return
    endif


    let l:sections = ''

    if l:hasTakeRange
	let l:sections .=
	\   join(
	\       filter(
	\           getline(a:takeStartLnum, a:takeEndLnum),
	\           'v:val !~# "^\\([<=>|]\\)\\{7}\\1\\@!"') + [''],
	\   "\n")
    endif

    for l:what in (empty(a:arguments) && ! l:hasTakeRange ?
    \   ['this'] :
    \   s:CanonicalizeArgs(split(a:arguments, '\s\+\|\%(\A\&\S\)\zs'), l:startLnum, l:endLnum)
    \)
	execute l:startLnum

	let l:isFoundMarker = 0
	if l:what ==? 'none' || l:what ==# '-'
	    let l:isFoundMarker = 1
	elseif l:what ==? 'this' || l:what ==# '.'
	    let l:isFoundMarker = 1
	    execute l:currentLnum
	elseif l:what ==? 'ours' || l:what ==# '<'
	    let l:isFoundMarker = 1
	elseif l:what ==? 'base' || l:what ==# '|'
	    let l:isFoundMarker = search('^|\{7}|\@!', 'W')
	elseif l:what ==? 'theirs' || l:what ==# '>'
	    let l:isFoundMarker = search('^=\{7}=\@!', 'W')
	else
	    call s:ErrorMsg('Invalid argument: ' . l:what)
	    return
	endif

	if ! l:isFoundMarker
	    execute l:currentLnum   | " Restore original cursor line.

	    call s:ErrorMsg('Conflict marker not found')
	    execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.

	    return
	endif

	if l:what !=? 'none' && l:what !=# '-'
	    let l:sections .= s:CaptureSection()
	endif
    endfor

    execute (empty(l:sections) ? '' : 'silent') printf('%d,%ddelete _', l:startLnum, l:endLnum)
    if ! empty(l:sections)
	call ingolines#PutWrapper(l:startLnum, 'put!', l:sections)
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
