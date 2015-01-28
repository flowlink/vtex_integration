require 'spec_helper'

module VTEX
  describe ClientPubApi do
    it "get product by ref id" do
      subject = described_class.new Factories.parameters

      VCR.use_cassette "get_product_by_id" do
        response = subject.get_product_by_id "31068"

        expect(response['id']).not_to be_present
        expect(response['productName']).to be_present
        expect(response['items']).to be_present
        expect(response['categories']).to be_present
        expect(response['allSpecifications']).to be_present
        expect(response['sellers']).to be_present
      end
    end

    it "get product by ref id" do
      subject = described_class.new Factories.parameters

      VCR.use_cassette "get_product_by_id_not_there" do
        response = subject.get_product_by_id "000111"
        expect(response).to be_nil
      end
    end
  end
end
