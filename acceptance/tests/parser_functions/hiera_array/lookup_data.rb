test_name "Lookup data using the hiera_array parser function" do
  tag 'audit:medium',
      'audit:acceptance'

  agents.each do |agent|
    on(agent, puppet('agent', "-t"), :acceptable_exit_codes => [2])

    assert_match("ntpserver global.ntp.puppetlabs.com", stdout)
    assert_match("ntpserver production.ntp.puppetlabs.com", stdout)
  end
end
