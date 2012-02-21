# Handles client calls
class Client < Controller
	# new or existing tinker
	get %r{^/(?:([A-Za-z0-9]{5})(?:/([0-9]+))?/?)?$} do |hash, revision|
		locals = {
			:tinker => Tinker.find(hash, revision),
			:doctypes => Doctype.list,
			:frameworks => Framework.list,
			:urls => APP_CONFIG['urls']
		}
		haml :index, :locals => locals
	end

	# save new or existing tinker
	post '/save' do
		tinker = Tinker.find(params[:hash])

		tinker['title'] = params[:title]
		tinker['description'] = params[:description]
		tinker['doctype'] = params[:doctype]
		tinker['framework'] = params[:framework]
		tinker['extensions'] = params[:extensions] || []
		tinker['normalize'] = params[:normalize] ? 1 : 0
		tinker['assets'] = params[:assets] || []
		tinker['markup'] = params[:markup]
		tinker['style'] = params[:style]
		tinker['interaction'] = params[:interaction]

		if tinker.save && !tinker['hash'].nil? && !tinker['revision'].nil?
			{
				:status => 'ok',
				:hash => tinker['hash'],
				:revision => tinker['revision']
			}.to_json
		else
			{
				:status => 'error',
				:error => {
					:code => 100,
					:message => 'Something went wrong while trying to save'
				}
			}.to_json
		end
	end

	get %r{^/([A-Za-z0-9]{5})(?:/([0-9]+))?/embed/?$} do |hash, revision|
		locals = {
			:tinker => Tinker.find(hash, revision),
			:urls => APP_CONFIG['urls']
		}

		headers 'X-Frame-Options' => ''
		body haml :embed, :locals => locals
	end

	get '/css/base.css' do
		sass :base
	end

	get '/css/embed.css' do
		sass :embed
	end
end
