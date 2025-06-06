import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="enrollment"
export default class extends Controller {
  static targets = ["button", "status", "progress"]
  static values = { 
    courseId: Number,
    enrolled: Boolean,
    url: String
  }

  connect() {
    this.updateButtonState()
  }

  toggle(event) {
    event.preventDefault()
    
    if (this.enrolledValue) {
      this.unenroll()
    } else {
      this.enroll()
    }
  }

  async enroll() {
    this.setLoading(true)
    
    try {
      const response = await fetch(`/courses/${this.courseIdValue}/enroll`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html'
        }
      })
      
      if (response.ok) {
        this.enrolledValue = true
        this.updateButtonState()
        this.animateSuccess()
        
        // Show success message with option to start learning
        this.showSuccessWithStudyOption()
      } else {
        this.showError('Failed to enroll')
      }
    } catch (error) {
      this.showError('Network error')
    } finally {
      this.setLoading(false)
    }
  }

  async unenroll() {
    if (!confirm('Are you sure you want to unenroll from this course?')) {
      return
    }
    
    this.setLoading(true)
    
    try {
      const response = await fetch(`/courses/${this.courseIdValue}/unenroll`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html'
        }
      })
      
      if (response.ok) {
        this.enrolledValue = false
        this.updateButtonState()
        this.animateSuccess()
      } else {
        this.showError('Failed to unenroll')
      }
    } catch (error) {
      this.showError('Network error')
    } finally {
      this.setLoading(false)
    }
  }

  updateButtonState() {
    if (this.hasButtonTarget) {
      if (this.enrolledValue) {
        this.buttonTarget.textContent = 'Unenroll'
        this.buttonTarget.classList.remove('bg-blue-600', 'hover:bg-blue-700')
        this.buttonTarget.classList.add('bg-red-600', 'hover:bg-red-700')
      } else {
        this.buttonTarget.textContent = 'Enroll Now'
        this.buttonTarget.classList.remove('bg-red-600', 'hover:bg-red-700')
        this.buttonTarget.classList.add('bg-blue-600', 'hover:bg-blue-700')
      }
    }
  }

  setLoading(loading) {
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = loading
      this.buttonTarget.textContent = loading ? 'Processing...' : 
        (this.enrolledValue ? 'Unenroll' : 'Enroll Now')
    }
  }

  animateSuccess() {
    if (this.hasButtonTarget) {
      this.buttonTarget.classList.add('animate-pulse')
      setTimeout(() => {
        this.buttonTarget.classList.remove('animate-pulse')
      }, 1000)
    }
  }

  showError(message) {
    // Create a temporary error message
    const errorDiv = document.createElement('div')
    errorDiv.className = 'fixed top-4 right-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded z-50'
    errorDiv.textContent = message
    document.body.appendChild(errorDiv)
    
      setTimeout(() => {
        errorDiv.remove()
      }, 3000)
  }
  
  showSuccessWithStudyOption() {
    // Create success notification with study link
    const successDiv = document.createElement('div')
    successDiv.className = 'fixed top-4 right-4 bg-white border border-green-200 rounded-lg shadow-lg p-4 z-50 max-w-sm'
    successDiv.innerHTML = `
      <div class="flex items-start space-x-3">
        <div class="flex-shrink-0">
          <svg class="w-6 h-6 text-green-500" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
          </svg>
        </div>
        <div class="flex-1">
          <h3 class="text-sm font-medium text-gray-900">Successfully enrolled!</h3>
          <p class="text-sm text-gray-600 mt-1">Ready to start your learning journey?</p>
          <div class="mt-3 flex space-x-2">
            <a href="/study" class="inline-flex items-center px-3 py-1.5 bg-blue-600 text-white text-xs font-medium rounded hover:bg-blue-700 transition-colors">
              Start Learning
            </a>
            <button onclick="this.closest('.fixed').remove()" class="inline-flex items-center px-3 py-1.5 bg-gray-100 text-gray-700 text-xs font-medium rounded hover:bg-gray-200 transition-colors">
              Later
            </button>
          </div>
        </div>
        <button onclick="this.closest('.fixed').remove()" class="flex-shrink-0 text-gray-400 hover:text-gray-600">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path>
          </svg>
        </button>
      </div>
    `
    document.body.appendChild(successDiv)
    
    // Auto-remove after 8 seconds
    setTimeout(() => {
      if (successDiv && successDiv.parentNode) {
        successDiv.remove()
      }
    }, 8000)
  }
}

