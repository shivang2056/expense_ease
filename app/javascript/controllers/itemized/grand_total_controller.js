import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="itemized--grand-total"
export default class extends Controller {
  static targets = [
    'taxPercent', 'splitTax',
    'taxCost', 'splitTaxAmount',
    'tipPercent', 'splitTip',
    'tipCost', 'splitTipAmount',
    'grandTotal', 'splitGrandTotal',
    'splitSubtotal'
  ]

  connect() {
  }

  calculate() {
    this.calculateTax()
    this.calculateTip()
    this.calculateGrandTotal()
    this.fireGrandTotalChangeEvent()
  }

  calculateTax() {
    let taxPercent = Number(this.taxPercentTarget.value)
    let sum = 0

    if (typeof taxPercent == 'number'){
      for (let i = 0; i < this.splitSubtotalTargets.length; i++) {
        let splitTaxAmount = ((taxPercent * Number(this.splitSubtotalTargets[i].innerHTML)) / 100)

        sum += splitTaxAmount
        this.splitTaxTargets[i].innerHTML = splitTaxAmount.toFixed(2)
        this.splitTaxAmountTargets[i].value = splitTaxAmount.toFixed(2)
      }

      this.taxCostTarget.value = sum
    }
  }

  calculateTip() {
    let tipPercent = Number(this.tipPercentTarget.value)
    let sum = 0

    if (typeof tipPercent == 'number'){
      for (let i = 0; i < this.splitSubtotalTargets.length; i++) {
        let splitTipAmount = ((tipPercent * Number(this.splitSubtotalTargets[i].innerHTML)) / 100)

        sum += splitTipAmount
        this.splitTipTargets[i].innerHTML = splitTipAmount.toFixed(2)
        this.splitTipAmountTargets[i].value = splitTipAmount.toFixed(2)
      }

      this.tipCostTarget.value = sum
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

  fireGrandTotalChangeEvent() {
    const event = new CustomEvent("grandTotalChange")
    window.dispatchEvent(event);
  }

}
