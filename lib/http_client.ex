defmodule HttpClient do
  use HTTPoison.Base

  @headers [{"Content-Type","text/plain"}]

  def process_request_headers(_headers), do: @headers

end
