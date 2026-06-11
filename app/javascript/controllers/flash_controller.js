import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 5000 } }

  connect() {
    this.startTimer()
  }

  disconnect() {
    this.stopTimer()
  }

  startTimer() {
    this.stopTimer()
    this.timer = setTimeout(() => this.dismiss(), this.delayValue)
  }

  stopTimer() {
    if (this.timer) {
      clearTimeout(this.timer)
      this.timer = null
    }
  }

  pause() {
    this.stopTimer()
  }

  resume() {
    this.startTimer()
  }

  dismiss() {
    this.element.querySelector(".btn-close")?.click()
  }
}
