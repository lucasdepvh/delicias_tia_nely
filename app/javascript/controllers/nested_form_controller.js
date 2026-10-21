import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "list", "template" ]

  add() {
    const identifier = `${Date.now()}_${Math.random().toString(36).slice(2)}`
    this.listTarget.insertAdjacentHTML("beforeend", this.templateTarget.innerHTML.replaceAll("NEW_RECORD", identifier))
  }

  remove(event) {
    const item = event.target.closest("[data-nested-form-target='item']")
    const destroyField = item.querySelector("[data-nested-form-target='destroy']")

    if (item.dataset.newRecord === "true") {
      item.remove()
    } else {
      destroyField.value = "1"
      item.hidden = true
    }
  }
}
