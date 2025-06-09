import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sometest"
export default class extends Controller {
  connect() {
    console.log('connected!!!')
  }
}
