import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["address"]
  toggleDelivery(event) { this.addressTarget.classList.toggle("is-hidden", event.target.value !== "delivery") }
}
