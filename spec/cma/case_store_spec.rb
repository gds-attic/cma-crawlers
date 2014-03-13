require 'spec_helper'
require 'cma/oft/mergers/case'
require 'cma/oft/competition/case'
require 'cma/oft/consumer/case'
require 'cma/case_store'
require 'cma/asset'
require 'fileutils'

module CMA
  describe CaseStore do
    describe '.save' do
      let(:expected_filename) { 'spec/fixtures/store/OFTwork-mergers-Mergers_Cases-2013-DiageoUnitedSpirits.json' }
      let(:_case) do
        OFT::Mergers::Case.new.tap do |c|
          c.title = 'test_title'
          c.sector = 'test_sector'
          c.original_url = 'http://oft.gov.uk/OFTwork/mergers/Mergers_Cases/2013/DiageoUnitedSpirits'

          c.assets << CMA::Asset.new('http://1', c, '1234', 'text/plain')
        end
      end

      before do
        FileUtils.rmtree 'spec/fixtures/store'
        CaseStore.instance.save(_case)
      end

      it 'saves the case' do
        expect(File).to exist(expected_filename)
      end

      describe 'what to load via .load_class' do
        it 'loads a Mergers case for a merger URL' do
          CaseStore.instance.load_class('Somestore/OFTwork-mergers-Mergers_Cases-2013-Alliance.json').
            should == CMA::OFT::Mergers::Case
        end
        it 'loads a Competition case for a competition URL' do
          CaseStore.instance.load_class('somestore/OFTwork-oft-current-cases-competition-case-list-2005-interchage-fees-mastercard.json').
            should == CMA::OFT::Competition::Case
        end
        it 'loads a Consumer case for a consumer URL' do
          CaseStore.instance.load_class('somestore/OFTwork-oft-current-cases-consumer-case-list-2012-furniture-carpets.json').
            should == CMA::OFT::Consumer::Case
        end
        it 'loads a Markets case for a markets URL' do
          CaseStore.instance.load_class('somestore/OFTwork-oft-current-cases-markets-work2013/higher-education-cfi.json').
            should == CMA::OFT::Markets::Case
        end
        it 'loads a Markets case for a markets URL' do
          CaseStore.instance.load_class('_output/OFTwork-oft-current-cases-market-studies-2012-personal-current-accounts.json').
            should == CMA::OFT::Markets::Case
        end
      end

      describe 'loading the case' do
        subject { CaseStore.instance.load(expected_filename) }

        it                 { should be_an(OFT::Mergers::Case) }
        its(:title)        { should eql('test_title') }
        its(:sector)       { should eql('test_sector') }
        its(:original_url) { should eql('http://oft.gov.uk/OFTwork/mergers/Mergers_Cases/2013/DiageoUnitedSpirits') }
      end

      describe 'finding the case by URL' do
        subject { CaseStore.instance.find('http://oft.gov.uk/OFTwork/mergers/Mergers_Cases/2013/DiageoUnitedSpirits') }

        it { should be_an(OFT::Mergers::Case) }
      end

      describe 'cleaning the store' do
        before { CaseStore.instance.clean! }

        it 'has obliterated everything' do
          Dir["#{CaseStore.instance.location}/*"].should have(0).entries
        end
      end
    end
  end
end
