import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="json-editor"
export default class extends Controller {
  static targets = ["input", "error"];

  connect() {
    this.format();
  }

  format() {
    try {
      const parsed = JSON.parse(this.inputTarget.value);
      this.inputTarget.value = JSON.stringify(parsed, null, 2);
      this.errorTarget.textContent = "";
    } catch (e) {
      this.errorTarget.textContent = "Invalid JSON";
    }
  }
}
