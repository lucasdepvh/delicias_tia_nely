import { application } from "controllers/application"
import CartDrawerController from "controllers/cart_drawer_controller"
import CheckoutController from "controllers/checkout_controller"
import InputMaskController from "controllers/input_mask_controller"
import NestedFormController from "controllers/nested_form_controller"
import MobileMenuController from "controllers/mobile_menu_controller"

application.register("cart-drawer", CartDrawerController)
application.register("checkout", CheckoutController)
application.register("input-mask", InputMaskController)
application.register("nested-form", NestedFormController)
application.register("mobile-menu", MobileMenuController)
export { application }
