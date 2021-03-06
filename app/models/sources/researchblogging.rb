# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Researchblogging < Source

  validates_each :url, :username, :password do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires username & password") \
      if config.username.blank? or config.password.blank?

    query_url = get_query_url(article)

    get_xml(query_url, options.merge(:username => config.username, :password => config.password)) do |document|
      events = []

      total_count = document.root.attributes.get_attribute("total_records_found")

      document.find("//blogposts/post").each do |post|

        post_string = post.to_s(:encoding => XML::Encoding::UTF_8)
        event = Hash.from_xml(post_string)
        event = event['post']

        events << {:event => event, :event_url => event['post_URL']}
      end

      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => events,
       :events_url => "http://researchblogging.org/post-search/list?article=#{CGI.escape(article.doi)}",
       :event_count => total_count.value.to_i,
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }

    end

  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "username", :field_type => "text_field"},
     {:field_name => "password", :field_type => "password_field"}]
  end

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end

  def username
    config.username
  end
  def username=(value)
    config.username = value
  end

  def password
    config.password
  end
  def password=(value)
    config.password = value
  end
end