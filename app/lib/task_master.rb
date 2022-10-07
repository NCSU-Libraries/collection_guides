module TaskMaster

  # require 'general_utilities.rb'
  include GeneralUtilities

  def pids_directory_path
    "#{Rails.root}/tmp/pids"
  end


  def add_task_pid(task_name)
    pid_path = get_pid_path(task_name)
    # deploy_user_id = `id -u deploy`.strip.to_i

    if !File.exist?(pid_path)
      if !Dir.exist?(pids_directory_path)
        Dir.mkdir(pids_directory_path)
      end
      pid = Process.pid

      if pid
        pid_file = File.new(pid_path,"w")

        log_info "Adding pid file for process: #{ pid }"
        pid_file << pid.to_s

        # File.chown(deploy_user_id,deploy_user_id,pid_path)
        pid_file.close
        log_info "PID file added: #{ pid_path }"
        true
      end
    else
      pid = get_pid(task_name)
      if !pid || pid.length == 0 || !process_status(pid)
        log_info "PID file found but corresponding process does not exist"
        remove_task_pid(task_name)
        add_task_pid(task_name)
      else
        log_info "PID file found, indicating that the corresponding task is already running"
        nil
      end
    end
  end


  def remove_task_pid(task_name)
    pid_path = get_pid_path(task_name)

    if File.exist?(pid_path)
      # pid = get_pid(task_name)
      File.delete(pid_path)
      log_info "PID file removed: #{ pid_path }"
    end
  end


  def get_pid_path(task_name)
    "#{pids_directory_path}/#{task_name}.pid"
  end


  def get_pid(task_name)
    pid_path = get_pid_path(task_name)
    pid = nil
    if File.exist?(pid_path)
      pid = File.read(pid_path)
    end
    pid.strip
  end


  def process_status(pid)
    status = `ps -o state --no-headers #{ pid }`
    return status.empty? ? nil : status
  end


  def clear_all_pids

    if Dir.exist?(pids_directory_path)
      Dir.entries(pids_directory_path).each do |f|
        if f.match(/\.pid$/)
          task_name = f.gsub(/\.pid/,'')
          remove_task_pid(task_name)
        end
      end
    end
  end

end
