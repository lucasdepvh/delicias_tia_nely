import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "menu"]

  connect() {
    this.close()
  }

  toggle() {
    this.opened ? this.close() : this.open()
  }

  open() {
    this.menuTarget.classList.add("is-open")
    this.buttonTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    this.menuTarget.classList.remove("is-open")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  closeWithEscape(event) {
    if (event.key === "Escape") {
      this.close()
      this.buttonTarget.focus()
    }
  }

  get opened() {
    return this.menuTarget.classList.contains("is-open")
  }
}
