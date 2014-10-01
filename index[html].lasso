[
	lassoapp_include_current('/common/menu.lasso')

	local(action = string, feedback = string, nameCache = merginiNameCache, companyNameCache = merginiCompanyCache)
	web_request->params->asStaticArray >> 'add' ? #action = 'add'
	web_request->params->asStaticArray >> 'edit' ? #action = 'edit'
	web_request->params->asStaticArray >> 'save' ? #action = 'save'

	local(
		sk			= 0,
		limit		= 20
	)
	/* ========================================================
		generic skip set
	======================================================== */
	if(web_request->param('sk')->asString->size) => { 
		#sk = integer(web_request->param('sk')->asString)
		$sv_skips->insert('serial_list' = #sk)
	else 
		#sk = integer($sv_skips->find('serial_list'))
	}

	
	
	local(this = mergini_serial)
	if(#action == 'save') => {
		if(web_request->param('id')->asString->size) => {
			#this->idde(web_request->param('id')->asString)
			protect => { #this->load }
		}
		protect => {
			handle_error => {
				#this->id == 0 ? #action = 'add' | #action = 'edit'
				#feedback = error_msg
				#feedback->append('<pre>'+error_stack+'</pre>') // uncomment this line for debug
			}
			fail_if(not web_request->param('name')->asString->size,'Please enter a valid serial asset name')
			
			#this->name = web_request->param('name')->asString
			
			
			with attr in #this->options->keys do => {
				local(item = string)
				protect => {
					handle_error => {
						#item = web_request->param('attr_'+#attr)->asString
					}
					match(#this->options->find(#attr)->first) => {
						case('int')
							#item = integer(web_request->param('attr_'+#attr)->asString)
						case('dec')
							#item = decimal(web_request->param('attr_'+#attr)->asString)
						case('date')
							#item = date(web_request->param('attr_'+#attr)->asString)
						case
							#item = web_request->param('attr_'+#attr)->asString
					}

				}
				#this->setAttribute(#attr,#item)
			}
			
			#this->save
			#action = string
		}
	else(#action == 'edit')
		if(web_request->param('id')->asString->size) => {
			#this->idde(web_request->param('id')->asString)
			protect => { #this->load }
		}
		protect => {
			handle_error => {
				#feedback = error_msg
				#action = string
			}
			fail_if(not #this->id > 0,'Invalid ID')
		}
	}
]
[if(not #action->size) => {^]
<h2 class="l">Asset List <a href="?add" class="small pl">Add <span class="icon-square_plus"></span></a></h2>
</header>

	<div class="form-wrap row rounded">
		<div class="feedback[#feedback->size ? ' attn']">[#feedback]YAY YAR</div>
		<form action="?search" method="post" class="multi beside cfx">
			<div class="row">
				<div class="col two-thirds">
					<fieldset>
						<label>Filter:</label>
						<input type="text" name="filter_txt" value="[$sv_serialsfilter->find('txt')]" placeholder="Search">
						<button class="icon" type="reset">
							<span class="icon-close-icon"></span>
						</button>
					</fieldset>
				</div>
				<div class="col one-third">
					<fieldset class="form-actions">
						<input type="Submit" value="Search">
						<input type="button" class="sendto reset" location="?search" value="Reset">
					</fieldset>
				</div>
			</div>
			<div class="row">
				<div class="col one-third">
					<fieldset>
						<label>Vendor:</label>
						<div class="styled_select inline">
							<select name="filter_vendor">
								<option value="-1"[integer($sv_serialsfilter->find('vendor')) < 0 ? ' selected="selected"']>Ignore</option>
								<option value="0"[not integer($sv_serialsfilter->find('vendor')) ? ' selected="selected"']>Unassigned</option>
								[with t in merginiCompany->list where #t->status and #t->issupplier do {^]
								<option value="[#t->id]"[integer($sv_serialsfilter->find('vendor')) == #t->id ? ' selected="selected"']>[#t->name]</option>
								[^}]
							</select>
						</div>
					</fieldset>
				</div>
				<div class="col one-third">
					<fieldset>
						<label>Assigned To:</label>
						<div class="styled_select inline">
							<select name="filter_assignedto">
								<option value="-1"[integer($sv_serialsfilter->find('assignedto')) < 0 ? ' selected="selected"']>Ignore</option>
								<option value="0"[not integer($sv_serialsfilter->find('assignedto')) ? ' selected="selected"']>Unassigned</option>
								[merginiUser->selectOptions(integer($sv_serialsfilter->find('assignedto')),-status=-1,-showstatus=true)]
							</select>
						</div>
					</fieldset>
				</div>
			</div>
		</form>
	</div>

<table class="admin">
	<thead>
		<tr>
			<th>Software Title</th>
			<th>Version</th>
			<th>Assigned To</th>
			<th>Vendor</th>
			<th colspan="3">Actions</th>
		</tr>
	</thead>
	<tbody id="seriallist">
[
local(thelist = mergini_serial->filter(
	-vendor		= integer($sv_serialsfilter->find('vendor')),
	-assignedto	= integer($sv_serialsfilter->find('assignedto')),
	-txt		= $sv_serialsfilter->find('txt')->asString
	)
)
if(#thelist->size) => {^
	with t in #thelist skip integer($sv_skips->find('serial_list')) take #limit do => {^

]
		<tr id="serial_number[#t->ide]">
			<td>[#t->name]</td>
			<td>[#t->version]</td>
			<td>[integer(#t->assignedTo) ? #nameCache->lookup(integer(#t->assignedTo)) | 'Unassigned']</td>
			<td>[integer(#t->vendor) ? #companyNameCache->lookup(integer(#t->vendor)) | 'Unassigned']</td>
			<td>
				<a href="#" identity="[#t->ide]" class="serialstatus">[#t->status ? '<span class="icon-icon-checked small"></span><span class="check_label">Active</span>' | '<span class="icon-icon-unchecked small"></span><span class="check_label">Inactive</span>']</a>
			</td>
			<td>
				<span class="tooltip" aria-label="Edit">
					<a href="?edit&id=[#t->ide]"><span class="icon-square_edit small edit" identity="[#t->ide]"></span></a>
				</span>
			</td>
			<td>
				<span class="tooltip" aria-label="Delete">
					<span class="icon-trash-icon small delete" identity="[#t->ide]"></span>
				</span>
			</td>
		</tr>
[
	^}
	else
	]
		<tr>
			<td colspan="5">No serial number assets configured.</td>
		</tr>

[
^}
]
	</tbody>
</table>
[if(#thelist->size) => {^]
<div class="pager row">[
mergini_pageThrough(
	-base				= '',
	-found				= #thelist->size,
	-maxrecords			= #limit,
	-skip				= integer($sv_skips->find('serial_list')),
	-shownfirst			= integer($sv_skips->find('serial_list'))+1,
	-shownlast			= (integer($sv_skips->find('serial_list'))+#limit <= #thelist->size ? integer($sv_skips->find('serial_list'))+#limit | #thelist->size),
	-divider			= '',
	-ShowingClass		= 'pager-counter',
	-PagerNavClass		= '',
	-prevClass			= 'LEAP_prev-link ',
	-prevGroupClass		= 'LEAP_prev-link pagera',
	-nextClass			= 'LEAP_next-link pagera',
	-nextGroupClass		= 'LEAP_next-link pagera'
	)
]</div>
[^}]
[else(#action == 'edit' || #action == 'add')
	local(firstattrlist = array)
]
<h3>[#action == 'edit' ? 'Edit' | 'Add'] Serial Asset</h3>
</header>
<form action="?save" class="multi beside" method="post">
	[#action == 'edit' ? '<input type="hidden" name="id" value="'+#this->ide+'">']
	<div class="feedback[#feedback->size ? ' attn']">[#feedback]</div>
	<fieldset>
		<label for="new_asset_name">Software Title</label>
		<input type="text" name="name" placeholder="Enter Asset Name" value="[#this->name]">
	</fieldset>
	<fieldset class="attr_version">
		<label for="attr_version">Version</label>
		<input type="text" name="attr_version" placeholder="Version" value="[#this->version]">
	</fieldset>
	<fieldset class="attr_purchaseDate">
		<label for="attr_purchaseDate">Purchase Date (mm/dd/yyyy)</label>
		<input type="text" name="attr_purchaseDate" placeholder="Enter Purchase Date (mm/dd/yyyy)" value="[protect => {^ #this->purchaseDate->format('%m/%d/%yy') ^}]">
	</fieldset>
	<fieldset class="attr_serial">
		<label for="attr_serial">Serial #</label>
		<input type="text" name="attr_serial" placeholder="Serial #" value="[#this->serial]">
	</fieldset>

	<fieldset class="attr_location">
		<label for="attr_vendor">Vendor</label>
		<div class="styled_select inline">
			<select name="attr_vendor">
				<option value="0"[not integer(#this->vendor) ? ' selected="selected"']>Unassigned</option>
				[with t in merginiCompany->list where #t->status and #t->issupplier do {^]
				<option value="[#t->id]"[integer(#this->vendor) == #t->id ? ' selected="selected"']>[#t->name]</option>
				[^}]
			</select>
		</div>
	</fieldset>
	<fieldset class="attr_assignedTo">
		<label for="attr_assignedTo">Assigned To</label>
		<div class="styled_select inline">
			<select name="attr_assignedTo">
				<option value="0"[not integer(#this->assignedto) ? ' selected="selected"']>Unassigned</option>
				[merginiUser->selectOptions(integer(#this->assignedto),-status=-1,-showstatus=true)]
			</select>
		</div>
	</fieldset>

	<fieldset class="attr_notes">
		<label for="attr_notes">Notes</label>
		<textarea name="attr_notes">[#this->notes]</textarea>
	</fieldset>




	<fieldset class="form-actions panel">
		<button type="submit">Save</button>
		<button type="button" class="cancel" onClick="document.location.href='?'">Cancel</button>
	</fieldset>
</form>

[^}]