import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="split-by-dropdown"
export default class extends Controller {
  static targets = ["menu", "splitByMethod"]

  connect() {
  }

  toggle(e) {
    e.preventDefault();
    this.menuTarget.classList.toggle('hidden');
  }

  setSplitMethod(e) {
    e.preventDefault();

    this.splitByMethodTarget.value = e.params.name.split(' ').join('_');
    this.splitByMethodTarget.innerHTML = e.params.name;

    this.splitByMethodTarget.dispatchEvent(new Event('change'));
  }

  hide(event) {
    if (
      !this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")
    ) {
      this.menuTarget.classList.toggle('hidden');
    }
  }
}
