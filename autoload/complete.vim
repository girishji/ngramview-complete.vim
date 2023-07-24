vim9script

export var options: dict<any> = {
    maxCount: 10,
    cacheSize: 100,
}

var cache: dict<list<any>> = {}

def CacheAdd(key: string, val: list<string>)
    var cacheSize = max([10, options.cacheSize])
    if cache->len() > cacheSize
	for k in cache->keys()->slice(0, cacheSize / 2)
	    cache->remove(k)
	endfor
    endif
    cache[key] = val
enddef

var googjob: job
var Googcmd = (context) => $'https://books.google.com/ngrams/json?content={context}&year_start=1800&year_end=2019&corpus=en-2019&smoothing=3'

def GotNextWords(channel: channel, msg: string)
    var words = msg->js_decode()
    if words->len() < 2
	return
    endif
    var key = words[0].ngram->matchstr('[^*]\+')->split()->join('')
    words->map((_, v) => v.ngram->matchstr('\a\+$'))->slice(1)
    CacheAdd(key, words)
enddef

export def Completor(findstart: number, base: string): any
    var line = getline('.')->strpart(0, col('.') - 1)
    var EndsInSpace = () => line =~ '\s$'
    if EndsInSpace()
	if findstart == 1
	    var context = line->matchstr('\v((\a+)\s+){1,3}$')
	    if context->empty() || !executable('curl')
		return -2
	    endif
	    if googjob->job_status() ==? 'run'
		googjob->job_stop('kill')
	    endif
	    context = context->split()->join('+') .. '+*'
	    var cmd = ['curl', '-s', Googcmd(context)]
	    googjob = job_start(cmd, {
		out_cb: funcref('GotNextWords'),
		stoponexit: 'kill',
	    })
	    return line->len() + 1
	elseif findstart == 2
	    return googjob->job_status() ==? 'run' ? 0 : 1
	endif
    else
	if findstart == 1
	    var prefix = line->matchstr('\a\+$')
	    return prefix->empty() ? -2 : line->len() - prefix->len() + 1
	elseif findstart == 2
	    return 1
	endif
    endif

    var context = EndsInSpace() ? line->matchstr('\v((\a+)\s+){1,3}$') :
	line->matchstr('\v((\a+)\s+){1,3}\ze(\a+)$')
    if context->empty()
	return []
    endif
    context = context->split()->join('')
    var citems: list<dict<any>> = []
    if cache->has_key(context)
	var items = cache[context]
	if !EndsInSpace()
	    items->filter((_, v) => v =~? $'^{base}')
	    items->sort((v1, v2) => v1->len() < v2->len() ? -1 : 1)
	endif
	for item in items
	    citems->add({ abbr: item, word: item, kind: 'N' })
	endfor
    endif
    return citems->slice(0, options.maxCount)
enddef
