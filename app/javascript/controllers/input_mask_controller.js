import { Controller } from "@hotwired/stimulus"

// Mantém a apresentação brasileira nos campos, enquanto o servidor continua
// responsável por normalizar e validar os valores recebidos.
export default class extends Controller {
  static values = { type: String }

  connect() {
    if (this.typeValue === "currency") this.formatInitialCurrency()
    else this.format()
  }

  format() {
    if (this.typeValue === "phone") this.element.value = this.phone(this.element.value)
    if (this.typeValue === "postal-code") this.element.value = this.postalCode(this.element.value)
  }

  formatCurrency() {
    const digits = this.element.value.replace(/\D/g, "")
    this.element.value = this.currencyFromCents(digits)
  }

  formatInitialCurrency() {
    const value = this.element.value.trim()
    if (!value) return

    const normalized = value.replace(/[^\d,.-]/g, "")
    const decimal = normalized.includes(",") ? normalized.replace(/\./g, "").replace(",", ".") : normalized
    const cents = Math.round(Number(decimal) * 100)
    this.element.value = Number.isFinite(cents) ? this.currencyFromCents(String(cents)) : ""
  }

  phone(value) {
    const digits = value.replace(/\D/g, "").slice(0, 11)
    return digits.replace(/^(\d{2})(\d)/, "($1) $2").replace(/(\d{4,5})(\d{4})$/, "$1-$2")
  }

  postalCode(value) {
    return value.replace(/\D/g, "").slice(0, 8).replace(/^(\d{5})(\d)/, "$1-$2")
  }

  currencyFromCents(digits) {
    const cents = Number(digits || 0)
    return Number.isFinite(cents) ? (cents / 100).toLocaleString("pt-BR", { style: "currency", currency: "BRL" }) : ""
  }
}
