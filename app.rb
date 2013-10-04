require 'rss'
require 'open-uri'
require 'active_support/core_ext/date'
require 'active_support/core_ext/time'
require 'sinatra'

class DidChromeUpdateToday
  STABLE_UPDATES_CATEGORY_TERM = "Stable updates"
  URL = 'http://feeds.feedburner.com/GoogleChromeReleases?format=xml'
  DEFAULT_TIME_ZONE = "America/Los_Angeles"

  class << self
    def answer?(time_zone = DEFAULT_TIME_ZONE)
      Time.zone = time_zone

      $latest_release ||= open(URL) do |rss|
        feed = RSS::Parser.parse(rss)
        feed.entries.detect { |entry| entry.category.term == STABLE_UPDATES_CATEGORY_TERM }
      end

      $latest_release && $latest_release.published.content.today?
    end
  end
end

get '/' do
  @answer_text = DidChromeUpdateToday.answer? ? "Yes" : "No"
  erb :index
end
