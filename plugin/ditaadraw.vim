function! ditaadraw#IsInsideBounds(current, upper, lower)
    " simple bounds check

    if a:upper < a:lower && a:current >= a:upper && a:current <= a:lower
        return 1
    endif
    return 0
endfunction

function! ditaadraw#GetBlockLineNumbers()
    " get line nums of code block, if cursor is inside of
    " or at the boundaries

    let l:current = getpos('.')
    let l:upper = search('```ditaa', 'b')
    let l:lower = search('```')

    call setpos('.',l:current)

    if ditaadraw#IsInsideBounds(l:current[1], l:upper, l:lower)
        return [l:upper, l:lower]
    endif

    return []
endfunction

function! ditaadraw#GetContentForLines(lines)
    " gets lines of code block in current buffer

    if !empty(a:lines)
        return getbufline(bufnr('%'), a:lines[0]+1, a:lines[1]-1)
    endif

    return 0

endfunction

function! ditaadraw#GetLabel()
    let l:label = input("Title: ")
    redraw
    return l:label
endfunction

function! ditaadraw#RunDitaa(lines_content, label)

    let l:ditaa_args = ['--transparent']
    let l:tempfile = [tempname()]
    let l:out_file = [shellescape(a:label . '.png')]
    let l:cmd = ['ditaa'] + l:ditaa_args + l:tempfile + l:out_file

    " echo join(l:cmd, " ")

    call writefile(a:lines_content, l:tempfile[0])

    let report = system(join(l:cmd, " "))

    call delete(l:tempfile[0])

endfunction

function! ditaadraw#AddMarkdownImgLink(lines, label)

    let l:out_file = './' .a:label. '.png'
    let l:img_link = "![" .a:label. "](" .l:out_file. " \"" .a:label. "\")"

    if getline(a:lines[1]+1)[0] == '!' "Img link already present
        call setline(a:lines[1]+1, l:img_link)
    else
        call append(a:lines[1], l:img_link)
    endif

endfunction


function! TestDD()

    let l:lines = ditaadraw#GetBlockLineNumbers()
    let l:lines_content = ditaadraw#GetContentForLines(l:lines)
    let l:label = ditaadraw#GetLabel()

    if empty(l:lines_content)
        echo "Not in ditaa block"
        return 0
    endif

    if empty(l:label)
        echo "No label given, aborting."
        return 0
    endif

    call ditaadraw#RunDitaa(l:lines_content, l:label)
    call ditaadraw#AddMarkdownImgLink(l:lines, l:label)
endfunction
