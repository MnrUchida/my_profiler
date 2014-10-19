class SqlLog

  def initialize(payload, id)
    @config = if File.exist?("config/my_profiler/config.yml")
                YAML.load_file("config/my_profiler/config.yml")
              else
                { "sql_count" => 30, "time" => 500 }
              end
    @id = id
    @controller = payload[:controller]
    @action = payload[:action]
    @sql_records = []
    @bc = ActiveSupport::BacktraceCleaner.new
    if @config["app_name"].present?
      @bc.add_silencer { |line| not (line =~ /#{@config["app_name"]}/) }
    end
  end

  def rec_sql(start, finish, payload)
    return if payload[:name] == "SCHEMA"
    @sql_records << {name: payload[:name], sql: payload[:sql], time: ((finish - start) * 1000).round(3), caller: @bc.clean(caller)[1..4]}
  end

  def rec_action_end(start, finish, payload)
    @time = ((finish - start) * 1000).round(3)
  end

  def output
    return unless output?

    File.open("tmp/spent_time.yml", "a") do |io|
      YAML.dump( {id: @id, controller: @controller, action: @action, time: @time, sql_count: @sql_records.count}, io )
    end

    File.open("tmp/sql_log.yml", "a") do |io|
      io.set_encoding("utf-8", :undef => :replace)
      YAML.dump( to_hash, io )
    end
  end

  private
  def to_hash
    {id: @id, controller: @controller, action: @action, sql: @sql_records}
  end

  def output?
    return true if @config["sql_count"].present? && @sql_records.count > @config["sql_count"].to_i
    return true if @config["time"].present? && @time > @config["time"].to_i
  end
end
