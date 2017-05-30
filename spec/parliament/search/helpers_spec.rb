require_relative '../../spec_helper'

RSpec.describe Parliament::Search::Helpers do
  it 'should be a module' do
    expect(Parliament::Search::Helpers).to be_a(Module)
  end

  it 'should autoload PaginationHelper' do
    expect(Parliament::Search::Helpers::PaginationHelper).not_to be(nil)
  end

end
