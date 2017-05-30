require_relative '../spec_helper'

RSpec.describe Parliament::Search, vcr: true do

  it 'should be a module' do
    expect(Parliament::Search).to be_a(Module)
  end

  it 'should autoload VERSION' do
    expect(Parliament::Search::VERSION).not_to be(nil)
  end

  it 'should autoload Application' do
    expect(Parliament::Search::Application).not_to be(nil)
  end
end
