[
// app js
]var app = {};
app.init = function() {
	$('.sendto').on('click',function(){ document.location.href = $(this).attr('location'); return false; });

	$('.serialstatus').on('click',function(){
		var dataObj			= {};
		dataObj.obj			= 'serial';
		dataObj.id			= $(this).attr('identity');
		$.ajax({
			url:		'[lassoapp_link('/xhr/toggle.xhr')]',
			data:		dataObj,
			async:		true,
			type:		'post',
			cache:		false,
			dataType:	'json',
			success:	function(xhr) {
				if(xhr.successful === true){
					app.processlist(xhr);
				} else {
					$('.feedback').html(xhr.feedback).addClass('error');
				}
			}
		});
		return false;
	});
	$('#seriallist .delete').on('click',function(){
		if(confirm('Are you sure you wish to delete this serial asset?')) {			
			$.ajax({
				url:		'[lassoapp_link('/xhr/toggle.xhr')]?obj=serial&delete&id='+$(this).attr('identity'),
				async:		true,
				type:		'get',
				cache:		false,
				dataType:	'json',
				success:	function(xhr) {
					app.processlist(xhr);
				}
			});
		}
		return false;
	});
};
app.processlist = function(xhr) {
	//<!--
	var contents = '';
	var columns = xhr.columns;
	for (i = 0; i < xhr.rows.length; i++) {
		var thisline = xhr.template.toString();
		var thisrow = xhr.rows[i];
		for (f = 0; f < columns.length; f++) {
			var assemble = new RegExp("{"+columns[f]+"}", "gi");
			thisline = thisline.replace(assemble,thisrow[columns[f]]);
		}
		contents += thisline;
	}
	$('#'+xhr.target).html(contents);
	$('.'+xhr.target+'pager').html(xhr.pager);
	app.init();
	// -->
};

$(document).ready(function() {
	app.init();
});
