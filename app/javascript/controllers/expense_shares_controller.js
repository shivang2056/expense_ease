import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="expense-shares"
export default class extends Controller {
  static targets = ['amountDisplayValue', 'amountValue', 'shareCount'];

  static values = { totalAmount: Number };
  connect() {
  }

  calculateShares() {
    let totalParticpants = this.shareCountTargets.length;
    let totalShares = this.shareCountTargets.reduce(function(total, shareCountTarget) {
                        return total + Number(shareCountTarget.value);
                      }, 0);
    let singleShareAmount = this.totalAmountValue / totalShares;


    for (let i = 0; i < totalParticpants; i++) {
      let shareAmount = (Number(this.shareCountTargets[i].value) * singleShareAmount).toFixed(2);

      this.amountDisplayValueTargets[i].innerHTML = `$${shareAmount}`
      this.amountValueTargets[i].value = shareAmount;
    }
  }
}
