if exists('g:loaded_falcon')
  finish
endif
let g:loaded_falcon = 1

function! s:HandleInactiveBackground() abort
  if !exists('g:falcon_inactive')
    let g:falcon_inactive = 1
  endif

  if !exists('g:falcon_background')
    let g:falcon_background = 1
  endif

  hi! NonText guifg=#000000 ctermfg=NONE guibg=#000000 ctermbg=0 gui=NONE cterm=NONE
  hi! Normal guifg=#b4b4b9 ctermfg=249 guibg=#000000 ctermbg=0 gui=NONE cterm=NONE
  hi! InactiveWindow guibg=#000000 ctermbg=0
  hi! NormalNC guifg=#b4b4b9 ctermfg=249 guibg=#000000 ctermbg=0 gui=NONE cterm=NONE
  hi! EndOfBuffer guifg=#000000 ctermfg=0 guibg=#000000 ctermbg=0 gui=NONE cterm=NONE

  hi! LspInlayHint guifg=#AAAAAA guibg=#000000 ctermbg=0 gui=italic,bold cterm=italic,bold
  hi! DiagnosticError guifg=Red guibg=#000000 ctermbg=0

  hi! link SnacksDashboardDir Text
  hi! link BlinkCmpGhostText Comment
endfunction

function! s:MyHighlights() abort
  hi! HoverFloatBorder ctermfg=255 ctermbg=0 guibg=#000000
  hi! LspReferenceRead gui=bold guifg=LightYellow
  hi! LspReferenceText gui=bold guifg=LightYellow
  hi! LspReferenceWrite gui=bold guifg=LightYellow

  hi! SignColumn ctermfg=NONE ctermbg=0 guibg=#000000
  hi! NonText ctermfg=NONE ctermbg=0 guifg=#000000 guibg=#000000
  hi! LineNr ctermfg=NONE ctermbg=0 guibg=#000000

  hi! VertSplit guifg=#fff
  hi! cursorLineNr gui=bold guifg=#fabd2f guibg=#1A1B2A

  hi! Search guifg=#969896 guibg=#f0c674
  hi! IncSearch guifg=#282a2e guibg=#de935f
  hi! PMenuSel guifg=#282a2e guibg=#c5c8c6
  hi! Pmenu guibg=#00010a guifg=#fff
  hi! MatchParen guifg=orange gui=bold

  hi! CursorLine gui=bold

  hi! link CompeDocumentation NormalFloat

  hi! clear Conceal

  hi! link CompeDocumentation NormalFloat

  hi! Floaterm guibg=black ctermbg=0
  hi! FloatermNC guibg=black ctermbg=0

  hi! link javaConceptKind javaTypeDef

  hi! link ElCommand Statusline
  hi! link ElNormal Statusline
  hi! link ElVisual Statusline
  hi! link ElVisualLine Statusline
  hi! link ElVisualBlock Statusline

  hi! Visual guibg=#3a3a3a cterm=italic gui=italic
  hi! SpecialKey guifg=#FF0000 guibg=#00FF00 ctermfg=red ctermbg=green
endfunction

function! s:SetColors() abort
  if !exists('g:colors_name') || !exists('g:loaded_falcon')
    return
  endif

  call s:HandleInactiveBackground()
  call s:MyHighlights()
endfunction

augroup falcon_colors
  autocmd!
  autocmd VimEnter,ColorScheme * call s:SetColors()
augroup END
