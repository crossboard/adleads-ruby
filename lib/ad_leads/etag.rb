module AdLeads::Etag
  def etag_path
    # must be implemented in including class
  end

  def refresh_etag!
    @etag = client.get(etag_path).headers['Etag']
  end

  def etag
    @etag ||= refresh_etag!
  end

  def with_etag(count = 1, &block)
    raise MismatchError if count > 3

    response = yield
    count += 1

    if response.status == 412
      self.refresh_etag!
      with_etag(count) do
        yield
      end
    end

  end

  class MismatchError < StandardError; end
end
