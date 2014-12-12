  describe("New Game View", function() {
    var view;
    beforeEach(function() {
      view = newGame();
    });

    it('disables the submit button until the fields are filled in', function() {
      expect(view.find('button.new-game-submit').prop('disabled')).toBeTruthy();
    });

    it('Enables the submit button when all fields are entered', function() {
      view.find('input.game-title').val('My Title').change();
      view.find('input.datetime').val('2009-02-13').change();
      expect(view.find('button.new-game-submit').prop('disabled')).toBeFalsy();
    });

    it('Parses the time, setting the time to noon if the time is midnight', function() {
      view.find('input.datetime').val('2009-02-13').change();
      expect(view.find('input.datetime-hidden').val()).toEqual('1234548000000');
    });
  });

