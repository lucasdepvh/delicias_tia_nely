require "net/http"
require "json"

class PostalCodesController < PublicController
  def show
    code = params[:zip_code].to_s.gsub(/\D/, "")
    return render json: { error: "Informe um CEP com 8 dígitos." }, status: :unprocessable_entity unless code.match?(/\A\d{8}\z/)

    uri = URI("https://viacep.com.br/ws/#{code}/json/")
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 3, read_timeout: 3) { |http| http.get(uri.request_uri) }
    raise IOError unless response.is_a?(Net::HTTPSuccess)
    address = JSON.parse(response.body)
    return render json: { error: "CEP não encontrado. Preencha o endereço manualmente." }, status: :not_found if address["erro"]

    render json: address.slice("logradouro", "bairro", "localidade", "uf")
  rescue Timeout::Error, SocketError, SystemCallError, IOError, JSON::ParserError, OpenSSL::SSL::SSLError
    render json: { error: "Consulta de CEP indisponível. Preencha o endereço manualmente." }, status: :service_unavailable
  end
end
