[
	define mergini_serial => type {
		parent merginiItem
		data
			protected appid::string				= 'serials',		// identifier for app. ideally make same as appname
			protected vartype::string			= 'serialasset',	// identifier for your item type
			/* ===============================================================================
			options map defines attributes available to the item, 
			plus their datatype and default value
			- Camel case the attribute name to create a human readable name when called like:
				mergini_asset->attrName('nextMaintenanceDate')
			- underscores will also convert to spaces in output of attrName method.
			=============================================================================== */
			public options::map				= map(
												'version' 				= pair('text' 	= '1.0'), 
												'vendor' 				= pair('int' 	= 0),
												'purchaseDate' 			= pair('date' 	= date), 
												'assignedTo'			= pair('int' 	= 0),
												'serial' 				= pair('text' 	= ''), 
												'assetLink' 			= pair('int' 	= 0),
												'notes' 				= pair('text' 	= '')
												)
		// maintenance record - linked table
		// do later
		
		
		protected attrNameExceptions(txt::string) => {
			return // no exceptions needed
//			not #txt->size ? return
//			return map(
//				'qty' = 'QTY'
//				)->find(#txt)
		}
		public filter(-vendor::integer=-1,-assignedTo::integer=-1,-txt::string='') => {
			#vendor < 0 && #assignedto < 0 && not #txt->size ? return ..list(false)
			local(list = ..list(false))
			#vendor >= 0 ? #list = (with n in #list where integer(#n->vendor) == #vendor select #n)->asStaticArray
			#assignedto >= 0 ? #list = (with n in #list where integer(#n->assignedto) == #assignedto select #n)->asStaticArray
			#txt->size ? #list = (with n in #list where #n->name >> #txt select #n)->asStaticArray
			return #list
		}	
	}

	
]