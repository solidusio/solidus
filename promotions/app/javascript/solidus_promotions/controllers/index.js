import { application } from "solidus_promotions/controllers/application";

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";
eagerLoadControllersFrom(
  "solidus_promotions/controllers",
  application
);
