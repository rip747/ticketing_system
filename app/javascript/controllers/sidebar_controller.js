import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer", "collapseIcon"]

  connect() {
    // Restore collapsed state from localStorage
    if (localStorage.getItem("sidebar_collapsed") === "true") {
      this.drawerTarget.classList.add("collapsed")
      this.collapseIconTarget.classList.add("bi-chevron-right")
    }
  }

  toggle() {
    this.drawerTarget.classList.toggle("show")
  }

  close() {
    this.drawerTarget.classList.remove("show")
  }

  toggleCollapse() {
    // Don't toggle collapse on mobile view (when sidebar is an overlay)
    if (window.innerWidth < 768) return

    this.drawerTarget.classList.toggle("collapsed")
    let collasped = this.drawerTarget.classList.contains("collapsed")
    localStorage.setItem("sidebar_collapsed", collasped)
    if (collasped) {
      this.collapseIconTarget.classList.remove("bi-chevron-left")
      this.collapseIconTarget.classList.add("bi-chevron-right")
    } else {
      this.collapseIconTarget.classList.remove("bi-chevron-right")
      this.collapseIconTarget.classList.add("bi-chevron-left")
    }
  }

  closeOnBackdrop({ target }) {
    if (target === this.element) {
      this.close()
    }
  }
}


//bi-chevron-left