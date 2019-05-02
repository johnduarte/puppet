test_name "utf-8 characters in module doc string, puppet describe" do
  tag 'audit:medium',      # utf-8 is high impact in general, puppet describe low risk?
      'audit:integration'  # not package dependent but may want to vary platform by LOCALE/encoding

  confine :except, :platform => /^eos-/ # Puppet describe fails when the Arista module is installed (ARISTA-51)"

  # utf8chars = "€‰ㄘ万竹ÜÖ"
  utf8chars = "\u20ac\u2030\u3118\u4e07\u7af9\u00dc\u00d6"

  agents.each do |agent|
    testdir = agent.tmpdir("describe_utf-8_type")
    confdir = "#{testdir}/puppet"
    manifest =
      <<~MANIFEST
        File {
          ensure => directory,
          mode => "0755",
        }
         file {
          '#{confdir}':;
          '#{testdir}/code':;
          '#{testdir}/code/environments':;
          '#{testdir}/code/environments/production':;
          '#{testdir}/code/environments/production/modules':;
          '#{testdir}/code/environments/production/modules/mytype_module':;
          '#{testdir}/code/environments/production/modules/mytype_module/lib':;
          '#{testdir}/code/environments/production/modules/mytype_module/lib/puppet':;
          '#{testdir}/code/environments/production/modules/mytype_module/lib/puppet/type':;
        }
         file { '#{confdir}/puppet.conf' :
          ensure => file,
          mode => '0755',
          content => '
        [user]
        environment = production
        [main]
        codedir = #{testdir}/code
        ',
        }
         file { '#{testdir}/code/environments/production/modules/mytype_module/lib/puppet/type/mytype.rb' :
          ensure => file,
          mode => '0755',
          content => '
        Puppet::Type.newtype(:mytype) do
          @doc = "Testing to see if puppet handles describe blocks correctly
        when they contain utf8 characters, such as #{utf8chars}
        "
          newparam(:name) do
            isnamevar
            desc " name parameter for mytype, also with some utf8 chars #{utf8chars}"
          end
        end
        ',
        }
      MANIFEST

    apply_manifest_on(agent, manifest)

    puts "agent name: #{agent.hostname}, platform: #{agent.platform}"

  step "Start puppet server"
  with_puppet_running_on(master, master_opts, master_mod_dir) do
    agents.each do |agent|
      puts "agent name: #{agent.hostname}, platform: #{agent.platform}"
      step "Run puppet agent for plugin sync" do 
        on(
          agent, puppet("agent", "-t"),
          :acceptable_exit_codes => [0, 2]
        )
      end
    end
  end
end
