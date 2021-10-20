require 'rss'
require 'rss/2.0'
require 'open-uri'
require 'fileutils'
require 'safe_yaml'
require 'httparty'
require 'feedjira'
require 'jekyll-sitemap'

# url = 'https://s8hdp1sdz5.execute-api.eu-west-2.amazonaws.com/latest/proxy/'
url = 'https://feeds.acast.com/public/shows/6012fcea40e3fd5f183effd9'
xml = HTTParty.get(url).body
feed = Feedjira.parse(xml)

feed.entries.each do |item|
    formatted_date = item.published.strftime('%Y-%m-%d')
    post_name = item.title.split(%r{ |!|/|:|&|-|$|,}).map do |i|
        i.downcase if i != ''
    end.compact.join('-')
    name = "#{formatted_date}-#{post_name}"
    
    header = {
        'layout' => 'post',
        'title' => item.title,
        'subtitle'=> item.itunes_subtitle,
        'description' => item.summary,
        'image' => item.itunes_image,
        'pubdate' => formatted_date,
        'item' => item,
        'media' => item.enclosure_url,
        'duration'=> item.itunes_duration

        }

    FileUtils.mkdir_p("_posts")
    File.open("_posts/#{name}.html", "w") do |f|
        f.puts header.to_yaml
        f.puts "---\n\n"
    end
end