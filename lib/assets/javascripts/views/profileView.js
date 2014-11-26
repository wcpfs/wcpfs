function profileView() {
  function gameItem(game, viewName) {
    var item = $('#templates .well-item-sm').clone();
    item.find('a').attr('href', '#' + viewName + '-' + game.gameId).text(game.title);
    return item;
  }

  function playerItem(game) {
    return gameItem(game, 'gameDetail');
  }

  function gmItem(game) {
    return gameItem(game, 'gmDetail');
  }

  function profileInfo() {
    return {
      pfsNumber: view.find('.pfsNumber').val(),
      signatureUrl: view.find('.signatureUrl').val(),
      initialsUrl: view.find('.initialsUrl').val()
    }
  }

  var view = $('#templates .profile-view').clone();
  $.getJSON('/user/games', function(games) {  
    view.find('.games-playing').append(_.map(games.playing, playerItem));
    view.find('.games-running').append(_.map(games.running, gmItem));
  });

  userInfoPromise().done(function(data) { 
    applyValues(data, view.find('.profile-info'));
    updateImages();
  });

  function updateImages() {
    view.find('.signature-img').attr('src', profileInfo().signatureUrl);
    view.find('.initials-img').attr('src', profileInfo().initialsUrl);
  }

  view.find('.signatureUrl').change(updateImages);
  view.find('.initialsUrl').change(updateImages);

  view.find('.save-btn').click(function() {  
    store('/user/info', profileInfo());
    return false;
  });

  return view;
}
