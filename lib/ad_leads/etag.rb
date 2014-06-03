module AdLeads::Etag
  def etag_path
    # must be implemented in including class
  end

  def refresh_etag!
    @etag = client.get(etag_path)
  end

  def etag
    @etag ||= refresh_etag!
  end

  def with_etag(&block)
    response = yield

    retry_count = 0

    while response.status == 412 && retry_count <= 1
      retry_count += 1
      self.refresh_etag!
      response = yield
    end
  end
end
