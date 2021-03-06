<app>
	<auth hide={authorized}></auth>
	<virtual show={authorized}>
		<h3>Введите сравниваемые группы или публичные страницы</h3>
		<div class="alert alert-danger" role="alert" show={error}>Проверьте введенные сообщества</div>
		<form onsubmit={process} class="form-inline">
			<fieldset disabled={working}>
			  <div class='form-group'>
			  	<label for="first">vk.com/</label>
			    <input type="text" class="form-control" name="first" id="first" required>
			  </div>
			  <div class='form-group'>
			  	<label for="second">vk.com/</label>
			    <input type="text" class="form-control" name="second" id="second" required>
			  </div>
			  <div class='form-group'>
			  	<button type="submit" class="btn btn-primary">Сравнить</button>
			  </div>
			</fieldset>
		</form>
		<p>Это может занять некоторое время.</p>
	</virtual>

	<virtual if={found}>
		<hr />
		<div class="row">
			<virtual each={groups}>
		  	<div class="col-md-6">
		  		<div class="media">
					  <div class="media-left">
					    <a href="#">
					      <img class="media-object" src="{photo}">
					    </a>
					  </div>
					  <div class="media-body">
					    <h4 class="media-heading">{name}</h4>
					    <div class="progress" hide={subs_processed == 100}>
							<div class="progress-bar" role="progressbar" style="width: {subs_processed}%;">
								{subs_processed}%
							</div>
						</div>
					  </div>
					</div>
		  	</div>
		  </virtual>
		</div>
	</virtual>

	<virtual if={done}>
		<hr />
			<h4>Пересечений: {foundcount}</h4>
				<p><i>Выводится максимум 200 пользователей</i></p>
		  	<div class="media" each={founditems}>
			  <div class="media-left">
			    <a href="#">
			      <img class="media-object" src="{photo_50}">
			    </a>
			  </div>
			  <div class="media-body">
			    <h4 class="media-heading"><a href="https://vk.com/id{id}">{first_name} {last_name}</a></h4>
			  </div>
			</div>
		</div>
	</virtual>

	<script>
		self = this

		window.obs.on 'auth-success', ->
			self.update { authorized: true }

		VK.Auth.getLoginStatus (r)->
			if r.status == 'connected'
				window.obs.trigger 'auth-success'

		fetch = (group)->
			#VK.Api.call 'groups.getMembers', { group_id: group.id, offset: group.offset, fields: 'photo_50, city', v: '5.50' }, (r)->
			console.log group.offset
			VK.Api.call 'execute.massfetch', { where: group.id, start: group.offset, fields: 'photo_50', amount: '15000', func_v: 2, v: '5.50' }, (r)->
				console.log r
				if r.error
					fetch group
				else if r.response.items.length == 0
					self.groups[group.index].subs_processed = 100
					self.finished.push group
					if self.finished.length == 2
						merge()
				else
					group.total = r.response.count
					self.members[group.index] = self.members[group.index].concat r.response.items
					self.groups[group.index].subs_processed = Math.round(((group.offset/group.total)*100)*100)/100
					self.update { groups: self.groups }
					group.offset += 15000
					fetch group

		merge = ->
			first = self.members.pop()
			second = self.members.pop()

			if first.length > second.length
				c = first
				first = second
				second = c

			firstids = first.map (item)->
				item.id

			secondids = second.map (item)->
				item.id			

			#inters = secondids.filter (item)->
			#	return firstids.indexOf(item) > -1

			inters = array_intersect(firstids, secondids)

			console.log inters

			self.founditems = first.filter (item)->
				inters.indexOf(item.id) != -1

			console.log self.founditems

			self.foundcount = self.founditems.length
			self.founditems = self.founditems.slice(0, 200)

			self.update { working: null, done: true }

		self.process = (e)->
			self.update { error: null, fetcherror: null, working: true, groups: null, found: null, fetchdone: null, members: [], finished: [], done: null }
			VK.Api.call 'groups.getById', { group_ids: [self.first.value, self.second.value] }, (r)->
				if r.error or not r.response or (r.response.length != 2) or (self.first.value == self.second.value)
					self.update { error: true, working: null }
				else
					console.log r.response
					self.update { found: true, groups: r.response }
					r.response.forEach (item, index, array)->
						self.members[index] = []
						fetch { index: index, id: item.gid, offset: 0 }

	</script>
</app>