[
	merginiSetup
	$sv_uid == 0 ? redirect_url(mergini_home)
	
	var(json = map)
	local(
			successful	= false,
			feedback	= string,
			sk			= 0,
			limit		= 20,
			list		= array,
			nameCache = merginiNameCache, 
			companyNameCache = merginiCompanyCache
	)
	
//	if(web_request->param('obj')->asString == 'location') => {
		local(this = mergini_serial)
		$json->insert('target' = 'seriallist')
		$json->insert('columns' = array('id','name','version','assignedTo','vendor','status'))
		local(template = '<tr id="serial_number{id}">
			<td>{name}</td>
			<td>{version}</td>
			<td>{assignedTo}</td>
			<td>{vendor}</td>
			<td>
				<a href="#" identity="{id}" class="serialstatus">{status}</a>
			</td>
			<td>
				<span class="tooltip" aria-label="Edit">
					<a href="?edit&id={id}"><span class="icon-square_edit small edit" identity="{id}"></span></a>
				</span>
			</td>
			<td>
				<span class="tooltip" aria-label="Delete">
					<span class="icon-trash-icon small delete" identity="{id}"></span>
				</span>
			</td>
		</tr>')
		#template->replace('\t','') // there for readability only!
		#template->replace('\n','') // there for readability only!
		$json->insert('template' = #template)
		
		
		/* ========================================================
			generic skip set
		======================================================== */
		if(web_request->param('sk')->asString->size) => { 
			#sk = integer(web_request->param('sk')->asString)
			$sv_skips->insert('serial_list' = #sk)
		else 
			#sk = integer($sv_skips->find('serial_list'))
		}

		
		#this->idde(web_request->param('id')->asString)
		#this->load
		
		if(web_request->params->asStaticArray >> 'delete' && #this->id > 0) => {
			#this->delete
			#successful = true
			#feedback = 'Serial asset deleted successfully.'
			
		else
			local(state = #this->flip(-silent=false))
			#successful = true
			#feedback = 'Serial asset '+(not #state ? 'de')+'activated successfully.'
			
		}

		

		local(thelist = mergini_serial->filter(
			-vendor		= integer($sv_serialsfilter->find('vendor')),
			-assignedto	= integer($sv_serialsfilter->find('assignedto')),
			-txt		= $sv_serialsfilter->find('txt')->asString
			)
		)
		with obj in #thelist skip #sk take #limit do => {
			local(n = map)
			#n->insert('id' = #obj->ide)
			#n->insert('name' = #obj->name)
			#n->insert('version' = #obj->version)
			#n->insert('assignedTo' = integer(#obj->assignedTo) ? #nameCache->lookup(integer(#obj->assignedTo)) | 'Unassigned')
			#n->insert('vendor' = integer(#obj->vendor) ? #companyNameCache->lookup(integer(#obj->vendor)) | 'Unassigned')
			#n->insert('status' = #obj->status ? '<span class="icon-icon-checked small"></span><span class="check_label">Active</span>' | '<span class="icon-icon-unchecked small"></span><span class="check_label">Inactive</span>')
			#list->insert(#n)
		}		
		$json->insert('rows'= #list)
//		$json->insert('pager'='')
		$json->insert('pager' = mergini_pageThrough(
			-base				= '',
			-found				= #thelist->size,
			-maxrecords			= #limit,
			-skip				= #sk,
			-shownfirst			= #sk+1,
			-shownlast			= (#sk+#limit <= #thelist->size ? #sk+#limit | #thelist->size),
			-divider			= '',
			-ShowingClass		= 'pager-counter groupcount',
			-PagerNavClass		= '',
			-prevClass			= 'LEAP_prev-link pagera',
			-prevGroupClass		= 'LEAP_prev-link pagera',
			-nextClass			= 'LEAP_next-link pagera',
			-nextGroupClass		= 'LEAP_next-link pagera',
			-locationattr		= 'groups'
			)
		)
		
//	}
	$json->insert('successful'= #successful)
	$json->insert('feedback'= #feedback)
	local('xout' = json_serialize($json))
	#xout->trim
	#xout
]