module Diplomat
  # Methods for interacting with the Consul check API endpoint
  class Check < Diplomat::RestClient
    @access_methods = %i[checks register_script register_ttl
                         deregister pass warn fail]

    # Get registered checks
    # @return [OpenStruct] all data associated with the service
    def checks
      ret = @conn.get '/v1/agent/checks'
      JSON.parse(ret.body)
    end

    # Register a check
    # @param check_id [String] the unique id of the check
    # @param name [String] the name
    # @param notes [String] notes about the check
    # @param script [String] command to be run for check
    # @param interval [String] frequency (with units) of the check execution
    # @param ttl [String] time (with units) to mark a check down
    # @return [Integer] Status code
    #
    def register_script(check_id, name, notes, script, interval)
      ret = @conn.put do |req|
        req.url '/v1/agent/check/register'
        req.body = JSON.generate(
          'ID' => check_id, 'Name' => name, 'Notes' => notes, 'Script' => script, 'Interval' => interval
        )
      end
      ret.status == 200
    end

    # Register a TTL check
    # @param check_id [String] the unique id of the check
    # @param name [String] the name
    # @param notes [String] notes about the check
    # @param ttl [String] time (with units) to mark a check down
    # @return [Boolean] Success
    def register_ttl(check_id, name, notes, ttl)
      ret = @conn.put do |req|
        req.url '/v1/agent/check/register'
        req.body = JSON.generate(
          'ID' => check_id, 'Name' => name, 'Notes' => notes, 'TTL' => ttl
        )
      end
      ret.status == 200
    end

    # Deregister a check
    # @param check_id [String] the unique id of the check
    # @return [Integer] Status code
    def deregister(check_id)
      ret = @conn.put "/v1/agent/check/deregister/#{check_id}"
      ret.status == 200
    end

    # Update a TTL check
    # @param check_id [String] the unique id of the check
    # @param status [String] status of the check. Valid values are "passing", "warning", and "critical"
    # @param output [String] human-readable message will be passed through to the check's Output field
    # @return [Integer] Status code
    def update_ttl(check_id, status, output = nil)
      ret = @conn.put do |req|
        req.url "/v1/agent/check/update/#{check_id}"
        req.body = JSON.generate('Status' => status, 'Output' => output)
      end
      ret.status == 200
    end

    # Pass a check
    # @param check_id [String] the unique id of the check
    # @param output [String] human-readable message will be passed through to the check's Output field
    # @return [Integer] Status code
    def pass(check_id, output = nil)
      update_ttl(check_id, 'passing', output)
    end

    # Warn a check
    # @param check_id [String] the unique id of the check
    # @param output [String] human-readable message will be passed through to the check's Output field
    # @return [Integer] Status code
    def warn(check_id, output = nil)
      update_ttl(check_id, 'warning', output)
    end

    # Fail a check
    # @param check_id [String] the unique id of the check
    # @param output [String] human-readable message will be passed through to the check's Output field
    # @return [Integer] Status code
    def fail(check_id, output = nil)
      update_ttl(check_id, 'critical', output)
    end
  end
end
