require "my_profiler"

class MyProfiler::Railtie < ::Rails::Railtie
  ActiveSupport.on_load(:action_controller) do
    ActiveSupport::Notifications.subscribe "start_processing.action_controller" do |name, start, finish, id, payload|
      MyProfiler.start_log(payload)
    end

    ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
      MyProfiler.stop_log(start, finish, payload)
    end
  end
  ActiveSupport.on_load(:active_record) do
    ActiveSupport::Notifications.subscribe /active_record/ do |name, start, finish, id, payload|
      MyProfiler.rec_log(start, finish, payload)
    end
  end
end