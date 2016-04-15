riot.tag2('auth', '<h3>Авторизация</h3> <p>Авторизуйтесь через VK для продолжения.</p> <a href="#" class="btn btn-primary" role="button" onclick="{auth}">Авторизация</a>', '', '', function(opts) {
var self;

self = this;

self.auth = function() {
  return VK.Auth.login(function(response) {
    if (response.session) {
      return window.obs.trigger('auth-success');
    } else {
      return window.obs.trigger('auth-cancelled');
    }
  });
};
});