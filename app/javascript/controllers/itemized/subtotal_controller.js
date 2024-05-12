import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="itemized--subtotal"
export default class extends Controller {
  static values = { userCount: { type: Number } };
  static targets = ['itemSplit', 'subTotal', 'splitTotal'];

  calculate() {
    let subTotal = 0
    let splitTotals = new Array(this.userCountValue).fill(0)

    for (let i = 0; i < this.itemSplitTargets.length; i++) {
      subTotal += this.itemSplitAmount(i)

      splitTotals[i % this.userCountValue] += this.itemSplitAmount(i)
    }

    this.subTotalTarget.innerHTML = subTotal.toFixed(2)

    for (let i = 0; i < splitTotals.length; i++) {
      this.splitTotalTargets[i].innerHTML = splitTotals[i].toFixed(2)
    }

    this.fireSubTotalChangeEvent()
  }

  itemSplitAmount(i) {
    return Number(this.itemSplitTargets[i].innerHTML) || 0
  }

  fireSubTotalChangeEvent() {
    const event = new CustomEvent("subTotalChange")
    window.dispatchEvent(event);
  }
}
