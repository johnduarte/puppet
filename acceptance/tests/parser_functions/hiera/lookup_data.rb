test_name "Lookup data using the hiera parser function" do
  tag 'audit:medium',
      'audit:acceptance'

  agents.each do |agent|
    on(agent, puppet('agent', "-t"), :acceptable_exit_codes => [2])

    assert_match("apache server port: 8080", stdout)
  end
end
