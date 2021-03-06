function homeView() {
  function addGames(games) {
    var list = view.find('.game-list').empty();
    _.each(_.sortBy(games, 'datetime'), function(game) {  
      var gameItem = $('#templates .game-item').clone();
      populateGameTemplate(game, gameItem);
      gameItem.find('.detail-button').attr('href', '/#gameDetail-' + game.id);
      list.append(gameItem);
    })
  }

  var view = $('#templates .home-view').clone();
  $.getJSON('/games', addGames);
  return view;
}

