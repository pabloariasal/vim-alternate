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

function! s:Alternate()
    let file_components = split(expand("%:t"), '\.')
    " everything after the first dot
    let file_extension = '.' . join(file_components[1:], '.')

    let alternate_extension_mapping = s:GetMappingForExtension(file_extension)
    if empty(alternate_extension_mapping)
        call s:AlternateWarning('no alternate extension configured for extension ' . file_extension)
        return
    endif

    " everything before the first dot
    let filename_without_extension = file_components[0]

    let alternate_extension = alternate_extension_mapping[file_extension]
    while !empty(alternate_extension) && alternate_extension != file_extension
        let alternate_file_name = filename_without_extension . alternate_extension
        let alternate_file_path = findfile(alternate_file_name)
        if !empty(alternate_file_path)
            exe 'e ' . alternate_file_path
            return
        endif
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
