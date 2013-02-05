# encoding: UTF-8
require "spec_helper"

describe JSON::Schematized::Version do
  after { File.delete(described_class.version_file) rescue nil }

  let(:fake_version){ JSON::Schematized::VERSION }
  let(:stepup_version){ "v#{fake_version}+1" }
  let(:gem_root){ described_class.gem_root }

  context "#version_from_file" do
    before { File.open(described_class.version_file, "w"){ |f| f.write stepup_version } }
    subject { described_class.new.version_from_file }
    it { should == stepup_version }
  end

  context "#version_from_gempath" do
    before do
      described_class.any_instance.
        should_receive(:gem_root).
        and_return("./json-schematized-#{fake_version}")
    end
    subject { described_class.new.version_from_gempath }
    it { should == fake_version }
  end

  context "#version_from_stepup" do
    before do
      StepUp::Driver::Git.any_instance.
        should_receive(:last_version_tag).
        with("HEAD", true).
        and_return(stepup_version)
    end
    subject { described_class.new.version_from_stepup }
    it { should == stepup_version }
  end
end
