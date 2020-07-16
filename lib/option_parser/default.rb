module SASOptionParser
  class Defaults
    @@defaults_options = {
      :url                       => 'https://localhost/',
      :timeout                   => 300,
      :user                      => 'admin',
      :pass                      => 'change_me',
      :org                       => 1,
      :verify_ssl                => true,
      :config_file               => 'config.yaml',
      # :virtwho                   => false,
      # :virtwhocachefile          => 'virt-who.cache',
      :auto_heal                 => "noop",
      :multi_search              => false,
      :clean_same_sub            => false,
      :empty_hypervisor          => false,
      :density                   => false,
      :density_value             => 4,
      :density_els_value         => 4,
      :density_els_version       => 6,
      :force_density             => false,
      :density_file              => 'cluster-state.csv',
      :guest_report_file         => 'guest-report.csv',
      :report                    => false,
      :report_file               => 'sub-report.csv',
      :report_detail_file        => 'detailed-report.csv',
      :api_repeat                => false,
      :api_max_step              => 1,
      :api_sleep                 => false,
      :api_sleep_time            => 0,
      :api_sleep_mult            => 1,
      :concurrency               => false,
      :concurrency_max_thread    => 2,
      :verbose                   => false,
      :debug                     => false,
      :noop                      => false
    }
  end
end
