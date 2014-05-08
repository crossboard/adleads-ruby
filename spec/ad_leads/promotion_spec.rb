require 'spec_helper'
require './spec/fixtures/deal.rb'

describe AdLeads::Promotion do
  let(:deal) { Deal.new }
  let(:params) { AdLeads::Promotion.promotion_params(deal) }
  let(:account_params) { params[:account] }
  let(:promotion_params) { params[:promotion] }

  context '#promotion_params' do
    context ':account' do
      it 'sets :external_id' do
        expect(account_params[:external_id]).to eq deal.merchant_id
      end

      it 'sets :dba' do
        expect(account_params[:dba]).to eq deal.dba
      end

      it 'sets :name' do
        expect(account_params[:name]).to eq deal.from_name
      end

      it 'sets :email' do
        expect(account_params[:email]).to eq deal.from_email
      end

      it 'sets :description' do
        expect(account_params[:description]).to eq deal.merchant_about
      end

      it 'sets :website' do
        expect(account_params[:website]).to eq deal.website
      end

      it 'sets :address1' do
        expect(account_params[:address1]).to eq deal.location.address1
      end

      it 'sets :address2' do
        expect(account_params[:address2]).to eq deal.location.address2
      end

      it 'sets :city' do
        expect(account_params[:city]).to eq deal.location.city
      end

      it 'sets :state' do
        expect(account_params[:state]).to eq deal.location.state
      end

      it 'sets :zip' do
        expect(account_params[:zip]).to eq deal.location.zip
      end

      it 'sets :phone' do
        expect(account_params[:phone]).to eq deal.location.phone
      end

      it 'sets :country' do
        expect(account_params[:country]).to eq deal.location.country
      end

      it 'sets :facebook' do
        expect(account_params[:facebook]).to eq deal.facebook_info
      end

      it 'sets :twitter' do
        expect(account_params[:twitter]).to eq deal.twitter_info
      end
    end
    context ':promotion' do
      it 'sets :external_id' do
        expect(promotion_params[:external_id]).to eq deal.id
      end

      it 'sets :name' do
        expect(promotion_params[:name]).to eq deal.name
      end

      it 'sets :headline' do
        expect(promotion_params[:headline]).to eq deal.subject_line
      end

      it 'sets :landing_page' do
        expect(promotion_params[:landing_page]).to eq deal.full_landing_page_preview_url
      end

      it 'sets :landing_page_shortened' do
        expect(promotion_params[:landing_page_shortened]).to eq deal.shortened_lp_url
      end

      it 'sets :spend' do
        expect(promotion_params[:spend]).to eq deal.distribution_price
      end

      it 'sets :targeting' do
        expect(promotion_params[:range]).to eq deal.distribution_range
      end

      it 'sets :description' do
        expect(promotion_params[:description]).to eq deal.deal_about
      end

      it 'sets :kind' do
        expect(promotion_params[:kind]).to eq deal.deal_type
      end

      it 'sets :state' do
        expect(promotion_params[:state]).to eq deal.status
      end

      it 'sets :time_start' do
        expect(promotion_params[:time_start]).to eq deal.start_date
      end

      it 'sets :time_end' do
        expect(promotion_params[:time_end]).to eq deal.end_date
      end

    end
  end
end
