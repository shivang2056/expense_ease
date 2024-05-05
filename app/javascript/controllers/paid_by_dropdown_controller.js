import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="paid-by-dropdown"
export default class extends Controller {
  static targets = ["menu", "paidByUser", "paidByUserLabel"]

  connect() {
  }

  toggle(e) {
    e.preventDefault();
    this.menuTarget.classList.toggle('hidden');
  }

  setUser(e) {
    e.preventDefault();

    this.paidByUserTarget.value = e.params.id;
    this.paidByUserLabelTarget.innerHTML = e.params.name;
  }

  hide(event) {
    if (
      !this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")
    ) {
      this.menuTarget.classList.toggle('hidden');
    }
  }
}
