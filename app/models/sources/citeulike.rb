class Citeulike < Source
  include SourceHelper

  def query(article)

    url = "http://www.citeulike.org/api/posts/for/doi/#{CGI.escape(article.doi)}"
    get_xml(url) do |document|
      citations = []
      document.find("//posts/post/link").each do |cite|
        cite.gettAttrValue("link",linkURL)
        citation = {}
        citation[:uri] = linkURL
        citations << citation
      end
      citations
    end
  end
end
