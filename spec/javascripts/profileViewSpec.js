  describe('profile view', function() {
    var view;
    beforeEach(function() {
      view = profileView();
    });

    it('fetches the list of games playing', function() {
      expect(view.find('.games-playing li').length).toEqual(1);
      expect(view.find('.games-playing li:first a:first').text()).toEqual('City of Golden Death (Online)');
    });

    it('fetches the list of games running', function() {
      expect(view.find('.games-running li').length).toEqual(2);
      expect(view.find('.games-running li:first a').text()).toEqual('City of Golden Death (Online)');
    });

    it('Links to the GM view for games youre running', function() {
      expect(view.find('.games-running li:first a').attr('href')).toEqual('#gmDetail-' + game.id);
    });

    it('Adds an GM badge games youre running', function() {
      expect(view.find('.games-running li:first span').text()).toEqual('[GM]');
    });

    it('Adds a button to leave a game youre playing', function() {
      var btn = view.find('.games-playing li a:last');
      expect(btn.text()).toEqual('Leave Game');
      expect(btn.attr('href')).toEqual('/user/leaveGame?id=' + game.id);
    });

    it('populates the profile form fields', function() {
      expect(view.find('.name').text()).toEqual('Ben Rady');
    });

    it('Fills in the PFS number', function() {
      expect(view.find('.pfsNumber').val()).toEqual('38803');
    });

    it('updates the signature image when the URL is entered', function() {
      view.find('.signatureUrl').val('/img/preloader.gif#other').change();
      expect(view.find('.signature-img').attr('src')).toEqual('/img/preloader.gif#other');
    });

    it('updates the initials image when the URL is entered', function() {
      view.find('.initialsUrl').val('/img/preloader.gif#init-other').change();
      expect(view.find('.initials-img').attr('src')).toEqual('/img/preloader.gif#init-other');
    });

    it('updates URLS when loaded', function() {
      expect(view.find('.signature-img').attr('src')).toEqual('/img/preloader.gif');
      expect(view.find('.initials-img').attr('src')).toEqual('/img/preloader.gif#init');
    });

    it('Can save fields', function() {
      spyOn($, 'ajax')
      view.find('.pfsNumber').val('12345');
      view.find('.save-btn').click();
      expect($.ajax).toHaveBeenCalledWith({ 
        url:'/user/info',
        method: 'post',
        data: JSON.stringify({
          pfsNumber: '12345',
          signatureUrl: '/img/preloader.gif',
          initialsUrl: '/img/preloader.gif#init',
        }),
        contentType: 'application/json'
      });
    });
  });

