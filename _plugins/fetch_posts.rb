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

  MAX_POSTS = 200
  SOURCE_URL = "https://beatrootnews.com/api.php/article?page%5Blimit%5D=#{MAX_POSTS}&sort=-publishing_date"

  # Make a request to SOURCE_URL, and return the parsed JSON
  def get_content
    uri = URI.parse(SOURCE_URL)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)['data']
  end

  # Main plugin action, called by Jekyll-core
  def generate(site)
    @site = site
    site.data['topics'] = Set.new site.data['topics']
    count = 0
    get_content.each do |article|
      page = make_page(article['attributes']['modules'])
      if page
        site.pages << page 
        page['topics'].each do |topic|
          unless site.data['topics'].include? topic
            site.data['topics'] << topic
            Jekyll.logger.warn "News:", "New Topic #{topic}"
          end
        end
        count+=1
      end
    end

    site.data['topics'].each do |topic|
      @site.pages << make_topic_page(topic)
    end

    site.data['topics'] = site.data['topics'].to_a.sort
    Jekyll.logger.info "News:", "Generated #{count} pages"
  end

  private

  def make_topic_page(topic)
    PageWithoutAFile.new(@site, __dir__, topic, "index.html").tap do |file|
      file.data.merge!(
        'title'    => topic.capitalize,
        'layout'   => 'topic',
        'topic'    => topic,
        'permalink' => "/#{topic}/"
      )
      file.output
    end
  end

  # Generates contents for a file

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
    n = DateTime.new
    now = DateTime.new(n.year, n.month, n.day, 23, 59, 59, "+0530")
    date = timestamp(article['updated_on'])
    days_ago = (now - date).floor
    return nil if days_ago > 2

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
        'sources'  => article['sources'],
        "date"     => date,
        "id"       => article['id'],
        "slug"     => article['slug'],
        "title"    => article['title'],
        "layout"   => 'article',
        "topics"   => topics,
        "days_ago" => days_ago,
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