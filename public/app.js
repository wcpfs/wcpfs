$(window).ready(function() {  
  var pairings = {
    "Ben": "Peggy",
    "Jenny": "Brad",
    "Brian": "Bruce",
    "Lily": "Ben",
    "Brad": "Lily",
    "Bruce": "Brian",
    "Peggy": "Jenny"
  };
  function addRow(giver, getter) {
    var row = $('#templates .giver-row').clone();
    row.find('.giver').text(giver);
    row.find('.getter').text(getter);
    $('.main-table tbody').append(row);
  }

  $.each(pairings, addRow);
});
