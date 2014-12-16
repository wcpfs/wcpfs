function gameDetailView(id) {
  var view = $('#templates .game-detail-view').clone();
  function showGame(game) {
    populateGameTemplate(game, view);
  }
  $.getJSON('/games/detail?id=' + id, showGame);
  return view;
}
