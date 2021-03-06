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

class ArticlesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :index, :show ]

  respond_to :html, :xml, :json

  # GET /articles
  def index
    # cited=0|1
    # query=(doi fragment)
    # order=doi|published_on (whitelist, default to doi)
    # source=source_type

    collection = Article
    collection = collection.cited(params[:cited])  if params[:cited]
    collection = collection.query(params[:query])  if params[:query]
    collection = collection.order_articles(params[:order])

    @articles = collection.paginate(:page => params[:page], :per_page => params[:per_page])

    # if private sources have been filtered out, the source parameter will be present and modified

    # source url parameter is only used for csv format
    @source = Source.find_by_name(params[:source].downcase) if params[:source]

    if params[:source]
      @sources = Source.where("lower(name) in (?)", params[:source].split(",")).order("display_name")
    else
      @sources = Source.order("display_name")
    end

    respond_with(@articles) do |format|
      format.json { render :json => @articles, :callback => params[:callback] }
      format.csv  { render :csv => @articles }
    end
  end

  # GET /articles/:id
  def show

    load_article

    format_options = params.slice :events, :history, :source

    # if private sources have been filtered out, the source parameter will be present and modified
    # private sources are filtered out in the load_article_eager_includes method by looking at source parameter
    load_article_eager_includes

    respond_with(@article) do |format|
      format.csv  { render :csv => @article }
      format.json { render :json => @article.as_json(format_options), :callback => params[:callback] }
      format.xml  do
        response.headers['Content-Disposition'] = 'attachment; filename=' + params[:id].sub(/^info:/,'') + '.xml'
        render :xml => @article.to_xml(:events => format_options[:events],
                                       :history => format_options[:history],
                                       :source => format_options[:source])
      end
    end
  end

  # GET /articles/new
  def new
    @article = Article.new

    respond_with @article
  end

  # POST /articles
  def create
    @article = Article.new(params[:article])

    if @article.save
      flash[:notice] = 'Article was successfully created.'
    end
    respond_with(@article)
  end

  # GET /articles/:id/edit
  def edit
    load_article
  end

  # PUT /articles/:id(.:format)
  def update
    load_article
    if @article.update_attributes(params[:article])
      flash[:notice] = 'Article was successfully updated.'
    end
    respond_with(@article)
  end

  # DELETE /articles/:id(.:format)
  def destroy
    load_article
    @article.destroy
    flash[:notice] = 'Article was successfully deleted.'
    respond_with(@article)
  end

  protected
  def load_article()
    # Load one article given query params
    doi = DOI::from_uri(params[:id])
    @article = Article.find_by_doi!(doi)
  end

  def load_article_eager_includes
    doi = DOI::from_uri(params[:id])
    if params[:source]
      @article = Article.where("doi = ? and lower(sources.name) in (?)", doi, params[:source].downcase.split(",")).
          includes(:retrieval_statuses => :source).first
    else
      @article = Article.where("doi = ?", doi).includes(:retrieval_statuses => :source).first
    end

    raise ActiveRecord::RecordNotFound, "Couldn't find Article with doi = #{doi}" if @article.nil?
  end

end
