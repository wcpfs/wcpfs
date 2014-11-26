function gmDetailView(gameId) {
  var view = $('#templates .game-detail-view').clone();

  function assetItem(link, text) {
    var item = $('#templates .well-item-sm').clone();
    item.find('a').attr('href', link).text(text);
    return item;
  }

  function showGame(game) {
    populateGameTemplate(game, view);
    var chronicleSheetElem = $('#templates .chronicle-sheet').clone();
    if (game.chronicle.sheetUrl) {
      chronicleSheetElem.append(imageEditor(game));
    }
    view.append(chronicleSheetElem);
  }
  $.getJSON('/games/detail?gameId=' + gameId, showGame);
  view.find('.gm-option').show();
  view.find('.player-option').hide();
  return view;
}
