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
      view.find('input.datetime').val('5pm February 13th, 2009').change();
      expect(view.find('button.new-game-submit').prop('disabled')).toBeFalsy();
    });

    it('parses the date and places the timestamp in a hidden field', function() {
      view.find('input.datetime').val('5pm February 13th, 2009').change();
      expect(view.find('input.datetime-hidden').val()).toEqual('1234566000000');
    });
  });

