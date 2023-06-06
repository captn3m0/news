# frozen_string_literal: true
require 'sanitize'
require 'uri'
require 'net/http'
require 'set'
require 'date'

class PageWithoutAFile < Jekyll::Page
  def read_yaml(*)
    @data ||= {}
  end
end

class BeatrootNews < Jekyll::Generator
  safe true
  priority :high

  SOURCE_URL = "https://beatrootnews.com/api.php/article?page%5Blimit%5D=60&sort=-publishing_date"

  # Make a request to SOURCE_URL, and return the parsed JSON
  def get_content
    uri = URI.parse(SOURCE_URL)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)['data']
  end

  # Main plugin action, called by Jekyll-core
  def generate(site)
    @site = site
    topics = Set.new
    get_content.each do |article|
      page = make_page(article['attributes']['modules'])
      if page
        site.pages << page 
        page['topics'].each { |t| topics.add(t) }
      end
    end

    topics.each do |topic|
      @site.pages << make_topic_page(topic)
    end
    site.config['topics'] = topics.to_a.sort
  end

  private

  def make_topic_page(topic)
    PageWithoutAFile.new(@site, __dir__, topic, "index.html").tap do |file|
      file.data.merge!(
        'title'    => topic.capitalize,
        'layout'   => 'topic',
        'topic'    => topic,
        'permalink' => "/#{topic}/",
      )
      file.output
    end
  end

  # Generates contents for a file

  def timestamp(ts)
    d = Time.at(ts.to_i).to_datetime
    d.new_offset("+0530")
  end

  def make_page(article)
    return nil if article['topic'].nil?
    n = DateTime.new
    now = DateTime.new(n.year, n.month, n.day, 23, 59, 59, "+0530")
    PageWithoutAFile.new(@site, __dir__, article['id'], "index.html").tap do |file|
      html = article['body_json']['blocks'].map{ |t| t['data']['text']}.join(" ")
      topics = article['topic'].map { |topic| topic.split('-').first }
      if article['trigger_warning']
        html = "<p><b>#{article['trigger_warning_text']}</b></p>" + html
      end

      file.content = Sanitize.fragment(html, Sanitize::Config::RELAXED)
      
      date = timestamp(article['updated_on'])
      file.data.merge!(
        'sources'  => article['sources'],
        "date"     => date,
        "title"    => article['title'],
        "layout"   => 'article',
        "topics"   => topics,
        "days_ago" => (now - date).floor
      )
      file.output
    end
  end

end