import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="itemized--grand-total"
export default class extends Controller {
  static targets = [
    'taxPercent', 'splitTax',
    'tipPercent', 'splitTip',
    'grandTotal', 'splitGrandTotal',
    'splitSubtotal'
  ]

  connect() {
  }

  calculate() {
    this.calculateTax()
    this.calculateTip()
    this.calculateGrandTotal()
  }

  calculateTax() {
    let taxPercent = Number(this.taxPercentTarget.value)

    if (typeof taxPercent == 'number'){
      for (let i = 0; i < this.splitSubtotalTargets.length; i++) {
        this.splitTaxTargets[i].innerHTML = ((taxPercent * Number(this.splitSubtotalTargets[i].innerHTML)) / 100).toFixed(2)
      }
    }
  }

  calculateTip() {
    let tipPercent = Number(this.tipPercentTarget.value)

    if (typeof tipPercent == 'number'){
      for (let i = 0; i < this.splitSubtotalTargets.length; i++) {
        this.splitTipTargets[i].innerHTML = ((tipPercent * Number(this.splitSubtotalTargets[i].innerHTML)) / 100).toFixed(2)
      }
    }
  }

  calculateGrandTotal() {
    let grandTotal = 0;
    let temp = 0;

    for (let i = 0; i < this.splitSubtotalTargets.length; i++) {
      temp = Number(this.splitSubtotalTargets[i].innerHTML) + Number(this.splitTaxTargets[i].innerHTML) + Number(this.splitTipTargets[i].innerHTML)
      grandTotal += temp

      this.splitGrandTotalTargets[i].innerHTML = temp.toFixed(2)
    }

    this.grandTotalTarget.innerHTML = grandTotal.toFixed(2)
  }

}
