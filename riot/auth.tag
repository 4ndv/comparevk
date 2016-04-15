<auth>
	<h3>Авторизация</h3>
	<p>Авторизуйтесь через VK для продолжения.</p>
	<a href="#" class="btn btn-primary" role="button" onclick={auth}>Авторизация</a>

	<script>
		self = this

		self.auth = ->
			VK.Auth.login (response)->
				if response.session
					window.obs.trigger 'auth-success'
				else
					window.obs.trigger 'auth-cancelled'
	</script>
</auth>