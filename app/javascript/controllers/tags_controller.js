import { Controller } from "@hotwired/stimulus";
import Tagify from "@yaireo/tagify";
import "@yaireo/tagify/dist/tagify.css";
export default class extends Controller {
  static targets = ["tagsInput"];
  static values = { article: Array };

  connect() {
    const element = this.tagsInputTarget;
    // Use the article data from the data attribute
    const defaultTags = this.articleValue.map((tag) => tag.name);

    element.value = defaultTags.join(",");

    this.tagify = new Tagify(this.tagsInputTarget, {
      tags: defaultTags,
      enforceWhitelist: false,
      skipInvalid: false,
      dropdown: {
        enabled: 0,
        maxItems: 10,
        classname: "tags-look",
        closeOnSelect: true,
      },
      templates: {
        dropdownItemNoMatch: function (data) {
          return `Create New Tag: ${data.value}`;
        },
      },
    });

    // Add custom key binding for Tab
    this.tagify.DOM.input.addEventListener("keydown", (e) => {
      const inputValue = this.tagify.DOM.input.textContent; // Changed this line
      if (e.key === "Tab" && inputValue) {
        e.preventDefault(); // Prevent moving to next field
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
        fetch(`/tags/search?q=${value}`)
          .then((response) => response.json())
          .then((suggestions) => {
            this.tagify.whitelist = suggestions;
            this.tagify.loading(false);
            this.tagify.dropdown.show(value);
          });
      }, 300);
    });
  }
  handleKeyUp() {
    const element = this.tagsInputTarget;
    const name = element.value;
  }
}
