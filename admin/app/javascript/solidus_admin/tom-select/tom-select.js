import TomSelect from "tom-select";

import patchScroll from "solidus_admin/tom-select/plugins/patch_scroll";
import stashOnSearch from "solidus_admin/tom-select/plugins/stash_on_search";
import remoteWithPagination from "solidus_admin/tom-select/plugins/remote_with_pagination";

TomSelect.define("patch_scroll", patchScroll);
TomSelect.define("stash_on_search", stashOnSearch);
TomSelect.define("remote_with_pagination", remoteWithPagination);

export default TomSelect;
