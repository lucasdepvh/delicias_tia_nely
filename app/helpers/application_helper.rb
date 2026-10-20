module ApplicationHelper
  BRAND_NAME = "Delícias da Tia Nely".freeze
  DEFAULT_DESCRIPTION = "Delícias da Tia Nely prepara quitandas, salgados e sabores especiais.".freeze
  CHECKOUT_ICON_PATHS = {
    back: "M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z",
    check: "m9 16.17-4.17-4.18L3.41 13.4 9 19 21 7l-1.41-1.41z",
    truck: "M20 8h-3V4H3c-1.1 0-2 .9-2 2v11h2c0 1.66 1.34 3 3 3s3-1.34 3-3h6c0 1.66 1.34 3 3 3s3-1.34 3-3h2v-5zM6 18.5c-.83 0-1.5-.67-1.5-1.5S5.17 15.5 6 15.5s1.5.67 1.5 1.5S6.83 18.5 6 18.5zM15 15H9.82c-.55-1.2-1.76-2-3.18-2s-2.63.8-3.18 2H3V6h12zm3 3.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zM17 13V10h2.5l2.04 3z",
    message: "M20 2H4c-1.1 0-1.99.9-1.99 2L2 22l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zM6 9h12v2H6zm8 5H6v-2h8zm4-6H6V6h12z",
    person: "M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z",
    store: "M4 4 2 9v2h1v9h8v-6h2v6h8v-9h1V9l-2-5zm0 7h2v2H4zm4 0h2v2H8zm4 0h2v2h-2zm4 0h2v2h-2zm3-2H5l1-3h12z",
    payment: "M21 4H3c-1.11 0-1.99.89-1.99 2L1 18c0 1.11.89 2 2 2h18c1.11 0 2-.89 2-2V6c0-1.11-.89-2-2-2zm0 14H3v-6h18zm0-10H3V6h18z",
    heart: "M12 21.35 10.55 20C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.51z",
    receipt: "M19 3H5c-1.1 0-2 .9-2 2v16l3-2 3 2 3-2 3 2 3-2 3 2V5c0-1.1-.9-2-2-2zM8 15H6v-2h2zm0-4H6V9h2zm6 4h-4v-2h4zm0-4h-4V9h4zm4 4h-2v-2h2zm0-4h-2V9h2z",
    edit: "M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.03 0-1.42l-2.34-2.33a.9959.995 0 0 0-1.41 0l-1.83 1.83 3.75 3.75z",
    product: "M12 2 4 6v5c0 5.05 3.41 9.76 8 11 4.59-1.24 8-5.95 8-11V6zm0 2.18L17.74 7 12 9.82 6.26 7zm-6 4.44 5 2.46v7.32c-2.97-1.24-5-4.73-5-7.4zm7 9.78v-7.32l5-2.46v2.78c0 2.67-2.03 6.16-5 7.4z",
    lock: "M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1s3.1 1.39 3.1 3.1z"
  }.freeze
  NAVIGATION_ICON_PATHS = {
    cart: "M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45C5.09 14.32 5 14.65 5 15c0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03L20.88 5.5c.08-.14.12-.31.12-.5 0-.55-.45-1-1-1H5.21l-.94-2zM17 18c-1.1 0-1.99.9-1.99 2S15.9 22 17 22s2-.9 2-2-.9-2-2-2z",
    login: "M10 17v-2h7V9h-7V7l-5 5zm-6 2v-4H2v4c0 1.1.9 2 2 2h8v-2zm0-16c-1.1 0-2 .9-2 2v4h2V5h8V3z",
    trash: "M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6zm2.46-7.12 1.41-1.41L12 12.59l2.12-2.12 1.41 1.41L13.41 14l2.12 2.12-1.41 1.41L12 15.41l-2.12 2.12-1.41-1.41L10.59 14zM15.5 4l-1-1h-5l-1 1H5v2h14V4z"
  }.freeze

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

  def checkout_icon(name, class_name: nil)
    path = CHECKOUT_ICON_PATHS.fetch(name)
    content_tag(:svg, tag.path(d: path), class: [ "checkout-icon", class_name ].compact.join(" "),
      viewBox: "0 0 24 24", aria: { hidden: true }, focusable: false)
  end

  def navigation_icon(name)
    content_tag(:svg, tag.path(d: NAVIGATION_ICON_PATHS.fetch(name)), class: "navigation-icon",
      viewBox: "0 0 24 24", aria: { hidden: true }, focusable: false)
  end
end
