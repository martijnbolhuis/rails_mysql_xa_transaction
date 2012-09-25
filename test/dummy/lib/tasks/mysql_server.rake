# # Add this to /etc/sudoers
# %martijn ALL=(root) NOPASSWD:/usr/sbin/mysqld
# %martijn ALL=(root) NOPASSWD:/bin/kill

namespace :mysql do
  desc "Start mysql server"
  task :start do
    pid = `ps -ef | grep mysql | awk '{if ($1 ~ /mysql/) print $2}'`
    system 'sudo mysqld &' unless pid.present?
  end

  desc "Stop mysql server"
  task :stop do
    pid = `ps -ef | grep mysql | awk '{if ($1 ~ /mysql/) print $2}'`
    system "sudo kill #{pid}"
  end

  desc "Crash mysql server"
  task :crash do
    pid = `ps -ef | grep mysql | awk '{if ($1 ~ /mysql/) print $2}'`
    system "sudo kill -9 #{pid}"
  end

end