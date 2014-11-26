function gameDetailView(gameId) {
  var view = $('#templates .game-detail-view').clone();
  function showGame(game) {
    populateGameTemplate(game, view);
  }
  $.getJSON('/games/detail?gameId=' + gameId, showGame);
  return view;
}
