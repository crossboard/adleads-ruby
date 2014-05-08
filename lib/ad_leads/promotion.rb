module  AdLeads
  class Promotion
    def self.promotion_params(deal)
      {
        account: {
          external_id: deal.merchant_id,
          dba: deal.dba,
          name: deal.from_name,
          email: deal.from_email,
          description: deal.merchant_about,
          website: deal.website,
          address1: deal.location.address1,
          address2: deal.location.address2,
          city: deal.location.city,
          state: deal.location.state,
          zip: deal.location.zip,
          phone: deal.location.phone,
          country: deal.location.country,
          facebook: deal.facebook_info,
          twitter: deal.twitter_info
        },
        promotion: {
          external_id: deal.id,
          name: deal.name,
          headline: deal.subject_line,
          landing_page: deal.full_landing_page_preview_url,
          landing_page_shortened: deal.shortened_lp_url,
          spend: deal.distribution_price,
          range: deal.distribution_range,
          description: deal.deal_about,
          kind: deal.deal_type,
          state: deal.status,
          time_start: deal.start_date,
          time_end: deal.end_date,
        }
      }
    end
  end
end
