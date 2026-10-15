module ApplicationHelper
  BRAND_NAME = "Delícias da Tia Nely".freeze
  DEFAULT_DESCRIPTION = "Delícias da Tia Nely prepara quitandas, salgados e sabores especiais.".freeze

  def page_title(title = nil)
    title.present? ? "#{title} | #{BRAND_NAME}" : BRAND_NAME
  end

  def page_description(description = nil)
    description.presence || DEFAULT_DESCRIPTION
  end

  def format_brl(value)
    number_to_currency(value || 0, unit: "R$", separator: ",", delimiter: ".", format: "%u %n")
  end

  def canonical_url
    request.original_url.split("?").first
  end

  def brand_name
    BRAND_NAME
  end
end
