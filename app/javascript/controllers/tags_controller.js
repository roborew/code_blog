import { Controller } from "@hotwired/stimulus";
import Tagify from "@yaireo/tagify";
import "@yaireo/tagify/dist/tagify.css";
export default class extends Controller {
  static targets = ["tagsInput"];

  connect() {
    console.log("Tags controller connected", this.element);
    const element = this.tagsInputTarget;
    const name = element.value;
    console.log(`hello, ${name}!`);
    this.tagify = new Tagify(this.tagsInputTarget);
  }
  handleKeyUp() {
    const element = this.tagsInputTarget;
    const name = element.value;
    console.log(`hello, ${name}!`);
  }
}
