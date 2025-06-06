import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="video-upload"
export default class extends Controller {
  static targets = [
    "fileInput", "dropzone", "uploadPrompt", "uploadProgress", 
    "filePreview", "fileName", "fileSize", "progressBar",
    "videoSection", "textSection", "otherSection"
  ]
  
  static values = {
    maxSize: Number
  }

  connect() {
    this.allowedTypes = ['video/mp4', 'video/webm', 'video/ogg', 'video/avi', 'video/mov', 'video/wmv']
    
    // Initialize the form state based on current content type
    this.initializeContentFields()
  }
  
  initializeContentFields() {
    const contentTypeSelect = this.element.querySelector('select[name*="content_type"]')
    if (contentTypeSelect) {
      this.toggleContentFields({ target: contentTypeSelect })
    }
  }

  selectFile() {
    this.fileInputTarget.click()
  }

  handleFileSelect(event) {
    const file = event.target.files[0]
    if (file) {
      this.processFile(file)
    }
  }

  handleDragEnter(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.add('border-blue-400', 'bg-blue-50')
  }

  handleDragLeave(event) {
    event.preventDefault()
    // Only remove styles if we're leaving the dropzone entirely
    if (!this.dropzoneTarget.contains(event.relatedTarget)) {
      this.dropzoneTarget.classList.remove('border-blue-400', 'bg-blue-50')
    }
  }

  handleDragOver(event) {
    event.preventDefault()
  }

  handleDrop(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.remove('border-blue-400', 'bg-blue-50')
    
    const files = Array.from(event.dataTransfer.files)
    const videoFile = files.find(file => this.allowedTypes.includes(file.type))
    
    if (videoFile) {
      this.processFile(videoFile)
      // Set the file input
      const dt = new DataTransfer()
      dt.items.add(videoFile)
      this.fileInputTarget.files = dt.files
    } else {
      this.showError('Please select a valid video file (MP4, WebM, OGG, AVI, MOV, WMV)')
    }
  }

  processFile(file) {
    // Validate file type
    if (!this.allowedTypes.includes(file.type)) {
      this.showError('Invalid file type. Please select a video file.')
      return
    }

    // Validate file size
    if (file.size > this.maxSizeValue) {
      this.showError(`File too large. Maximum size is ${this.formatFileSize(this.maxSizeValue)}.`)
      return
    }

    // Show file preview
    this.showFilePreview(file)
  }

  showFilePreview(file) {
    this.fileNameTarget.textContent = file.name
    this.fileSizeTarget.textContent = this.formatFileSize(file.size)
    
    this.uploadPromptTarget.classList.add('hidden')
    this.filePreviewTarget.classList.remove('hidden')
  }

  removeFile() {
    this.fileInputTarget.value = ''
    this.uploadPromptTarget.classList.remove('hidden')
    this.filePreviewTarget.classList.add('hidden')
    this.uploadProgressTarget.classList.add('hidden')
  }

  toggleContentFields(event) {
    const contentType = event.target.value
    
    // Hide all sections first
    if (this.hasVideoSectionTarget) {
      this.videoSectionTarget.style.display = 'none'
    }
    if (this.hasTextSectionTarget) {
      this.textSectionTarget.style.display = 'none'
    }
    if (this.hasOtherSectionTarget) {
      this.otherSectionTarget.style.display = 'none'
    }
    
    // Show relevant section
    switch (contentType) {
      case 'video':
        if (this.hasVideoSectionTarget) {
          this.videoSectionTarget.style.display = 'block'
        }
        break
      case 'text':
        if (this.hasTextSectionTarget) {
          this.textSectionTarget.style.display = 'block'
        }
        break
      case 'audio':
      case 'quiz':
        if (this.hasOtherSectionTarget) {
          this.otherSectionTarget.style.display = 'block'
        }
        break
    }
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  showError(message) {
    // Create or update error message
    let errorDiv = this.element.querySelector('.video-upload-error')
    
    if (!errorDiv) {
      errorDiv = document.createElement('div')
      errorDiv.className = 'video-upload-error bg-red-50 border border-red-200 rounded-md p-4 mt-4'
      errorDiv.innerHTML = `
        <div class="flex">
          <div class="flex-shrink-0">
            <svg class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
            </svg>
          </div>
          <div class="ml-3">
            <p class="text-sm text-red-700 error-message"></p>
          </div>
          <div class="ml-auto pl-3">
            <button type="button" class="text-red-400 hover:text-red-600 close-error">
              <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
          </div>
        </div>
      `
      this.dropzoneTarget.parentNode.appendChild(errorDiv)
      
      // Add close functionality
      errorDiv.querySelector('.close-error').addEventListener('click', () => {
        errorDiv.remove()
      })
    }
    
    errorDiv.querySelector('.error-message').textContent = message
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
      if (errorDiv.parentNode) {
        errorDiv.remove()
      }
    }, 5000)
  }
}

