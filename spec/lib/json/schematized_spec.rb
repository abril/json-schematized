# encoding: UTF-8
require "spec_helper"

describe SamplePerson do
  context "mass assignment" do
    let(:initial_attributes){ {:_id => "123", :age => 45} }
    subject { described_class.new initial_attributes }

    its(:_id){ should be initial_attributes[:_id] }
    its(:age){ should be 45 }
    context "attributes missed" do
      its(:name){ should be_nil }
      its(:phones){ should be_kind_of(Array) }
      its(:children){ should be_kind_of(Array) }
      its(:birth){ should be_kind_of(Hash) }
      its(:death){ should be_kind_of(Hash) }
      it "should assign non-required hashes at first call only" do
        subject.__json__.should_not be_has_key("death")
        subject.__json__["death"].should be_nil
        subject.death.should be_kind_of(Hash)
        subject.__json__["death"].should == {}
      end
      it "should assign non-required arrays at first call only" do
        subject.__json__.should_not be_has_key("phones")
        subject.__json__["phones"].should be_nil
        subject.phones.should be_kind_of(Array)
        subject.__json__["phones"].should == []
      end
    end
    context "required attributes" do
      it "should always assign required hashes" do
        subject.__json__.should be_has_key("birth")
        subject.__json__["birth"].should be_kind_of(Hash)
        subject.__json__["birth"].should be_has_key("location")
        subject.__json__["birth"]["location"].should be_kind_of(Hash)
      end
      it "should always assign required arrays" do
        subject.__json__.should be_has_key("children")
        subject.__json__["children"].should be_kind_of(Array)
        subject.__json__["birth"].should be_has_key("tags")
        subject.__json__["birth"]["tags"].should be_kind_of(Array)
      end
    end
  end
end
