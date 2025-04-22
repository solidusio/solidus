// Substitute default TomSelect functionality for single selects, where typing in the select field while there is
//  an option selected shows both selected option and the search term.
// Instead, hide the selected option when typing and bring it back when leaving the field.
class Stash {
  constructor() {
    this.content = {};
  }

  put(value, data) {
    this.content["value"] = value;
    this.content["data"] = data;
  }

  pop() {
    const { value, data } = this.content;
    this.clear();
    return { value, data };
  }

  clear() {
    this.content = {};
  }

  isEmpty() {
    return Object.keys(this.content).length === 0;
  }
}

export default function() {
  if (this.settings.mode === 'multi') return;

  this.stash = new Stash();

  this.stashSelected = function() {
    if (!this.stash.isEmpty()) return;
    if (!this.items.length) return;

    const currentValue = this.items[0];
    this.stash.put(currentValue, this.options[currentValue]);
    this.clear(true);
  };

  this.unstashSelected = function() {
    if (this.stash.isEmpty()) return;

    const { value, data } = this.stash.pop();
    // In case this is a select with remote source, options are refreshed on each search, so we need to put the option
    //  back in the list for TomSelect to pick it as a selected item.
    // If the option is already in the list, it will be ignored.
    this.addOption(data);
    this.setValue(value, true);
  };

  // save current selected option in case user won't select anything
  this.on("type", function() {
    this.stashSelected();
  });

  // new option has been selected, no need to hold on to previous option
  this.on("item_add", function() {
    this.stash.clear();
  });

  // if nothing has been selected restore previous option
  this.on("blur", function() {
    if (this.items.length) return;

    this.unstashSelected();
  });
}
