import { application } from "controllers/application"
import CartDrawerController from "controllers/cart_drawer_controller"
import CheckoutController from "controllers/checkout_controller"

application.register("cart-drawer", CartDrawerController)
application.register("checkout", CheckoutController)
export { application }
