import { application } from "solidus_friendly_promotions/controllers/application";

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";
eagerLoadControllersFrom(
  "solidus_friendly_promotions/controllers",
  application
);
