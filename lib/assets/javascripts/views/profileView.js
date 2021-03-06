function profileView() {
  function gameItem(game, viewName) {
    var item = $('#templates .well-item-sm').clone();
    item.find('a').attr('href', '#' + viewName + '-' + game.id).text(game.title);
    return item;
  }

  function playerItem(game) {
    var btn = $('#templates .leave-game-button').clone();
    btn.find('a').attr('href', '/user/leaveGame?id=' + game.id);
    return gameItem(game, 'gameDetail').append(btn);
  }

  function gmItem(game) {
    return gameItem(game, 'gmDetail').append($('<span>').addClass('left-padding-sm').text('[GM]'));
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
