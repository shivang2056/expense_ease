import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["options", "formInput", "button"]

  toggle(e) {
    e.preventDefault();
    this.optionsTarget.classList.toggle('hidden');
  }

  setOption(e) {
    e.preventDefault();

    this.formInputTarget.value = e.params.optionValue;
    this.buttonTarget.innerHTML = e.params.option;
  }

  hide(event) {
    if ( !this.element.contains(event.target) && !this.optionsTarget.classList.contains("hidden") ) {
      this.optionsTarget.classList.toggle('hidden');
    }
  }
}