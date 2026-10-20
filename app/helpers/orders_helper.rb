module OrdersHelper
  def whatsapp_url_for(order)
    setting = StoreSetting.current
    return unless setting.commercial_details_ready?

    lines = [setting.order_message.presence || "Olá! Gostaria de confirmar este pedido.",
             "Pedido: #{order.number}", "Cliente: #{order.customer.name} — #{order.customer.phone}", "", "Itens:"]
    order.order_items.each do |item|
      lines << "#{item.quantity}x #{item.product_name} — #{format_brl(item.unit_price)} = #{format_brl(item.total)}"
    end
    lines += ["", "Subtotal: #{format_brl(order.subtotal)}", "Entrega: #{format_brl(order.delivery_fee)}",
              "Desconto: #{format_brl(order.discount_amount)}", "Total: #{format_brl(order.total)}",
              "Recebimento: #{order.delivery? ? 'Entrega' : 'Retirada'}", "Pagamento: #{order.payment_label}"]
    lines << "Troco para: #{format_brl(order.change_for)}" if order.change_for.present?
    lines << "Endereço: #{order.delivery_address}" if order.delivery?
    lines << "Observações: #{order.notes}" if order.notes.present?
    "https://wa.me/#{setting.whatsapp_number.to_s.gsub(/\D/, '')}?text=#{ERB::Util.url_encode(lines.join("\n"))}"
  end
end
