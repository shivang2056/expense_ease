import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="item-form"
export default class extends Controller {
  static targets = ['newItemLocation', 'formTemplate'];
  static values = { formSelector: { type: String } };

  addItem() {
    const content = this.formTemplateTarget.innerHTML.replace(
      /NEW_RECORD/g,
      new Date().getTime().toString()
    );

    this.newItemLocationTarget.insertAdjacentHTML("beforebegin", content);
  }

  removeItem(e) {
    const wrapper = e.target.closest(this.formSelectorValue)

    wrapper.remove()
  }
}
