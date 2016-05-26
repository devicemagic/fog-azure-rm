module Fog
  module Network
    class AzureRM
      # LoadBalancer model class for Network Service
      class LoadBalancer < Fog::Model
        identity :name
        attribute :id
        attribute :location
        attribute :resource_group
        attribute :frontend_ip_configurations
        attribute :backend_address_pool_names
        attribute :load_balancing_rules
        attribute :probes
        attribute :inbound_nat_rules
        attribute :inbound_nat_pools

        # @param [Object] load_balancer
        def self.parse(load_balancer)
          load_balancer_properties = load_balancer['properties']

          hash = {}
          hash['id'] = load_balancer['id']
          hash['name'] = load_balancer['name']
          hash['location'] = load_balancer['location']
          hash['resource_group'] = load_balancer['id'].split('/')[4]
          hash['backend_address_pool_names'] = load_balancer_properties['backendAddressPools'].map { |item| item['name'] } unless load_balancer_properties['backendAddressPools'].nil?

          hash['frontend_ip_configurations'] = []
          load_balancer_properties['frontendIPConfigurations'].each do |fic|
            frontend_ip_configuration = Fog::Network::AzureRM::FrontendIPConfiguration.new
            hash['frontend_ip_configurations'] << frontend_ip_configuration.merge_attributes(Fog::Network::AzureRM::FrontendIPConfiguration.parse(fic))
          end unless load_balancer_properties['frontendIPConfigurations'].nil?

          hash['load_balancing_rules'] = []
          load_balancer_properties['loadBalancingRules'].each do |lbr|
            load_balancing_rule = Fog::Network::AzureRM::LoadBalangcingRule.new
            hash['load_balancing_rules'] << load_balancing_rule.merge_attributes(Fog::Network::AzureRM::LoadBalangcingRule.parse(lbr))
          end unless load_balancer_properties['loadBalancingRules'].nil?

          hash['probes'] = []
          load_balancer_properties['probes'].each do |prb|
            prob = Fog::Network::AzureRM::Probe.new
            hash['probes'] << prob.merge_attributes(Fog::Network::AzureRM::Probe.parse(prb))
          end unless load_balancer_properties['probes'].nil?

          hash['inbound_nat_rules'] = []
          load_balancer_properties['inboundNatRules'].each do |inr|
            inbound_nat_rule = Fog::Network::AzureRM::InboundNatRule.new
            hash['inbound_nat_rules'] << inbound_nat_rule.merge_attributes(Fog::Network::AzureRM::InboundNatRule.parse(inr))
          end unless load_balancer_properties['inboundNatRules'].nil?

          hash['inbound_nat_rules'] = []
          load_balancer_properties['inboundNatPools'].each do |inp|
            inbound_nat_pool = Fog::Network::AzureRM::InboundNatPool.new
            hash['inbound_nat_rules'] << inbound_nat_pool.merge_attributes(Fog::Network::AzureRM::InboundNatPool.parse(inp))
          end unless load_balancer_properties['inboundNatPools'].nil?

          hash
        end

        def save
          requires :name, :location, :resource_group

          unless frontend_ip_configurations.nil?
            validate_frontend_ip_configurations(frontend_ip_configurations)
          end
          unless load_balancing_rules.nil?
            validate_load_balancing_rules(load_balancing_rules)
          end
          validate_probes(probes) unless probes.nil?
          unless inbound_nat_rules.nil?
            validate_inbound_nat_rules(inbound_nat_rules)
          end
          unless inbound_nat_pools.nil?
            validate_inbound_nat_pools(inbound_nat_pools)
          end

          load_balancer = service.create_load_balancer(name, location, resource_group, frontend_ip_configurations, backend_address_pool_names, load_balancing_rules, probes, inbound_nat_rules, inbound_nat_pools)

          merge_attributes(Fog::Network::AzureRM::LoadBalancer.parse(load_balancer))
        end

        def validate_load_balancing_rules(load_balancing_rules)
          if load_balancing_rules.is_a?(Array)
            if load_balancing_rules.any?
              load_balancing_rules.each do |lbr|
                if lbr.is_a?(Hash)
                  validate_load_balancing_rule_params(lbr)
                else
                  raise(ArgumentError, ':load_balancing_rules must be an Array of Hashes')
                end
              end
            else
              raise(ArgumentError, ':load_balancing_rules must not be an empty Array')
            end
          else
            raise(ArgumentError, ':load_balancing_rules must be an Array')
          end
        end

        def validate_load_balancing_rule_params(lbr)
          required_params = [
            :name,
            :protocol,
            :frontend_port,
            :backend_port
          ]
          missing = required_params.select { |p| p unless lbr.key?(p) }
          if missing.length == 1
            raise(ArgumentError, "#{missing.first} is required for this operation")
          elsif missing.any?
            raise(ArgumentError, "#{missing[0...-1].join(', ')} and #{missing[-1]} are required for this operation")
          end
        end

        def validate_probes(probes)
          if probes.is_a?(Array)
            if probes.any?
              probes.each do |prb|
                if prb.is_a?(Hash)
                  validate_probe_params(prb)
                else
                  raise(ArgumentError, ':probes must be an Array of Hashes')
                end
              end
            else
              raise(ArgumentError, ':probes must not be an empty Array')
            end
          else
            raise(ArgumentError, ':probes must be an Array')
          end
        end

        def validate_probe_params(prb)
          required_params = [
            :name,
            :port,
            :request_path,
            :interval_in_seconds,
            :number_of_probes
          ]
          missing = required_params.select { |p| p unless prb.key?(p) }
          if missing.length == 1
            raise(ArgumentError, "#{missing.first} is required for this operation")
          elsif missing.any?
            raise(ArgumentError, "#{missing[0...-1].join(', ')} and #{missing[-1]} are required for this operation")
          end
        end

        def validate_inbound_nat_rules(inbound_nat_rules)
          if inbound_nat_rules.is_a?(Array)
            if inbound_nat_rules.any?
              inbound_nat_rules.each do |inr|
                if inr.is_a?(Hash)
                  validate_inbound_nat_rule_params(inr)
                else
                  raise(ArgumentError, ':inbound_nat_rules must be an Array of Hashes')
                end
              end
            else
              raise(ArgumentError, ':inbound_nat_rules must not be an empty Array')
            end
          else
            raise(ArgumentError, ':inbound_nat_rules must be an Array')
          end
        end

        def validate_inbound_nat_rule_params(inr)
          required_params = [
            :name,
            :protocol,
            :frontend_port,
            :backend_port
          ]
          missing = required_params.select { |p| p unless inr.key?(p) }
          if missing.length == 1
            raise(ArgumentError, "#{missing.first} is required for this operation")
          elsif missing.any?
            raise(ArgumentError, "#{missing[0...-1].join(', ')} and #{missing[-1]} are required for this operation")
          end
        end

        def validate_inbound_nat_pools(inbound_nat_pools)
          if inbound_nat_pools.is_a?(Array)
            if inbound_nat_pools.any?
              inbound_nat_pools.each do |inp|
                if inp.is_a?(Hash)
                  validate_inbound_nat_pool_params(inp)
                else
                  raise(ArgumentError, ':inbound_nat_pools must be an Array of Hashes')
                end
              end
            else
              raise(ArgumentError, ':inbound_nat_pools must not be an empty Array')
            end
          else
            raise(ArgumentError, ':inbound_nat_pools must be an Array')
          end
        end

        def validate_inbound_nat_pool_params(inp)
          required_params = [
            :name,
            :protocol,
            :frontend_port_range_start,
            :frontend_port_range_end,
            :backend_port
          ]
          missing = required_params.select { |p| p unless inp.key?(p) }
          if missing.length == 1
            raise(ArgumentError, "#{missing.first} is required for this operation")
          elsif missing.any?
            raise(ArgumentError, "#{missing[0...-1].join(', ')} and #{missing[-1]} are required for this operation")
          end
        end

        def validate_frontend_ip_configurations(frontend_ip_configurations)
          if frontend_ip_configurations.is_a?(Array)
            if frontend_ip_configurations.any?
              frontend_ip_configurations.each do |fic|
                if fic.is_a?(Hash)
                  validate_frontend_ip_configuration_params(fic)
                else
                  raise(ArgumentError, ':frontend_ip_configurations must be an Array of Hashes')
                end
              end
            else
              raise(ArgumentError, ':frontend_ip_configurations must not be an empty Array')
            end
          else
            raise(ArgumentError, ':frontend_ip_configurations must be an Array')
          end
        end

        def validate_frontend_ip_configuration_params(fic)
          required_params = [
            :name,
            :private_ipallocation_method
          ]
          missing = required_params.select { |p| p unless fic.key?(p) }
          if missing.length == 1
            raise(ArgumentError, "#{missing.first} is required for this operation")
          elsif missing.any?
            raise(ArgumentError, "#{missing[0...-1].join(', ')} and #{missing[-1]} are required for this operation")
          end
          unless fic.key?(:subnet_id) || fic.key?(:public_ipaddress_id)
            raise(ArgumentError, 'subnet_id and public_id can not be empty at the same time.')
          end
        end

        def destroy
          service.delete_load_balancer(resource_group, name)
        end
      end
    end
  end
end
