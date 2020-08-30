" alternate.vim
"
" BSD-2 license applies, see LICENSE for licensing details.
if exists('g:loaded_alternate')
    finish
endif
let g:loaded_alternate = 1

command! Alternate :call <SID>Alternate()

function! s:InitVariable(var, value)
    if !exists(a:var)
        exec 'let ' . a:var . ' = ' . string(a:value)
    endif
endfunction

call s:InitVariable('g:AlternateExtensionMappings', [{'.cpp' : '.h', '.h' : '.hpp', '.hpp' : '.cpp'}, {'.c': '.h', '.h' : '.c'}])
call s:InitVariable('g:AlternatePaths', ['.', '../itf', '../include', '../src'])

function! s:Alternate()
    let file_components = split(expand("%:t"), '\.')
    " everything after the first dot
    let file_extension = '.' . join(file_components[1:], '.')

    let alternate_extension_mapping = s:GetMappingForExtension(file_extension)
    if empty(alternate_extension_mapping)
        call s:AlternateWarning('no alternate extension configured for extension ' . file_extension)
        return
    endif

    let file_path = expand("%:p:h")
    " everything before the first dot
    let filename_without_extension = file_components[0]

    let alternate_extension = alternate_extension_mapping[file_extension]
    while !empty(alternate_extension) && alternate_extension != file_extension
        for alternate_path in g:AlternatePaths
            let alternate_file_path = file_path . '/' . alternate_path . '/' . filename_without_extension . alternate_extension
            if filereadable(alternate_file_path)
                " Switch to the alternate file, modify the file path to be as
                " short as possible, without any dot dot entries.
                exe 'e ' . fnamemodify(alternate_file_path, ":p:.")
                return
            endif
        endfor
        let alternate_extension = alternate_extension_mapping[alternate_extension]
    endwhile

    call s:AlternateWarning('no alternate file found')
endfun

function! s:GetMappingForExtension(extension)
    for mapping in g:AlternateExtensionMappings
        if has_key(mapping, a:extension)
            return mapping
        endif
    endfor
endfun

function! s:AlternateWarning(msg)
    echohl WarningMsg
    echomsg 'vim-alternate: ' . a:msg
    echohl None
endfun
