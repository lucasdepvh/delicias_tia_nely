max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
threads max_threads_count, max_threads_count

port ENV.fetch("PORT", 3000)
bind "tcp://#{ENV.fetch("BIND_HOST", "127.0.0.1")}:#{ENV.fetch("PORT", 3000)}"
environment ENV.fetch("RAILS_ENV", "development")
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")
plugin :tmp_restart
