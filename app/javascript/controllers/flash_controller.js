import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  static values = { 
    dismissAfter: Number,
    autoHide: Boolean
  }

  connect() {
    if (this.autoHideValue) {
      this.scheduleHide()
    }
    
    // Add entrance animation
    this.element.classList.add('transform', 'translate-x-full')
    requestAnimationFrame(() => {
      this.element.classList.remove('translate-x-full')
      this.element.classList.add('translate-x-0')
    })
  }

  dismiss(event) {
    event.preventDefault()
    this.hide()
  }

  hide() {
    // Add exit animation
    this.element.classList.add('transform', 'translate-x-full', 'opacity-0')
    
    setTimeout(() => {
      if (this.element.parentNode) {
        this.element.remove()
      }
    }, 300)
  }

  scheduleHide() {
    const delay = this.dismissAfterValue || 5000
    
    setTimeout(() => {
      this.hide()
    }, delay)
  }

  // Pause auto-hide on hover
  pauseHide() {
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
    }
  }

  // Resume auto-hide when not hovering
  resumeHide() {
    if (this.autoHideValue) {
      this.scheduleHide()
    }
  }
}

