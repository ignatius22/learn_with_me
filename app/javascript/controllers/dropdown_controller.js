import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]
  static classes = ["hidden"]

  connect() {
    this.isOpen = false
    // Close dropdown when clicking outside
    this.outsideClickHandler = this.outsideClick.bind(this)
    document.addEventListener("click", this.outsideClickHandler)
    console.log('connected')
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClickHandler)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    this.menuTarget.classList.add("block")
    this.isOpen = true
    
    // Add animation
    this.menuTarget.style.opacity = "0"
    this.menuTarget.style.transform = "scale(0.95)"
    
    requestAnimationFrame(() => {
      this.menuTarget.style.transition = "opacity 100ms ease-out, transform 100ms ease-out"
      this.menuTarget.style.opacity = "1"
      this.menuTarget.style.transform = "scale(1)"
    })
  }

  close() {
    this.menuTarget.style.opacity = "0"
    this.menuTarget.style.transform = "scale(0.95)"
    
    setTimeout(() => {
      this.menuTarget.classList.add("hidden")
      this.menuTarget.classList.remove("block")
      this.isOpen = false
    }, 100)
  }

  outsideClick(event) {
    if (this.isOpen && !this.element.contains(event.target)) {
      this.close()
    }
  }
}

