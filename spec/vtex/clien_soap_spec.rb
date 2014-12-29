require 'spec_helper'

module VTEX
  describe ClientSoap do
    it "get product by ref id" do
      subject = described_class.new Factories.parameters

      VCR.use_cassette "get_product_by_ref_id" do
        response = subject.get_product_by_ref_id "31068"

        expect(response['id']).not_to be_present
        expect(response[:id]).to be_present
      end
    end

    it "get product by ref id" do
      subject = described_class.new Factories.parameters

      VCR.use_cassette "get_product_by_ref_id_not_there" do
        response = subject.get_product_by_ref_id "000111"

        expect(response['id']).not_to be_present
        expect(response['id']).not_to be_present
      end
    end

    it "get sku by ref id" do
      subject = described_class.new Factories.parameters

      VCR.use_cassette "get_sky_by_ref_id" do
        response = subject.get_sku_by_ref_id "31068"

        expect(response['id']).not_to be_present
        expect(response[:id]).to be_present
      end
    end
  end
end
