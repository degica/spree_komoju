module ActiveMerchant
  class Connection
    def request(method, body, headers = {})
      request_start = Time.now.to_f

      retry_exceptions(:max_retries => max_retries, :logger => logger, :tag => tag) do
        begin
          info "connection_http_method=#{method.to_s.upcase} connection_uri=#{endpoint}", tag

          result = nil

          realtime = Benchmark.realtime do
            result = case method
            when :get
              raise ArgumentError, "GET requests do not support a request body" if body
              http.get(endpoint.request_uri, headers)
            when :post
              debug body
              http.post(endpoint.request_uri, body, RUBY_184_POST_HEADERS.merge(headers))
            when :patch
              debug body
              http.patch(endpoint.request_uri, body, headers)
            when :put
              debug body
              http.put(endpoint.request_uri, body, headers)
            when :delete
              # It's kind of ambiguous whether the RFC allows bodies
              # for DELETE requests. But Net::HTTP's delete method
              # very unambiguously does not.
              raise ArgumentError, "DELETE requests do not support a request body" if body
              http.delete(endpoint.request_uri, headers)
            else
              raise ArgumentError, "Unsupported request method #{method.to_s.upcase}"
            end
          end

          info "--> %d %s (%d %.4fs)" % [result.code, result.message, result.body ? result.body.length : 0, realtime], tag
          debug result.body
          result
        end
      end

    ensure
      info "connection_request_total_time=%.4fs" % [Time.now.to_f - request_start], tag
    end
  end
end
