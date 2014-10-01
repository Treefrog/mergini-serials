[

	/* ========================================================================================
		Init file for mergini app
	======================================================================================== */
	
	protect => {
		handle_error => { log_critical('Serials load error: '+error_msg+'... '+error_stack) }
		not merginiApp->isInstalled('serials') ? 
			merginiApp->install(
				-appid			= 'serials',
				-appname		= 'Serial Numbers',
				-description	= 'Serial Number Management.',
				-publisher		= 'Treefrog Inc.',
				-apptype		= 'native',
				-aswrapper		= true
			)
		lassoapp_include_current('_oop/oop.lasso')
	}

]