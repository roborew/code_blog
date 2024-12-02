import { Controller } from "@hotwired/stimulus";
import { Crepe } from "@milkdown/crepe";
import { listener, listenerCtx } from "@milkdown/kit/plugin/listener";
import { imageBlockConfig } from "@milkdown/kit/component/image-block";

import "@milkdown/crepe/theme/common/style.css";
import "@milkdown/crepe/theme/frame.css";

export default class extends Controller {
  static targets = ["editor", "content"];

  connect() {
    let jsonOutput = "";
    const editor = this.editorTarget;
    const form = this.element.closest("form");

    if (form) {
      // Prevent form from submitting when clicking on the editor.
      this.editorTarget.addEventListener("mouseup", (e) => e.preventDefault());
      // this.editorTarget.addEventListener("click", (e) => e.preventDefault());
    }
    // Initialize the editor.
    this.contentEditor = new Crepe({
      root: editor,
      defaultValue: this.contentTarget.value,
    });
    // Create the editor.
    this.contentEditor.create().then(() => {
      console.log("Editor created");
    });
    // Listen for changes in the editor inorder to update the content field
    this.contentEditor.editor
      .config((ctx) => {
        ctx.get(listenerCtx).updated((ctx, doc, prevDoc) => {
          if (doc !== prevDoc) {
            // Set content to be updated.
            this.setContent(this.contentEditor.getMarkdown());
          }
        });
      })
      .use(listener);

    this.contentEditor.editor.config((ctx) => {
      ctx.update(imageBlockConfig.key, (defaultConfig) => ({
        ...defaultConfig,
        onUpload: async (file) => {
          const formData = new FormData();
          formData.append("file", file);

          const csrfToken = document
            .querySelector('meta[name="csrf-token"]')
            ?.getAttribute("content");

          try {
            const response = await fetch("/uploads/upload_image", {
              method: "POST",
              headers: {
                "X-CSRF-Token": csrfToken,
              },
              body: formData,
            });

            if (!response.ok) {
              throw new Error(`Upload failed: ${response.statusText}`);
            }

            const data = await response.json();
            console.log("Data", data);

            // Simply return the URL as per the documentation
            return data.url;
          } catch (error) {
            console.error("Upload error:", error);
            return null;
          }
        },
      }));
    });
  }
  disconnect() {
    if (this.contentEditor) {
      this.contentEditor.destroy();
    }
  }

  setContent(content) {
    this.contentTarget.value = content;
    console.log("Content updated:");
  }
}
