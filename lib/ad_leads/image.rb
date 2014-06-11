module AdLeads
  class Client
    module Image
      def create_image(creative_group_id, ad_id, options)
        post image_root_path(creative_group_id, ad_id), options
      end

      def upload_image(creative_group_id, ad_id, image_id, file)
        remaining_tries ||= 3
        post image_upload_path(creative_group_id, ad_id, image_id), image_upload_opts(creative_group_id, ad_id, image_id, file)
      rescue AdLeads::EtagMismatchError
        remaining_tries -= 1
        retry unless remaining_tries.zero?
      end

      private

      def image_root_path(creative_group_id, ad_id)
        "/creativegroups/#{creative_group_id}/creatives/#{ad_id}/images"
      end

      def image_upload_path(creative_group_id, ad_id, image_id)
        "/creativegroups/#{creative_group_id}/creatives/#{ad_id}/images/#{image_id}/file"
      end

      def image_upload_opts(creative_group_id, ad_id, image_id, file)
        {
          file: Faraday::UploadIO.new(file, 'image/jpeg'),
          etag: image_etag(creative_group_id, ad_id, image_id).headers['Etag']
        }
      end

      def image_etag(creative_group_id, ad_id, image_id)
        get "/creativegroups/#{creative_group_id}/creatives/#{ad_id}/images/#{image_id}"
      end
    end
  end
end
