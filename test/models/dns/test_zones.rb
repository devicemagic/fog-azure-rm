require File.expand_path '../../test_helper', __dir__

# Test class for Zone Collection
class TestZones < Minitest::Test
  def setup
    @service = Fog::DNS::AzureRM.new(credentials)
    @zones = Fog::DNS::AzureRM::Zones.new(service: @service)
    @response = [ApiStub::Models::DNS::Zone.list_zones]
  end

  def test_collection_methods
    methods = [
      :all,
      :get
    ]
    methods.each do |method|
      assert @zones.respond_to? method, true
    end
  end

  def test_all_method_response
    @service.stub :list_zones, @response do
      assert_instance_of Fog::DNS::AzureRM::Zones, @zones.all
      assert @zones.all.size >= 1
      @zones.all.each do |s|
        assert_instance_of Fog::DNS::AzureRM::Zone, s
      end
    end
  end

  def test_get_method_response
    @service.stub :list_zones, @response do
      assert_instance_of Fog::DNS::AzureRM::Zone, @zones.get('fog-test-zone.com', 'fog-test-rg')
    end
  end
end
