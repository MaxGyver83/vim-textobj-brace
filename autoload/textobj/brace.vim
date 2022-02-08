function! s:select(object_type)
    let initial_view = winsaveview()
    let initial_position = getpos('.')

    " search forward for a closing bracket
    let line = search(']\|)\|}\|>', 'ceW')
    if line == 0
        return 0
    endif
    let end_position = getpos('.')

    " go to matching opening bracket
    normal! %
    let start_position = getpos('.')
    if start_position == end_position
        return 0
    endif

    " go back to initial position
    call winrestview(initial_view)

    " search again, this time backwards
    let line = search('[\|(\|{\|<', 'bceW')
    if line > 0
        let alternative_start_position = getpos('.')
        normal! %
        let alternative_end_position = getpos('.')

        " prefer brackets found by searching backwards if only those
        " surround the cursor position. Example: { p|rintf("x"); }
        if alternative_start_position != alternative_end_position
                \ && s:is_inside(initial_position, start_position, end_position) == 0
                \ && s:is_inside(initial_position, alternative_start_position, alternative_end_position) == 1
            let start_position = alternative_start_position
            let end_position = alternative_end_position
        endif
        " TODO: This fails for: { printf("x");| printf("y"); }
        " And for: | { printf("x"); printf("y"); }
        " (not finding the surrounding/following curly brackets)
    endif

    if a:object_type ==? 'i'
        let start_position[2] += 1
        if end_position[2] == 1
            " go up one line
            let end_position[1] -= 1
            " go to end of line
            let end_position[2] = v:maxcol
        else
            let end_position[2] -= 1
        endif
    endif

    return ['v', start_position, end_position]
endfunction


function! s:is_inside(position, start_position, end_position)
    if a:position[1] < a:start_position[1]
        return 0
    elseif a:position[1] == a:start_position[1] && a:position[2] < a:start_position[2]
        return 0
    elseif a:position[1] > a:end_position[1]
        return 0
    elseif a:position[1] == a:end_position[1] && a:position[2] > a:end_position[2]
        return 0
    endif
    return 1
endfunction


function! s:select_a()
    return s:select('a')
endfunction


function! s:select_i()
    return s:select('i')
endfunction


function! textobj#brace#select_i() abort
    return s:select_i()
endfunction


function! textobj#brace#select_a() abort
    return s:select_a()
endfunction
