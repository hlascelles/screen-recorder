require_relative '../spec_helper'

#
# Windows Only
#
if OS.windows? # Only gdigrab supports window capture
  RSpec.describe FFMPEG::WindowTitles do
    describe '.fetch' do
      context 'given application is Firefox' do
        let(:browser_process) { :firefox }
        let(:url) { 'https://google.com' }
        let(:expected_title) { 'Google - Mozilla Firefox' }
        let(:browser) do
          Webdrivers.install_dir = 'webdrivers_bin'
          Watir::Browser.new browser_process
        end

        it 'returns window title from Mozilla Firefox' do
          # Note: browser is lazily loaded with let
          browser.goto url
          browser.wait
          expect(FFMPEG::WindowTitles.fetch(browser_process).first).to eql(expected_title)
          browser.quit
        end
      end

      context 'given application is Chrome with extensions as individual processes' do
        let(:browser_process) { :chrome }
        let(:url) { 'https://google.com' }
        let(:expected_titles) { ['Google - Google Chrome'] }
        let(:browser) do
          Webdrivers.install_dir = 'webdrivers_bin'
          Watir::Browser.new browser_process
        end

        it 'excludes titles from extensions' do
          # Note: browser is lazily loaded with let
          browser.goto url
          browser.wait
          expect(FFMPEG::WindowTitles.fetch(browser_process)).to eql(expected_titles)
          browser.quit
        end
      end
    end # describe
  end # Os.windows?
end