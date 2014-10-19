require "my_profiler/version"
require "my_profiler/sql_log"

module MyProfiler
  def self.start_log(payload)
    @id ||= 0
    @id += 1
    @sql_log = SqlLog.new(payload, @id)
  end

  def self.stop_log(start, finish, payload)
    @sql_log.rec_action_end(start, finish, payload)
    @sql_log.output
    @sql_log = nil
  end

  def self.rec_log(start, finish, payload)
    if @sql_log.present?
      @sql_log.rec_sql(start, finish, payload)
    end
  end
end

require 'my_profiler/railtie' if defined?(Rails)