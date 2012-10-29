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
"	001	30-Oct-2012	file creation

function! ConflictMotions#Complete( ArgLead, CmdLine, CursorPos )
    return filter(['none', 'this', 'ours', 'base', 'theirs', '-', '.', '<', '|', '>'], 'v:val =~ "\\V" . escape(a:ArgLead, "\\")')
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
	execute printf('normal yi%s', g:ConflictMotions_SectionMapping)
	let l:section = @"
    call setreg('"', l:save_reg, l:save_regmode)
    let &clipboard = l:save_clipboard

    return l:section
endfunction
function! ConflictMotions#Take( what )
    let l:currentLnum = line('.')

    execute printf("normal Va%s\<C-\>\<C-n>", g:ConflictMotions_ConflictMapping)
    let [l:startLnum, l:endLnum] = [line("'<"), line("'>")]
    if l:startLnum == l:endLnum
	" Capture failed; the cursor is not inside a conflict.
	" The mapping already beeped for us.
	return
    endif

    execute l:startLnum
    if a:what ==? 'none' || a:what ==# '-'
	let l:isFoundMarker = 1
    elseif a:what ==? 'this' || a:what ==# '.' || empty(a:what)
	let l:isFoundMarker = 1
	execute l:currentLnum
    elseif a:what ==? 'ours' || a:what ==# '<'
	let l:isFoundMarker = 1
    elseif a:what ==? 'base' || a:what ==# '|'
	let l:isFoundMarker = search('^|\{7}|\@!', 'W')
    elseif a:what ==? 'theirs' || a:what ==# '>'
	let l:isFoundMarker = search('^=\{7}=\@!', 'W')
    else
	call s:ErrorMsg('Invalid argument: ' . a:what)
	return
    endif

    if ! l:isFoundMarker
	call s:ErrorMsg('Conflict marker not found')
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
	return
    endif

    if a:what ==? 'none'
	let l:section = ''
    else
	let l:section = s:CaptureSection()
    endif

    execute (empty(l:section) ? '' : 'silent') printf('%d,%ddelete _', l:startLnum, l:endLnum)
    if ! empty(l:section)
	call ingolines#PutWrapper(l:startLnum, 'put!', l:section)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
