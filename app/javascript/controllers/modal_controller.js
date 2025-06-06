import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["content", "backdrop"]
  static classes = ["open"]
  static values = {
    closable: { type: Boolean, default: true },
    closeOnBackdrop: { type: Boolean, default: true },
    closeOnEscape: { type: Boolean, default: true }
  }

  connect() {
    this.isOpen = false
    
    // Bind event handlers
    this.escapeHandler = this.handleEscape.bind(this)
    this.backdropHandler = this.handleBackdrop.bind(this)
    
    // Set up ARIA attributes
    this.element.setAttribute('role', 'dialog')
    this.element.setAttribute('aria-modal', 'true')
    this.element.setAttribute('aria-hidden', 'true')
    
    // Initially hide the modal
    this.close()
  }

  disconnect() {
    this.removeEventListeners()
    // Restore body scroll
    document.body.classList.remove('overflow-hidden')
  }

  open(event) {
    if (event) {
      event.preventDefault()
    }
    
    this.isOpen = true
    this.element.classList.remove('hidden')
    this.element.setAttribute('aria-hidden', 'false')
    
    // Prevent body scroll
    document.body.classList.add('overflow-hidden')
    
    // Add event listeners
    this.addEventListeners()
    
    // Focus management
    this.focusFirstElement()
    
    // Animation
    requestAnimationFrame(() => {
      this.element.classList.add('opacity-100')
      if (this.hasBackdropTarget) {
        this.backdropTarget.classList.add('opacity-100')
      }
      if (this.hasContentTarget) {
        this.contentTarget.classList.remove('scale-95')
        this.contentTarget.classList.add('scale-100')
      }
    })
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }
    
    if (!this.closableValue && event) {
      return
    }
    
    this.isOpen = false
    
    // Animation out
    this.element.classList.remove('opacity-100')
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove('opacity-100')
    }
    if (this.hasContentTarget) {
      this.contentTarget.classList.add('scale-95')
      this.contentTarget.classList.remove('scale-100')
    }
    
    // Hide after animation
    setTimeout(() => {
      this.element.classList.add('hidden')
      this.element.setAttribute('aria-hidden', 'true')
      
      // Restore body scroll
      document.body.classList.remove('overflow-hidden')
      
      // Remove event listeners
      this.removeEventListeners()
    }, 200)
  }

  toggle(event) {
    if (this.isOpen) {
      this.close(event)
    } else {
      this.open(event)
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape' && this.closeOnEscapeValue) {
      this.close()
    }
  }

  handleBackdrop(event) {
    if (event.target === this.element && this.closeOnBackdropValue) {
      this.close()
    }
  }

  addEventListeners() {
    if (this.closeOnEscapeValue) {
      document.addEventListener('keydown', this.escapeHandler)
    }
    if (this.closeOnBackdropValue) {
      this.element.addEventListener('click', this.backdropHandler)
    }
  }

  removeEventListeners() {
    document.removeEventListener('keydown', this.escapeHandler)
    this.element.removeEventListener('click', this.backdropHandler)
  }

  focusFirstElement() {
    const focusableElements = this.element.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )
    
    if (focusableElements.length > 0) {
      focusableElements[0].focus()
    }
  }

  // Action methods for different use cases
  openModal(event) {
    this.open(event)
  }

  closeModal(event) {
    this.close(event)
  }

  submitAndClose(event) {
    // Allow form submission to complete, then close modal
    setTimeout(() => {
      this.close()
    }, 100)
  }
}

