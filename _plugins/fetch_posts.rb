# frozen_string_literal: true
require 'sanitize'
require 'uri'
require 'net/http'
require 'set'
require 'date'

SANITIZE_CONFIG = {
  :elements => ['a', 'span', 'p', 'i', 'br'],

  :attributes => {
    'a'    => ['href', 'title']
  },

  :protocols => {
    'a' => {'href' => ['http', 'https']}
  }
}

class PageWithoutAFile < Jekyll::Page
  def read_yaml(*)
    @data ||= {}
  end
end

class BeatrootNews < Jekyll::Generator
  safe true
  priority :highest

  MAX_POSTS = 150
  SOURCE_URL = "https://beatrootnews.com/api.php/article?page%5Blimit%5D=#{MAX_POSTS}&sort=-publishing_date"

  def fix_dates_for_dev(data)
    # Calculate number of days since 2023-11-30, the date of our fixture
    days_since = (DateTime.now - DateTime.new(2023, 11, 30)).floor
    seconds_to_add = days_since * 86400
    data.each do |article|
      article['attributes']['modules']['updated_on'] = article['attributes']['modules']['updated_on'].to_i + seconds_to_add
    end

    data
  end

  def make_request(url, retries=5)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10
    http.open_timeout = 10
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if response.code == "200"
      return response.body
    elsif retries > 0
      Jekyll.logger.warn "News:", "Retrying #{url} (#{retries} retries left)"
      return make_request(url, retries - 1)
    else
      Jekyll.logger.error "News:", "Failed to fetch #{url}"
      raise "Failed to fetch news after 5 attempts"
    end
  end

  def get_content
    unless Jekyll.env == 'production'
      body = File.read '_development/fixture.json'
    else
      body = make_request(SOURCE_URL, 5)
    end
    data = JSON.parse(body)['data']
    data = fix_dates_for_dev(data) unless Jekyll.env == 'production'
    data
  end

  # Main plugin action, called by Jekyll-core
  def generate(site)
    @site = site
    # Topic Counter
    site.data['topics'] = site.data['topics'].to_h {|topic| [topic, 0]}
    get_content.each do |article|
      page = make_page(article['attributes']['modules'])
      if page
        site.pages << page 
        page['topics'].each do |topic|
          unless site.data['topics'].include? topic
            site.data['topics'][topic] = 0
            Jekyll.logger.warn "News:", "New Topic #{topic}"
          end
        end
        site.data['topics'][page['topics'].first] += 1
      end
    end

    site.data['topics'].each do |topic, count|
      @site.pages << make_topic_page(topic, count)
    end

    Jekyll.logger.info "News:", "Generated #{site.data['topics'].values.sum} article pages"
    # These are fallback checks to make sure if we have a bug or get bad data,
    # we don't update the website with not enough news
    # better to fail the build than show an empty website.
    raise "Not enough articles, not updating website" if site.data['topics'].values.sum < 10
    raise "Not enough topics, not updating website" if site.data['topics'].size < 5
  end

  private

  def make_topic_page(topic, count)
    PageWithoutAFile.new(@site, __dir__, topic, "index.html").tap do |file|
      file.data.merge!(
        'title'    => topic.capitalize,
        'layout'   => 'topic',
        'topic'    => topic,
        'permalink' => "/#{topic}/",
        'article_count'    => count
      )
      file.output
    end
  end

  def timestamp(ts)
    d = Time.at(ts.to_i).to_datetime
    d.new_offset("+0530")
  end

  def syndicated?(article)
    sources = article['sources'].map(&:downcase)
    return !(sources & @site.config['syndication_sources']).empty?
  end

  def make_page(article)
    return nil if article['topic'].nil?
    return nil if article['body_json']['blocks'].empty?
    n = DateTime.now
    now = DateTime.new(n.year, n.month, n.day, 23, 59, 59, "+0530")
    date = timestamp(article['updated_on'])
    days_ago = (now - date).floor
    # We only return news for today(0) or yesterday(1)
    return nil if days_ago > 1

    PageWithoutAFile.new(@site, __dir__, article['id'], "index.html").tap do |file|
      html = article['body_json']['blocks'].map{ |t| t['data']['text']}.join(" ")
      html = Sanitize.fragment(html, SANITIZE_CONFIG)
      topics = article['topic'].map { |topic| topic.split('-').first }
      twt = nil

      if article['trigger_warning']
        twt = article['trigger_warning_text'] || 'Trigger Warning'
        unless twt.downcase.include? 'trigger'
          twt = 'Trigger Warning: ' + twt
        end
        html = "<b>#{twt}</b><br>" + html
      end

      file.content = html
      
      file.data.merge!(
        'sources'  => article['sources'].reject(&:empty?),
        "date"     => date,
        "id"       => article['id'],
        "slug"     => article['slug'],
        "title"    => article['title'],
        "layout"   => 'article',
        "topics"   => topics,
        "days_ago" => days_ago,
        "day" => days_ago == 0 ? "today" : "yesterday",
        # We use 300 characters here
        # and the SEO plugin strips down to 200 with ellepsis
        "description" => Sanitize.fragment(html)[0...199] + "…",
        "trigger_warning" => twt,
        "syndicated" => syndicated?(article),
        "seo" => {
          "type" => "NewsArticle",
          "links" => [
            "https://app.beatrootnews.com/#article-#{article['id']}",
            "https://beatrootnews.com/custom/share?type=article&slug=#{article['slug']}"
          ],
          "date_modified"     => date
        },
        "media_link" => article['media_link'] ? article['media_link'] : nil,
        # This is currently disabled because the page doesn't load in desktop
        # Or rather doesn't load at all for old links.
        # "canonical_url" => "https://app.beatrootnews.com/#article-#{article['id']}"
      )
      file.output
    end
  end

end