
module HammerCLIKatello
  module ForemanExceptionHandlerExtensions
    def ssl_cert_instructions
      host_url = HammerCLI::Settings.get(:_params, :host) || HammerCLI::Settings.get(:foreman, :host)
      uri = URI.parse(host_url)
      cert_url = "http://#{uri.host}/pub/katello-server-ca.crt"

      _("Make sure you downloaded the server ca certificate from %{cert_url} and installed it onto your system.") % { :cert_url => cert_url } +
      "\n" +
      _("Alternatively you can use options --ssl-ca-path and --ssl-ca-file or corresponding settings in your configuration file.")
    end
  end
  ::HammerCLIForeman::ExceptionHandler.prepend(ForemanExceptionHandlerExtensions)

  class ExceptionHandler < HammerCLIForeman::ExceptionHandler
    def mappings
      super + [
        [RestClient::InternalServerError, :handle_internal_error],
        [RestClient::BadRequest, :handle_bad_request]
      ]
    end

    protected

    def handle_internal_error(e)
      handle_katello_error(e)
      HammerCLI::EX_SOFTWARE
    end

    def handle_unprocessable_entity(e)
      handle_katello_error(e)
      HammerCLI::EX_DATAERR
    end

    def handle_not_found(e)
      handle_katello_error(e)
      HammerCLI::EX_NOT_FOUND
    end

    def handle_bad_request(e)
      handle_katello_error(e)
      HammerCLI::EX_NOT_FOUND
    end

    def handle_katello_error(e)
      response = JSON.parse(e.response)
      response = HammerCLIForeman.record_to_common_format(response)
      # Check multiple possible keys that can contain error message:
      # - displayMessage for katello specific messages
      # - full_messages for for messages that come from rails
      # - message for foreman specific messages
      print_error response["displayMessage"] || response["full_messages"] || response["message"]
      log_full_error e
    end
  end
end
