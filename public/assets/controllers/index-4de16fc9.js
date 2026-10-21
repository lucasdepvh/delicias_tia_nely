import { application } from "controllers/application"
import CartDrawerController from "controllers/cart_drawer_controller"
import CheckoutController from "controllers/checkout_controller"
import InputMaskController from "controllers/input_mask_controller"

application.register("cart-drawer", CartDrawerController)
application.register("checkout", CheckoutController)
application.register("input-mask", InputMaskController)
export { application }
