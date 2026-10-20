import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["drawer"]
  open(event) { event.preventDefault(); this.drawerTarget.classList.add("is-open"); this.drawerTarget.setAttribute("aria-hidden", "false") }
  close() { this.drawerTarget.classList.remove("is-open"); this.drawerTarget.setAttribute("aria-hidden", "true") }
  updateQuantity(event) { event.currentTarget.form.requestSubmit() }
}
