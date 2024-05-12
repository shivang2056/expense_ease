import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="split-by-accordion"
export default class extends Controller {
  static targets = [
    'splitByMethod', 'cost',
    'participantsIds', 'accordionElement',
    'title', 'body','svgIndicator',
    'grandTotal'
  ];

  connect() {
  }

  setTitle() {
    this.titleTarget.innerHTML = this.splitByMethodTarget.innerHTML;
  }

  setCost() {
    if (this.hasGrandTotalTarget) {
      this.costTarget.value = Number(this.grandTotalTarget.innerHTML).toFixed(2)
    }
  }

  toggle() {
    this.bodyTarget.classList.toggle('hidden');
    this.accordionElementTarget.classList.toggle('text-gray-900');
    this.svgIndicatorTarget.classList.toggle('rotate-180');
  }
  reload() {
    let frame = this.bodyTarget.querySelector('turbo-frame#split_by_accordion_body');
    let participantIds = this.participantsIdsTarget.value;
    let cost = this.costTarget.value;
    let splitByMethod = this.splitByMethodTarget.value;

    if (cost == '999') {
      frame.src = `/expenses/new?cost=${cost}&participant_ids=${participantIds}&split_by=${splitByMethod}`
    }
  }
}
