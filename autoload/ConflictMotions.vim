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
function! s:ErrorMsg( text, isBeep )
    let v:errmsg = a:text
    echohl ErrorMsg
    echomsg v:errmsg
    echohl None

    if a:isBeep
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
    endif
endfunction
function! s:FindEndOfConflict()
    return search('^>\{7}>\@!', 'nW')
endfunction
function! s:GetCurrentConflict( currentLnum )
    " This is a re-implementation of the
    " CountJump#TextObject#TextObjectWithJumpFunctions() that doesn't beep and
    " modify the visual selection.
    if ! search('^<\{7}<\@!', 'bcW')
	return [0, 0]
    endif

    let l:endLnum = s:FindEndOfConflict()
    if ! l:endLnum || l:endLnum < a:currentLnum
	return [0, 0]
    endif

    return [line('.'), l:endLnum]
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
    let l:save_view = winsaveview()
    let l:hasRange = (a:takeEndLnum != 1)

    let [l:startLnum, l:endLnum] = s:GetCurrentConflict(l:currentLnum)
    let l:isInsideConflict = (l:startLnum != 0 && l:endLnum != 0)

    if l:hasRange
	if l:isInsideConflict && a:takeStartLnum > l:startLnum && a:takeEndLnum < l:endLnum
	    " Take the selected lines from the current conflict.
	    call ConflictMotions#TakeFromConflict(l:currentLnum, l:startLnum, l:endLnum, a:arguments, 'this', 1, a:takeStartLnum, a:takeEndLnum)
	else
	    " Go through all conflicts found in the range.
	    let [l:takeStartLnum, l:takeEndLnum] = [a:takeStartLnum, a:takeEndLnum]
	    call cursor(l:takeStartLnum, 1)
	    let l:searchFlags = 'c' " Allow match at the current position for the first one.
	    while l:startLnum <= l:takeEndLnum
		let l:startLnum = search('^<\{7}<\@!', 'W' . l:searchFlags, l:takeEndLnum)
		if l:startLnum == -1
		    break
		endif
		let l:searchFlags = ''
		let l:endLnum = s:FindEndOfConflict()
		if l:endLnum == -1
		    break
		endif

		let l:offset = ConflictMotions#TakeFromConflict(l:startLnum, l:startLnum, l:endLnum, a:arguments, 'query', 0, 0, 0)
		if l:offset == -1
		    break
		else
		    let l:takeEndLnum -= l:offset
		endif
	    endwhile

	    if ! empty(l:searchFlags)
		" Not a single conflict was found.
		call winrestview(l:save_view)
		call s:ErrorMsg(printf('No conflicts %s', (a:takeStartLnum == 1 && a:takeEndLnum == line('$') ? 'in buffer' : 'inside range')), 1)
	    endif
	endif
    elseif ! l:isInsideConflict
	" Capture failed; the cursor is not inside a conflict.
	call winrestview(l:save_view)
	call s:ErrorMsg('Not inside conflict', 1)
    else
	" Take from the current conflict.
	call ConflictMotions#TakeFromConflict(l:currentLnum, l:startLnum, l:endLnum, a:arguments, 'this', 0, 0, 0)
    endif
endfunction
function! ConflictMotions#TakeFromConflict( currentLnum, startLnum, endLnum, arguments, defaultArgument, isKeepRange, takeStartLnum, takeEndLnum )
    let l:sections = ''

    if a:isKeepRange
	let l:sections .=
	\   join(
	\       filter(
	\           getline(a:takeStartLnum, a:takeEndLnum),
	\           'v:val !~# "^\\([<=>|]\\)\\{7}\\1\\@!"') + [''],
	\   "\n")
    endif

    for l:what in (empty(a:arguments) && ! a:isKeepRange ?
    \   [a:defaultArgument] :
    \   s:CanonicalizeArgs(split(a:arguments, '\s\+\|\%(\A\&\S\)\zs'), a:startLnum, a:endLnum)
    \)
	call cursor(a:startLnum, 1)

	let l:isFoundMarker = 0
	if l:what ==? 'none' || l:what ==# '-'
	    let l:isFoundMarker = 1
	elseif l:what ==? 'this' || l:what ==# '.'
	    let l:isFoundMarker = 1
	    call cursor(a:currentLnum, 1)
	elseif l:what ==? 'ours' || l:what ==# '<'
	    let l:isFoundMarker = 1
	elseif l:what ==? 'base' || l:what ==# '|'
	    let l:isFoundMarker = search('^|\{7}|\@!', 'W')
	elseif l:what ==? 'theirs' || l:what ==# '>'
	    let l:isFoundMarker = search('^=\{7}=\@!', 'W')
	else
	    call s:ErrorMsg('Invalid argument: ' . l:what, 0)
	    return -1
	endif

	if ! l:isFoundMarker
	    call cursor(a:startLnum, 1)
	    call s:ErrorMsg('Conflict marker not found', 1)
	    return -1
	endif

	if l:what !=? 'none' && l:what !=# '-'
	    let l:sections .= s:CaptureSection()
	endif
    endfor

    execute (empty(l:sections) ? '' : 'silent') printf('%d,%ddelete _', a:startLnum, a:endLnum)
    if empty(l:sections)
	return (a:endLnum - a:startLnum + 1)
    else
	let l:prevLineCnt = line('$')
	call ingolines#PutWrapper(a:startLnum, 'put!', l:sections)
	return (a:endLnum - a:startLnum + 1) - (line('$') - l:prevLineCnt)
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
