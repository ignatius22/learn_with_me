import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="video-upload-test"
export default class extends Controller {
  static targets = ["submitButton", "results", "statusContainer", "statusButton"]
  
  connect() {
    this.currentLessonId = null
  }

  uploadTest(event) {
    event.preventDefault()
    
    const form = event.target
    const formData = new FormData(form)
    
    // Disable submit button and show loading state
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.textContent = "Uploading..."
    
    // Show results container
    this.resultsTarget.classList.remove("hidden")
    this.resultsTarget.className = "mt-6 p-4 rounded-md bg-blue-50 border border-blue-200"
    this.resultsTarget.innerHTML = `
      <div class="flex items-center">
        <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600 mr-3"></div>
        <p class="text-blue-800">Uploading video...</p>
      </div>
    `
    
    // Submit form via fetch
    fetch(form.action, {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      this.handleUploadResponse(data)
    })
    .catch(error => {
      this.handleUploadError(error)
    })
    .finally(() => {
      // Re-enable submit button
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.textContent = "Upload Test Video"
    })
  }
  
  handleUploadResponse(data) {
    if (data.status === 'success') {
      this.currentLessonId = data.lesson_id
      
      this.resultsTarget.className = "mt-6 p-4 rounded-md bg-green-50 border border-green-200"
      this.resultsTarget.innerHTML = `
        <div class="text-green-800">
          <h3 class="font-medium mb-2">✅ Upload Successful!</h3>
          <ul class="text-sm space-y-1">
            <li><strong>Lesson ID:</strong> ${data.lesson_id}</li>
            <li><strong>File Size:</strong> ${this.formatFileSize(data.file_size)}</li>
            <li><strong>Video URL:</strong> <a href="${data.video_url}" target="_blank" class="underline">View Video</a></li>
            ${data.thumbnail_url ? `<li><strong>Thumbnail:</strong> <a href="${data.thumbnail_url}" target="_blank" class="underline">View Thumbnail</a></li>` : ''}
            ${data.duration ? `<li><strong>Duration:</strong> ${data.duration} seconds</li>` : '<li class="text-yellow-600">⏳ Duration processing...</li>'}
          </ul>
          <p class="mt-2 text-sm">Background processing may still be in progress for thumbnail generation and metadata extraction.</p>
        </div>
      `
      
      // Show status checking button
      this.statusButtonTarget.classList.remove("hidden")
      
    } else {
      this.resultsTarget.className = "mt-6 p-4 rounded-md bg-red-50 border border-red-200"
      this.resultsTarget.innerHTML = `
        <div class="text-red-800">
          <h3 class="font-medium mb-2">❌ Upload Failed</h3>
          <ul class="text-sm space-y-1">
            ${data.errors.map(error => `<li>• ${error}</li>`).join('')}
          </ul>
        </div>
      `
    }
  }
  
  handleUploadError(error) {
    console.error('Upload error:', error)
    this.resultsTarget.className = "mt-6 p-4 rounded-md bg-red-50 border border-red-200"
    this.resultsTarget.innerHTML = `
      <div class="text-red-800">
        <h3 class="font-medium mb-2">❌ Upload Error</h3>
        <p class="text-sm">An unexpected error occurred: ${error.message}</p>
      </div>
    `
  }
  
  clearResults() {
    this.resultsTarget.classList.add("hidden")
    this.statusContainerTarget.innerHTML = '<p class="text-gray-500">Upload a video to see processing status...</p>'
    this.statusButtonTarget.classList.add("hidden")
    this.currentLessonId = null
    
    // Reset form
    this.element.querySelector('form').reset()
  }
  
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }
}

