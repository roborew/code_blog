import { Controller } from "@hotwired/stimulus";
import "@yaireo/tagify/dist/tagify.css";
import Tagify from "@yaireo/tagify";

export default class extends Controller {
  static targets = ["categories"];
  static values = { article: String };

  connect() {
    const element = this.categoriesTarget;
    let defaultCategory = [];
    console.log(this.articleValue);
    if (this.articleValue) {
      defaultCategory = this.articleValue;
      element.value = this.articleValue;
    }

    // Fetch initial categories before initializing Tagify
    fetch("/categories/search")
      .then((response) => response.json())
      .then((initialCategories) => {
        this.tagify = new Tagify(element, {
          whitelist: initialCategories,
          tags: defaultCategory,
          enforceWhitelist: false,
          skipInvalid: false,
          maxTags: 1,
          mode: "select",
          blacklist: ["Porn", "Sex", "Nudity", "Violence", "Dangerous Content"],
          dropdown: {
            enabled: 0,
            maxItems: 10,
            classname: "tags-look",
            closeOnSelect: true,
          },
          templates: {
            dropdownItemNoMatch: function (data) {
              return `Create New Category: ${data.value}`;
            },
          },
        });

        // Add custom key binding for Tab
        this.tagify.DOM.input.addEventListener("keydown", (e) => {
          const inputValue = this.tagify.DOM.input.textContent; // Changed this line
          if (e.key === "Tab" && inputValue) {
            this.tagify.addTags([inputValue]); // Wrap in array to ensure proper handling
            this.tagify.DOM.input.textContent = ""; // Clear the input
            this.tagify.dropdown.hide(); // Hide dropdown after adding
          }
        });

        // Handle tag suggestions as user types
        let timeout;
        this.tagify.on("input", (e) => {
          const value = e.detail.value;
          this.tagify.whitelist = null;
          clearTimeout(timeout);
          this.tagify.loading(true);
          // Debounce the API call by 300ms
          timeout = setTimeout(() => {
            fetch(`/categories/search?q=${value}`)
              .then((response) => response.json())
              .then((suggestions) => {
                this.tagify.whitelist = suggestions;
                this.tagify.loading(false);
                this.tagify.dropdown.show(value);
              });
          }, 300);
        });
      });
  }
}
