// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require_tree .

var ready;

ready = function() {
};

$(document).ready(ready);
$(document).on('page:load', ready);


$(document).on('click', '#stop-stream', function(e) {
	e.preventDefault();
	e.stopPropagation();
	var id = $('#stop-stream').data('id');
	var stream_id = $('#stop-stream').data('stream-id');
	callServer('/users/'+id+'/twitter_streams/'+stream_id+'/stop', 'POST', {}, null, null);
});

$(document).on('click', '#stop-twitter-search', function(e) {
	e.preventDefault();
	e.stopPropagation();
	var id = $('#stop-twitter-search').data('id');
	var stream_id = $('#stop-twitter-search').data('search-id');
	callServer('/users/'+id+'/twitter_searches/'+stream_id+'/stop', 'POST', {}, null, null);
});

$(document).on('click', '#stop-facebook-search', function(e) {
	e.preventDefault();
	e.stopPropagation();
	var id = $('#stop-facebook-search').data('id');
	var stream_id = $('#stop-facebook-search').data('search-id');
	callServer('/users/'+id+'/facebook_searches/'+stream_id+'/stop', 'POST', {}, null, null);
});


function callServer(url, method, params, target, callback) {
	
	$.ajax({
        url: url, // Route to the Script Controller method
       type: method,
   dataType: "json",
       data: params, // This goes to Controller in params hash, i.e. params[:file_name]
   complete: function() {
	   			if(callback != null)
	   				callback();
   			 },
    success: function(data, textStatus, xhr) {
    			if (target != null)
    				$(target).html(data.html);
             },
      error: function() {
    	  		if (target != null)
    	  			$(target).html("Ajax error!");
             }
	});
}
