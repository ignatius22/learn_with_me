import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="progress"
export default class extends Controller {
  static targets = ["bar", "percentage", "text"]
  static values = { 
    current: Number,
    total: Number,
    animated: Boolean
  }

  connect() {
    this.updateProgress()
    if (this.animatedValue) {
      this.animateProgress()
    }
  }

  updateProgress() {
    const percentage = this.calculatePercentage()
    
    if (this.hasBarTarget) {
      this.barTarget.style.width = `${percentage}%`
      this.barTarget.setAttribute('aria-valuenow', percentage)
    }
    
    if (this.hasPercentageTarget) {
      this.percentageTarget.textContent = `${Math.round(percentage)}%`
    }
    
    if (this.hasTextTarget) {
      this.textTarget.textContent = `${this.currentValue} of ${this.totalValue} completed`
    }
  }

  calculatePercentage() {
    if (this.totalValue === 0) return 0
    return (this.currentValue / this.totalValue) * 100
  }

  animateProgress() {
    if (this.hasBarTarget) {
      this.barTarget.style.width = '0%'
      
      setTimeout(() => {
        this.barTarget.style.transition = 'width 1s ease-in-out'
        this.updateProgress()
      }, 100)
    }
  }

  increment(event) {
    event.preventDefault()
    this.currentValue = Math.min(this.currentValue + 1, this.totalValue)
    this.updateProgress()
  }

  decrement(event) {
    event.preventDefault()
    this.currentValue = Math.max(this.currentValue - 1, 0)
    this.updateProgress()
  }

  currentValueChanged() {
    this.updateProgress()
  }

  totalValueChanged() {
    this.updateProgress()
  }
}

