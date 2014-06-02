module AdLeads::Etag
  def etag_path
    # must be implemented in including class
  end

  def etag
    request(:get, etag_path)
  end
end
