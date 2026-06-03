import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "keywords", "results", "result"];
  static classes = ["current"];

  // This is needed to restore the current result index when the
  // results are updated after a search.
  resultsTargetConnected() {
    this.currentResultIndex = 0;
    this.render();
  }

  fetchResults() {
    // this.keywords.length == 0 means the string has been totally deleted
    // or the 'x' cancel cross has been clicked.
    // the html input type search fires a search event
    // in both cases, either a character is typed, or the cancel cross is clicked.

    if (this.keywords.length < 2) {
      this.reset();
      return;
    }

    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => this.formTarget.requestSubmit(), 500);
  }

  nextResult() {
    if (this.currentResultIndex < this.resultTargets.length - 1) {
      this.currentResultIndex++;
      this.render();
    }
  }

  previousResult() {
    if (this.currentResultIndex > 0) {
      this.currentResultIndex--;
      this.render();
    }
  }

  openResult() {
    this.resultTargets[this.currentResultIndex].firstElementChild.click();
  }

  focusOut(event) {
    if (!this.formTarget.contains(event.target)) {
      this.reset();
    }
  }

  reset() {
    this.currentResultIndex = 0;
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = "";
    }
  }

  render() {
    this.resultTargets.forEach((element, index) => {
      element.classList.toggle(
        this.currentClass,
        index == this.currentResultIndex
      );
    });
  }

  get keywords() {
    return this.keywordsTarget.value;
  }
}
