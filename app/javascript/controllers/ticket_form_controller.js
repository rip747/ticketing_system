import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "error"];

  submit(event) {
    event.preventDefault();
    fetch(this.formTarget.action, {
      method: "POST",
      body: new FormData(this.formTarget),
      headers: { "Accept": "text/vnd.turbo-stream.html" }
    })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
      .catch(error => {
        this.errorTarget.textContent = "Failed to submit ticket";
        console.error(error);
      });
  }
}
