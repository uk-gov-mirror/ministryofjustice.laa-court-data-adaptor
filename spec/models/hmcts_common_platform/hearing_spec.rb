RSpec.describe HmctsCommonPlatform::Hearing, type: :model do
  let(:data) { JSON.parse(file_fixture("hearing/all_fields.json").read).deep_symbolize_keys }
  let(:hearing) { described_class.new(data[:hearing]) }

  it "has a jurisdiction type" do
    expect(hearing.jurisdiction_type).to eql("CROWN")
  end

  it "has a court centre ID" do
    expect(hearing.court_centre_id).to eql("bc4864ca-4b22-3449-9716-a8db1db89905")
  end

  it "has a first sitting day date" do
    expect(hearing.first_sitting_day_date).to eql("2019-10-25T10:45:00.000Z")
  end
end
