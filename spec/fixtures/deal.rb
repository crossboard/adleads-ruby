class Deal
  attr_accessor(
    :merchant_id,
    :dba,
    :deal_type,
    :deal_about,
    :name,
    :display_email,
    :start_date,
    :end_date,
    :facebook_info,
    :from_name,
    :from_email,
    :id,
    :merchant_about,
    :full_landing_page_preview_url,
    :shortened_lp_url,
    :subject_line,
    :status,
    :twitter_info,
    :type,
    :website,
    :distribution_price,
    :distribution_range,
    :location
  )

  def initialize
    @dba = 'Acme, Inc.'
    @merchant_id = '5f7d60e0-b6b8-0131-e62a-38e8562b3602'
    @deal_type = 'voucher'
    @deal_about = "Pickled distillery post-ironic, butcher pork belly Carles meh try-hard PBR Portland VHS plaid Williamsburg banjo."
    @display_email = 'display_email@example.com'
    @start_date = '2014-05-05 12:01:45 -0400'
    @end_date = '2014-05-12 12:02:35 -0400'
    @facebook_info = 'https://www.facebook.com/john'
    @from_name = 'John Doe'
    @from_email = 'john.doe@example.com'
    @id = '8b3c8260-b6b8-0131-e62b-38e8562b3602'
    @merchant_about = "Meggings bitters cornhole small batch farm-to-table, messenger bag pickled scenester you probably haven't heard of them normcore."
    @name = 'Big Deal'
    @shortened_lp_url = 'http://bigdeal.com'
    @full_landing_page_preview_url = 'https://www.d1.savelocal.com/dealslp/offer?oid=0064abed-8414-4343-a8d7-f8e2532ad4e2&soid=1100348700152&ss=1599a108-415f-4b30-a589-3f4596892781&src=email&preview=true'
    @subject_line = "This is the Deal's subject"
    @status = 'running'
    @twitter_info = 'johndoe'
    @type = 'Promotion'
    @website = 'http://bigdeal.com'
    @distribution_price = '25'
    @distribution_range = '5'
    @location = Location.new
  end
end

class Location
  attr_accessor(
    :id,
    :deal_id,
    :address1,
    :address2,
    :city,
    :state,
    :country,
    :zip,
    :phone
  )

  def initialize
    @id = "36a90325-4f67-492a-9929-42dc025c5629"
    @deal_id = "0064abed-8414-4343-a8d7-f8e2532ad4e2"
    @address1 = "1601 Trapelo Rd."
    @address2 = ""
    @city = "Waltham"
    @state = "MA"
    @country = "us"
    @zip = "01803"
    @phone = "8747992938"
  end
end
