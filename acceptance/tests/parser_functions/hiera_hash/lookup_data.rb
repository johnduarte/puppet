require "puppet/acceptance/puppet_type_test_tools.rb"
test_name "Lookup data using the hiera_hash parser function" do
  extend Puppet::Acceptance::PuppetTypeTestTools
  tag 'audit:medium',
      'audit:acceptance'

  agents.each do |agent|
    on(agent, puppet('agent', "-t"), :acceptable_exit_codes => [2])

    assert_match("name: postgres shell: /bin/bash", stdout)
  end
end
