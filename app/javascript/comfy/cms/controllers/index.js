// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "comfy/cms/controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("comfy/cms/controllers", application)
