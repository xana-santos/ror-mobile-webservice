class UrlShortener
  def shorten(url)
    shortened = Bitly.client.shorten(url)

    shortened.short_url
  end
end