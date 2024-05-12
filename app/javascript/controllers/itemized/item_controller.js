import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="itemized--item"
export default class extends Controller {
  static targets = ['itemCost', 'itemSplit']

  disconnect(){
    this.fireSplitChangeEvent()
  }

  calculateSplits() {
    let itemCost = Number(this.itemCostTarget.value) || 0
    let selectedSplits = this.selectedSplits()
    let selectedSplitsCount = selectedSplits.length
    let perSplitAmount = (itemCost / selectedSplitsCount).toFixed(2)

    selectedSplits[0].innerHTML = (itemCost - perSplitAmount * (selectedSplitsCount - 1)).toFixed(2)

    for (let i = 1; i < selectedSplitsCount; i++) {
      selectedSplits[i].innerHTML = perSplitAmount
    }

    this.fireSplitChangeEvent()
  }

  toggle(e) {
    if (e.target.dataset.state == 'unselected') {
      e.target.dataset.state = 'selected'
      e.target.classList.add("bg-gray-200")
    } else {
      e.target.dataset.state = 'unselected'
      e.target.classList.remove("bg-gray-200")
      e.target.innerHTML = ""
    }

    this.calculateSplits()
  }

  selectedSplits() {
    return this.itemSplitTargets.filter(target => (target.dataset.state != 'unselected'))
  }

  fireSplitChangeEvent() {
    const event = new CustomEvent("itemSplitChange")
    window.dispatchEvent(event);
  }
}
