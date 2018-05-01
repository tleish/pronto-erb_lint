require 'spec_helper'

module Pronto
  describe ERBLint do
    let(:erb_lint) { ERBLint.new(patches) }
    let(:patches) { nil }

    describe '#run' do
      subject { erb_lint.run }

      context 'patches are nil' do
        it { should == [] }
      end

      context 'no patches' do
        let(:patches) { [] }
        it { should == [] }
      end
    end

    describe '#level' do
      subject { erb_lint.level(severity) }

      ::RuboCop::Cop::Severity::NAMES.each do |severity|
        let(:severity) { severity }
        context "severity '#{severity}' conversion to Pronto level" do
          it { should_not be_nil }
        end
      end
    end
  end
end
