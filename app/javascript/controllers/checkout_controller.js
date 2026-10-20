import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["address", "fee", "total", "message", "submit"]
  static values = { subtotal: Number, fee: Number }
  connect() { this.toggleDelivery() }
  field(name) { return this.element.querySelector('[name="customer[' + name + ']"]') }
  delivery() { return this.element.querySelector('[name="order[fulfillment_method]"]:checked')?.value === "delivery" }
  toggleDelivery() {
    this.addressTarget.classList.toggle("is-hidden", !this.delivery())
    this.quote()
  }
  money(value) { return value.toLocaleString("pt-BR", { style: "currency", currency: "BRL" }) }
  async quote() {
    const request = this.quoteRequest = (this.quoteRequest || 0) + 1
    let fee = this.delivery() ? this.feeValue : 0
    this.feeTarget.textContent = this.money(fee)
    this.totalTarget.textContent = this.money(this.subtotalValue + fee)
    if (!this.delivery()) return
    try {
      const response = await fetch("/finalizar-pedido/frete?neighborhood=" + encodeURIComponent(this.field("neighborhood").value), { headers: { Accept: "application/json" } })
      if (!response.ok) return
      const data = await response.json()
      if (request !== this.quoteRequest) return
      fee = Number(data.fee)
      this.feeTarget.textContent = this.money(fee)
      this.totalTarget.textContent = this.money(this.subtotalValue + fee)
      this.messageTarget.textContent = [data.message, data.estimated_time].filter(Boolean).join(" ")
    } catch { this.messageTarget.textContent = "Confira o frete ao finalizar. A estimativa usa a taxa padrão." }
  }
  async lookupPostalCode() {
    const code = this.field("zip_code").value.replace(/\D/g, "")
    try {
      const response = await fetch("/cep/" + encodeURIComponent(code || "invalido"), { headers: { Accept: "application/json" } })
      const data = await response.json()
      if (this.field("zip_code").value.replace(/\D/g, "") !== code) return
      if (!response.ok) { this.messageTarget.textContent = data.error; return }
      for (const [field, key] of Object.entries({ street: "logradouro", neighborhood: "bairro", city: "localidade", state: "uf" })) {
        if (data[key]) this.field(field).value = data[key]
      }
      this.field("number").focus()
      this.quote()
    } catch { this.messageTarget.textContent = "Consulta indisponível. Preencha o endereço manualmente." }
  }
  formatPostalCode(event) { event.target.value = event.target.value.replace(/\D/g, "").slice(0, 8).replace(/^(\d{5})(\d)/, "$1-$2") }
  formatPhone(event) {
    const digits = event.target.value.replace(/\D/g, "").slice(0, 15)
    event.target.value = digits.length <= 11 ? digits.replace(/^(\d{2})(\d)/, "($1) $2").replace(/(\d{4,5})(\d{4})$/, "$1-$2") : digits
  }
  submit(event) {
    if (this.submitting) { event.preventDefault(); return }
    this.submitting = true
    this.submitTarget.disabled = true
    this.submitTarget.value = "Registrando pedido..."
  }
}
