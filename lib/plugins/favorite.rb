# -*- coding: utf-8 -*-

module Termtter::Client
  add_help 'favorite,fav ID', 'Favorite a status'

  add_command %r'^(?:favorite|fav)\s+(\d+)\s*$' do |m, t|
    id = m[1]
    res = t.favorite(id)
    if res.code == '200'
      puts "Favorited status ##{id}"
    else
      puts "Failed: #{res}"
    end
  end

  add_help 'favorite,fav USER', 'Favorite last status on the user'

  add_command %r'^(?:favorite|fav)\s+@(.+)\s*$' do |m, t|
    user = m[1].strip
    statuses = t.user_timeline(user)
    unless statuses.empty?
      id = statuses[0].id
      text = statuses[0].text
      res = t.favorite(id)
      if res.code == '200'
        puts %Q(Favorited last status ##{id} on user @#{user}: "#{text}")
      else
        puts "Failed: #{res}"
      end
    end
  end

  if public_storage[:log]
    add_help 'favorite,fav /WORD', 'Favorite a status by searching'

    add_command %r'^(?:favorite|fav)\s+/(.+)$' do |m, t|
      pat = Regexp.new(m[1])
      statuses = public_storage[:log].select {|s| pat =~ s.text }
      if statuses.size == 1
        status = statuses.first
        res = t.favorite(status.id)
        if res.code == '200'
          puts %Q(Favorited "#{status.user.screen_name}: #{status.text}")
        else
          puts "Failed: #{res}"
        end
      else
        puts "#{pat} does not match single status"
      end
    end
  end

  add_completion do |input|
    case input
    when /^(favorite|fav)\s+@(.*)/
      find_user_candidates $2, "#{$1} @%s"
    when /^(favorite|fav)\s+(\d*)/
      find_status_id_candidates $2, "#{$1} %s"
    else
      %w(favorite).grep(/^#{Regexp.quote input}/)
    end
  end
end

module Termtter
  class Twitter
    def favorite(id)
      uri = "#{@connection.protocol}://twitter.com/favourings/create/#{id}.json"

      @connection.start('twitter.com', @connection.port) do |http|
        http.request(post_request(uri))
      end
    end
  end
end