import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-menu"
export default class extends Controller {
  static targets = ["menu", "overlay"]
  static classes = ["open"]

  connect() {
    this.isOpen = false
  }

  toggle(event) {
    event.preventDefault()
    
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.isOpen = true
    
    // Show overlay
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("hidden")
    }
    
    // Animate menu
    this.menuTarget.classList.remove("-translate-x-full")
    this.menuTarget.classList.add("translate-x-0")
    
    // Prevent body scroll
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.isOpen = false
    
    // Hide overlay
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("hidden")
    }
    
    // Animate menu
    this.menuTarget.classList.add("-translate-x-full")
    this.menuTarget.classList.remove("translate-x-0")
    
    // Allow body scroll
    document.body.classList.remove("overflow-hidden")
  }

  overlayClick(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }
}

