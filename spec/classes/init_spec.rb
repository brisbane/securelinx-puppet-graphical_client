require 'spec_helper'
describe 'graphical_client' do
  context 'with default values for all parameters' do
    it { should contain_class('graphical_client') }
  end
end
