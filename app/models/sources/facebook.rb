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

require 'doi'

class Facebook < Source

  validates_each :api_key do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires api key") \
      if config.api_key.blank?

    events = []
    urls = []

    fbAPI = Koala::Facebook::API.new(config.api_key)

    doi_resolver_url = DOI.to_url(article.doi)
    urls = [doi_resolver_url]

    original_url = nil
    if options[:retrieval_status].local_id.nil?
      begin
        original_url = get_original_url(doi_resolver_url)
      rescue => e
        Rails.logger.error "Could not get the full url for #{doi_resolver_url} #{e.message}"
      end
      unless original_url.nil?
        urls << original_url
      end
    else
      urls << options[:retrieval_status].local_id
    end

    # if the article is one of plos articles, add plos specific doi resolver url
    rx = Regexp.new('10\.1371\/')
    unless rx.match(article.doi).nil?
      #Get the plos doi resolver
      urls << "http://dx.plos.org/#{article.doi}"
    end

    urls.each { |url| execute_search(fbAPI, events, "#{url}") }

    total = 0
    events.each do | event |
      total += event["total_count"]
    end

    data = {:events => events, :event_count => total}

    unless original_url.nil?
      data[:local_id] = original_url
    end

    return data
  end

  def execute_search(fbAPI, events, search_term)
    query = "select url, normalized_url, share_count, like_count, comment_count, total_count, click_count, "\
      "comments_fbid, commentsbox_count from link_stat where url = '#{search_term}'"

    Rails.logger.debug "facebook query #{query}"

    results = fbAPI.fql_query(query)

    if results && results.size > 0
      results.each {|result| events << result}
    end
  end

  def get_config_fields
    [{:field_name => "api_key", :field_type => "text_field"}]
  end

  def api_key
    config.api_key
  end

  def api_key=(value)
    config.api_key = value
  end
end