function! ditaadraw#InsideBounds(current, upper, lower)
    " simple bounds check

    if a:upper < a:lower && a:current >= a:upper && a:current <= a:lower
        return 1
    endif

    return 0

endfunction

function! ditaadraw#InsideDitaaBlock(current)

    let l:upper = search('```ditaa', 'b')
    let l:lower = search('```')

    call setpos('.', a:current)

    if ditaadraw#InsideBounds(a:current[1], l:upper, l:lower)
        return 1
    endif

    return 0

endfunction


function! ditaadraw#GetBlockLineNumbers(current)
    " get line nums of ditaa code block
    " (assumes being inside)

    let l:upper = search('```ditaa', 'b')
    let l:lower = search('```')

    call setpos('.', a:current)

    return [l:upper, l:lower]

endfunction

function! ditaadraw#GetContentForLines(lines)
    " gets lines of code block in current buffer

    if !empty(a:lines)
        return getbufline(bufnr('%'), a:lines[0]+1, a:lines[1]-1)
    endif

    return 0

endfunction

function! ditaadraw#InputLabel()

    redraw
    let l:label = input("Title: ")
    redraw

    if empty(l:label)
        throw "No label given, aborting."
    endif

    return l:label

endfunction

function! ditaadraw#RunDitaa(lines_content, label)

    let l:ditaa_args = ['--transparent']
    let l:tempfile = [tempname()]
    let l:out_file = [shellescape(expand('%:p:h').'/'.a:label . '.png')]
    let l:cmd = ['ditaa'] + l:ditaa_args + l:tempfile + l:out_file

    " echo join(l:cmd, " ")

    call writefile(a:lines_content, l:tempfile[0])

    let report = system(join(l:cmd, " "))

    call delete(l:tempfile[0])

endfunction

function! ditaadraw#HasMarkdownLink(lower)

    let l:match = matchstr(getline(a:lower+1), '!\[.*\]\(.*\)')

    if empty(l:match)
        return 0
    endif

    return 1

endfunction

function! ditaadraw#AddMarkdownLink(lower, label)

    let l:out_file = './' .a:label. '.png'
    let l:img_link = "![" .a:label. "](" .l:out_file. " \"" .a:label. "\")"

    if getline(a:lower+1)[0] == '!' "Img link already present
        call setline(a:lower+1, l:img_link)
    else
        call append(a:lower, l:img_link)
    endif

endfunction

function! ditaadraw#ConfirmKeepLabel()

    return confirm("Present link detected. Keep label?", "&Yes\n&No", 1)

endfunction

function! ditaadraw#GetPresentLabel(lower)

    return matchstr(getline(a:lower+1), '!\[\zs.*\ze\]\(.*\)')

endfunction


function! ditaadraw#Main()

    let l:current = getpos('.')

    if ditaadraw#InsideDitaaBlock(l:current)

        let l:lines = ditaadraw#GetBlockLineNumbers(l:current)
        let l:lower = l:lines[1]

        let l:lines_content = ditaadraw#GetContentForLines(l:lines)

        if ditaadraw#HasMarkdownLink(l:lower) && ditaadraw#ConfirmKeepLabel() == 1
            let l:label = ditaadraw#GetPresentLabel(l:lower)
        else
            let l:label = ditaadraw#InputLabel()
            call ditaadraw#AddMarkdownLink(l:lower, l:label)
        endif

        call ditaadraw#RunDitaa(l:lines_content, l:label)

    else
        return 0
    endif


endfunction

""""""" Keyboard Mapping """"""

nnoremap <Leader>dit :call ditaadraw#Main()<CR>

