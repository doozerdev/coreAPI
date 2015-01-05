$(document).ready(function() {

  $("#get_lists").click(function() {
    $.ajax({
      url: '/api/items/index',
      type: 'GET',
      headers: {session_id: $('textarea#current_session_id').val()},
      dataType: "json"
    })
    .done(function(data, textStatus) {
      $("#get_lists_response_status").html(textStatus)

      $('#get_lists_response_json').text(JSON.stringify(data, null, '\t'))
    }).fail(function( jqXHR, textStatus ) {
      $("#get_lists_response_status").html("<strong class='text-danger'>" + 
        jqXHR.status + ": " + textStatus + "</strong>")
    })
    .always(function(){
      $("#get_lists_response").removeClass("hidden")
    });
  });


  $("#get_children").click(function() {
    $.ajax({
      url: '/api/items/' + 
      $('textarea#get_children_parent_id').val() + '/children',
      type: 'GET',
      headers: {session_id: $('textarea#current_session_id').val()},
      dataType: "json"
    })
    .done(function(data, textStatus) {
      $("#get_children_response_status").html(textStatus)
    
      var items = ''
      $.each(data, function(index, item) {
        items = items + '<strong>' + item.title + '</strong> - ' + item.id + '<br />'
      });
      $("#get_children_response_children").html(items)

      $('#get_children_response_json').text(JSON.stringify(data, null, '\t'))
    }).fail(function( jqXHR, textStatus ) {
      $("#get_children_response_status").html("<strong class='text-danger'>" + 
        jqXHR.status + ": " + textStatus + "</strong>")
    }).always(function(){
      $("#get_children_response").removeClass("hidden")
    });
  });

  $("#create_item").click(function() {
    $.ajax({
      url: '/api/items/create',
      type: 'POST',
      headers: {session_id: $('textarea#current_session_id').val()},
      data: {
        parent:     $('#create_item_parent_id').val(),
        title:      $('#create_item_title').val(),
        notes:      $('#create_item_notes').val(),
        order:      $('#create_item_order').val(),
        duedate:    $('#create_item_due_date').val(),
        done:       $('#create_item_done').prop('checked'),
        archive:    $('#create_item_archive').prop('checked') 
        },
      dataType: "json"
    })
    .done(function(data, textStatus) {
      $("#create_item_response_status").html(textStatus)
      $('#create_item_response_json').text(JSON.stringify(data, null, '\t'))
    
    }).fail(function( jqXHR, textStatus ) {
      $("#create_item_response_status").html("<strong class='text-danger'>" + 
        jqXHR.status + ": " + textStatus + "</strong>")
    })
    .always(function(){
      $("#create_item_response").removeClass("hidden")
    });
  });

  $("#get_item").click(function() {
    $.ajax({
      url: '/api/items/' + 
      $('#get_item_item_id').val() + '/show',
      type: 'GET',
      headers: {session_id: $('textarea#current_session_id').val()},
      dataType: "json"
    })
    .done(function(data, textStatus) {
      $("#get_item_response_status").html(textStatus)
      $('#get_item_response_json').text(JSON.stringify(data, null, '\t'))
    }).fail(function( jqXHR, textStatus ) {
      $("#get_children_response_status").html("<strong class='text-danger'>" + 
        jqXHR.status + ": " + textStatus + "</strong>")
    }).always(function(){
      $("#get_item_response").removeClass("hidden")
    });
  });

  $("#update_item").click(function() {
    $.ajax({
      url: '/api/items/' + 
      $('#update_item_item_id').val(),
      type: 'PUT',
      headers: {session_id: $('textarea#current_session_id').val()},
      data: {
        parent:     $('#update_item_parent_id').val(),
        title:      $('#update_item_title').val(),
        notes:      $('#update_item_notes').val(),
        order:      $('#update_item_order').val(),
        duedate:    $('#update_item_due_date').val(),
        done:       $('#update_item_done').prop('checked'),
        archive:    $('#update_item_archive').prop('checked') 
        },
      dataType: "json"
    })
    .done(function(data, textStatus) {
      $("#update_item_response_status").html(textStatus)
      $('#update_item_response_json').text(JSON.stringify(data, null, '\t'))
    
    }).fail(function( jqXHR, textStatus ) {
      $("#update_item_response_status").html("<strong class='text-danger'>" + 
        jqXHR.status + ": " + textStatus + "</strong>")
    })
    .always(function(){
      $("#update_item_response").removeClass("hidden")
    });
  });

  $("#search_button").click(function() {
    $.ajax({
      url: '/api/items/' + 
      $('#search_term').val() + '/search',
      type: 'GET',
      headers: {session_id: $('textarea#current_session_id').val()},
      dataType: "json"
    })
    .done(function(data, textStatus) {
      $("#search_response_status").html(textStatus)
      $('#search_response_json').text(JSON.stringify(data, null, '\t'))
    }).fail(function( jqXHR, textStatus ) {
      $("#search_response_status").html("<strong class='text-danger'>" + 
        jqXHR.status + ": " + textStatus + "</strong>")
    }).always(function(){
      $("#search_response").removeClass("hidden")
    });
  });

  $("#common_words").click(function() {
    $.ajax({
      url: '/api/items/common/words',
      type: 'GET',
      headers: {session_id: $('textarea#current_session_id').val()},
      dataType: "json"
    })
    .done(function(data, textStatus) {
      $("#common_words_response_status").html(textStatus)

      $('#common_words_response_json').text(JSON.stringify(data, null, '\t'))
    }).fail(function( jqXHR, textStatus ) {
      $("#common_words_response_status").html("<strong class='text-danger'>" + 
        jqXHR.status + ": " + textStatus + "</strong>")
    })
    .always(function(){
      $("#common_words_response").removeClass("hidden")
    });
  });



  $("#delete_item").click(function() {
    $.ajax({
      url: '/api/items/' + 
      $('#delete_item_item_id').val(),
      type: 'DELETE',
      headers: {session_id: $('textarea#current_session_id').val()},
      dataType: "json"
    })
    .done(function(data, textStatus) {
      $("#delete_item_response_status").html(textStatus)
      $('#delete_item_response_json').text(JSON.stringify(data, null, '\t'))
    }).fail(function( jqXHR, textStatus ) {
      $("#delete_children_response_status").html("<strong class='text-danger'>" + 
        jqXHR.status + ": " + textStatus + "</strong>")
    }).always(function(){
      $("#delete_item_response").removeClass("hidden")
    });
  });

});
