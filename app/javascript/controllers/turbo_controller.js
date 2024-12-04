import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["temporary", "loading"]

  connect() {
    this.setupTurboListeners();
  }

  disconnect() {
    // Clean up if needed
  }

  setupTurboListeners() {
    document.addEventListener("turbo:before-visit", () => {
      // Show loading indicator, hide main content
      this.element.classList.add("loading");
    });

    document.addEventListener("turbo:load", () => {
      // Hide loading indicator, show main content
      this.element.classList.remove("loading");
      this.initializeComponents();
    });

    document.addEventListener("turbo:before-render", () => {
      // Fade out current page
      document.body.classList.add("opacity-0");
    });

    document.addEventListener("turbo:render", () => {
      // Fade in new page
      document.body.classList.remove("opacity-0");
    });

    document.addEventListener("turbo:before-cache", () => {
      // Clean up before page is cached
      this.cleanupComponents();
    });
  }

  initializeComponents() {
    // Add any initialization logic here
    console.log("Page loaded, initializing components...");
  }

  cleanupComponents() {
    // Add any cleanup logic here
    console.log("Cleaning up before caching...");
  }
}
