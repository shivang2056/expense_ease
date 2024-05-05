import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="expense-participants"
export default class extends Controller {

  static targets = ['participantsIds'];

  connect() {
  }

  storeUserId(e) {
    this.participantsIdsTarget.value = this.participantsIdsTarget.value.concat(",", e.params.userId);
    this.participantsIdsTarget.dispatchEvent(new Event('change'));
  }
}
