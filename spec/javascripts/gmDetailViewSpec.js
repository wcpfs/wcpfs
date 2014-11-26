  describe('GM Detail View', function() {
    var view;
    beforeEach(function() {
      spyOn(window, 'imageEditor');
      view = gmDetailView(game.gameId);
    });

    it('Adds chronicle sheet editor', function() {
      var item = view.find('.chronicle-sheet');
      expect(item.find('h2').text()).toEqual("Chronicle Sheet");
    });

    it('hides the chronicle sheet if it is not available', function() {
      expect(view.find('.image-editor')).not.toBeVisible();
    });

    it('Adds the date for the game', function() {
      expect(view.find('.when').text()).toEqual('Wednesday, November 5th');
    });

    it('Adds the notes and other fields', function() {
      expect(view.find('.notes').text()).toEqual(game.notes);
    });

    it('hides the join button', function() {
      expect(view.find('.join-button')).not.toBeVisible();
    });
    
  });
