scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of("vital")
let s:L = s:V.import("Data.List")


let s:default_config = {
\	"ignore_pat"     : "",
\	"separater"      : " | ",
\	"current_bufname_format" : "[%s]",
\}

let s:obj = {
\	"__buffers" : [],
\	"__config"  : {},
\}

function! s:obj.config(...)
	return deepcopy(extend(self.__config, get(a:, 1, {})))
endfunction


function! s:obj.refresh()
	if empty(self.__buffers)
		let self.__buffers = [bufnr("%")]
	endif

	if len(self.__buffers) <= 1
		return self
	endif

	let self.__buffers = s:L.uniq(self.__buffers)
	call filter(self.__buffers, "buflisted(v:val) && bufexists(v:val)")

	let ignore_pat = self.config().ignore_pat
	if ignore_pat != ""
		call filter(self.__buffers, "bufname(v:val) !~ ignore_pat")
	endif
	
	return self
endfunction


function! s:obj.add(bufnr)
	call add(self.__buffers, a:bufnr)
	return self.refresh()
endfunction


function! s:obj.remove(bufnr)
	let index = index(self.buffers(), a:bufnr)
	if index == -1
		return self
	endif

	call remove(self.__buffers, index)
	return self
endfunction


function! s:obj.buffers()
	return deepcopy(self.__buffers)
endfunction


function! s:obj.fnamemodify(bufnr)
	let label  = bufname(a:bufnr)
	if label == ""
		let label = "無名-" . getbufvar(a:bufnr, "&filetype")
	elseif &buftype != "nofile"
		let label = fnamemodify(label,':p:h:t').'/'. fnamemodify(label,':t')
	endif

	if a:bufnr == bufnr("%") && len(self.buffers()) > 1
		let label = printf(self.config().current_bufname_format, label)
	endif

	if getbufvar(a:bufnr, "&modified")
		let label = '+'.label
	endif
	return label
endfunction


function! s:obj.to_str(...)
	call self.refresh()
	if empty(self.buffers())
		return "-"
	endif
	return join(map(self.buffers(), 'self.fnamemodify(v:val)'), self.config().separater)
endfunction


function! s:obj.next_buffer(expr)
	let index = (index(self.buffers(), bufnr(a:expr)) + 1) % len(self.buffers())
	return get(self.buffers(), index, -1)
endfunction


function! s:obj.prev_buffer(expr)
	let index = (index(self.buffers(), bufnr(a:expr)) - 1) % len(self.buffers())
	return get(self.buffers(), index, -1)
endfunction


function! s:new()
	let obj = deepcopy(s:obj)
	let obj.__config = deepcopy(s:default_config)
	return obj
endfunction


function! swindle#current()
	let w:swindle =  get(w:, "swindle", s:new())
	return w:swindle
endfunction


function! swindle#jump_next()
	execute "buffer" swindle#current().next_buffer(bufnr("%"))
endfunction


function! swindle#jump_prev()
	execute "buffer" swindle#current().prev_buffer(bufnr("%"))
endfunction


function! swindle#close_buffer(...)
	let bufnr = get(a:, 1, bufnr("%"))
	call swindle#jump_next()
	call swindle#current().remove(bufnr)
	if len(swindle#current().buffers()) == 0
		close
	endif
endfunction


function! swindle#on_BufWinEnter()
	call swindle#current().add(bufnr("%"))
endfunction


function! swindle#get_tablabel()
	return swindle#current().to_str()
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
