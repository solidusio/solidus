$ ->
  $(document).ajaxStart ->
    $("#progress").show()

  $(document).ajaxStop ->
    $("#progress").hide()

