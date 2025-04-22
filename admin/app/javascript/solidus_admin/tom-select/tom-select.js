import TomSelect from "tom-select";

import patchScroll from "./plugins/patch_scroll.js";
import stashOnSearch from "./plugins/stash_on_search.js";
import remoteWithPagination from "./plugins/remote_with_pagination.js";

TomSelect.define("patch_scroll", patchScroll);
TomSelect.define("stash_on_search", stashOnSearch);
TomSelect.define("remote_with_pagination", remoteWithPagination);

export default TomSelect;
