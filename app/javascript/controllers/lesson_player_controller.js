import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lesson-player"
export default class extends Controller {
  static targets = ["videoPlayer", "iframe", "progressBar", "progressText", "completeButton"]
  static values = { enrollmentId: Number, lessonId: Number }

  connect() {
    this.progressInterval = null
    this.lastUpdateTime = 0
    
    // Setup video player if present
    if (this.hasVideoPlayerTarget) {
      this.setupVideoPlayer()
    }
    
    // Setup iframe tracking if present
    if (this.hasIframeTarget) {
      this.setupIframeTracking()
    }
  }

  disconnect() {
    if (this.progressInterval) {
      clearInterval(this.progressInterval)
    }
  }

  setupVideoPlayer() {
    const video = this.videoPlayerTarget
    
    video.addEventListener('loadedmetadata', () => {
      console.log('Video duration:', video.duration)
    })
    
    video.addEventListener('play', () => {
      console.log('Video started playing')
    })
    
    video.addEventListener('pause', () => {
      console.log('Video paused')
    })
  }

  setupIframeTracking() {
    // For iframe content (like YouTube), we'll use a timer-based approach
    // since we can't directly access the iframe content
    this.startProgressTimer()
  }

  updateProgress(event) {
    if (!this.hasVideoPlayerTarget) return
    
    const video = this.videoPlayerTarget
    const progress = (video.currentTime / video.duration) * 100
    
    // Throttle updates to avoid too many API calls
    const now = Date.now()
    if (now - this.lastUpdateTime < 5000) return // Update every 5 seconds
    
    this.lastUpdateTime = now
    this.updateProgressUI(progress)
    this.saveProgress(progress)
  }

  videoEnded(event) {
    console.log('Video ended')
    this.updateProgressUI(100)
    this.saveProgress(100)
    
    // Auto-complete lesson when video ends
    if (this.hasCompleteButtonTarget && !this.completeButtonTarget.disabled) {
      this.completeLesson()
    }
  }

  completeLesson(event) {
    if (event) event.preventDefault()
    
    const button = this.completeButtonTarget
    if (button.disabled) return
    
    button.disabled = true
    button.innerHTML = '<svg class="w-5 h-5 mr-2 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="m4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>Completing...'
    
    fetch(`/study/${this.enrollmentIdValue}/lessons/${this.lessonIdValue}/complete`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        button.innerHTML = '<svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>Completed'
        button.classList.remove('bg-green-600', 'hover:bg-green-700')
        button.classList.add('bg-gray-400')
        
        // Update progress UI
        this.updateProgressUI(100)
        
        // Show success message
        this.showSuccessMessage('Lesson completed!')
        
        // Auto-navigate to next lesson after 2 seconds if available
        if (data.next_lesson_id) {
          setTimeout(() => {
            window.location.href = `/study/${this.enrollmentIdValue}/lessons/${data.next_lesson_id}`
          }, 2000)
        }
      } else {
        button.disabled = false
        button.innerHTML = 'Mark as Complete'
        this.showErrorMessage(data.error || 'Failed to complete lesson')
      }
    })
    .catch(error => {
      console.error('Error completing lesson:', error)
      button.disabled = false
      button.innerHTML = 'Mark as Complete'
      this.showErrorMessage('Network error. Please try again.')
    })
  }

  saveProgress(progress) {
    fetch(`/study/${this.enrollmentIdValue}/lessons/${this.lessonIdValue}/progress`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ progress: progress })
    })
    .then(response => response.json())
    .then(data => {
      if (!data.success) {
        console.error('Failed to save progress:', data.error)
      }
    })
    .catch(error => {
      console.error('Error saving progress:', error)
    })
  }

  updateProgressUI(progress) {
    const roundedProgress = Math.round(progress)
    
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${roundedProgress}%`
    }
    
    if (this.hasProgressTextTarget) {
      this.progressTextTarget.textContent = `${roundedProgress}%`
    }
  }

  startProgressTimer() {
    // For iframe content, simulate progress based on time spent
    let timeSpent = 0
    const estimatedDuration = 600 // 10 minutes default
    
    this.progressInterval = setInterval(() => {
      timeSpent += 1
      const progress = Math.min((timeSpent / estimatedDuration) * 100, 95) // Cap at 95% until manually completed
      
      this.updateProgressUI(progress)
      
      // Save progress every 30 seconds
      if (timeSpent % 30 === 0) {
        this.saveProgress(progress)
      }
    }, 1000)
  }

  showSuccessMessage(message) {
    this.showMessage(message, 'success')
  }

  showErrorMessage(message) {
    this.showMessage(message, 'error')
  }

  showMessage(message, type) {
    // Create a toast notification
    const toast = document.createElement('div')
    toast.className = `fixed top-4 right-4 px-6 py-3 rounded-lg shadow-lg z-50 transition-all duration-300 transform translate-x-full ${
      type === 'success' ? 'bg-green-500 text-white' : 'bg-red-500 text-white'
    }`
    toast.textContent = message
    
    document.body.appendChild(toast)
    
    // Animate in
    setTimeout(() => {
      toast.classList.remove('translate-x-full')
    }, 100)
    
    // Remove after 3 seconds
    setTimeout(() => {
      toast.classList.add('translate-x-full')
      setTimeout(() => {
        document.body.removeChild(toast)
      }, 300)
    }, 3000)
  }
}

