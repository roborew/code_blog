import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button"];
  async copy(event) {
    const button = event.currentTarget;
    const code = atob(button.dataset.code);

    try {
      await navigator.clipboard.writeText(code);
      // Visual feedback
      const originalText = button.textContent;
      button.textContent = "Copied!";

      setTimeout(() => {
        button.textContent = originalText;
      }, 2000);
    } catch (err) {
      console.error("Failed to copy code:", err);
      button.textContent = "Failed to copy";

      setTimeout(() => {
        button.textContent = "Copy";
      }, 2000);
    }
  }
}
