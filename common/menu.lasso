[
	local(appname = 'serials')

//	Loading javascript after jquery
	$loadJavascriptInFoot->insert(lassoapp_link('/js/app.js'))
	
	session_addVar($gv_SessionName, 'sv_serialsfilter')
	var(sv_serialsfilter)->isNotA(::map) 	? var(sv_serialsfilter 		= map('txt' = string, 'vendor' = -1, 'assignedTo' = -1))
	
	if(web_request->params->asStaticArray >> 'search') => {
		$sv_serialsfilter = map('txt' = string, 'vendor' = -1, 'assignedTo' = -1) // back to default
		web_request->params->asStaticArray >> 'filter_txt' ? 		$sv_serialsfilter->insert('txt' = web_request->param('filter_txt')->asString)
		web_request->params->asStaticArray >> 'filter_vendor' ? 	$sv_serialsfilter->insert('vendor' = integer(web_request->param('filter_vendor')->asString))
		web_request->params->asStaticArray >> 'filter_assignedTo' ? $sv_serialsfilter->insert('assignedTo' = integer(web_request->param('filter_assignedTo')->asString))
	}

]

<header class="row">
<h1><div class="app_icon"><img src="[lassoapp_link('/icon.svg')]"></div> Serial Number Management</h1>
<nav class="rb ra mb">
	<ul class="mainnav horizontal">
		<li><a href="[mergini_apphome][#appname]"><span class="icon-home small"></span></a></li>
		<li><a href="[mergini_apphome][#appname]/suppliers" class="ml">Vendors / Suppliers</a></li>
	</ul>
</nav>