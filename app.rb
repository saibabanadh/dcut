require 'rss'
require 'open-uri'
require 'active_support/core_ext'
require 'sinatra'

class DidChromeUpdateToday
  STABLE_UPDATES_CATEGORY_TERM = "Stable updates"
  URL = 'http://feeds.feedburner.com/GoogleChromeReleases?format=xml'
  DEFAULT_TIME_ZONE = "UTC"

  class << self
    def answer(time_zone)
      tz = ActiveSupport::TimeZone[time_zone.presence || DEFAULT_TIME_ZONE]

      $latest_release ||= open(URL) do |rss|
        feed = RSS::Parser.parse(rss)
        feed.entries.detect { |entry| entry.category.term == STABLE_UPDATES_CATEGORY_TERM }
      end

      [
        $latest_release && tz.at($latest_release.published.content.to_i).to_date == tz.today,
        $latest_release && $latest_release.links.detect { |l| l.type == 'text/html' && l.rel == 'alternate' }.href
      ]
    end
  end
end

set :static_cache_control, [:public, max_age: 60 * 60 * 24 * 365]

get '/content' do
  answer = DidChromeUpdateToday.answer(params[:tz])
  @answer_text = answer[0] ? 'Yes' : 'No'
  @answer_url = answer[0] && answer[1]
  erb :content
end

get '/' do
  erb :index
end
