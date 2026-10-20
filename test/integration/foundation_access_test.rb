require "test_helper"

class FoundationAccessTest < ActionDispatch::IntegrationTest
  test "public pages are accessible without an administrator" do
    get root_path
    assert_response :success
    assert_select "h1", "Sabores para adoçar o seu dia."
    assert_select ".storefront-empty-card", /sabores serão publicados/
    assert_select ".storefront-nav a[href='#{contato_path}']", count: 0
    assert_select ".storefront-nav svg.navigation-icon", 1
    assert_select "a.floating-cart svg.navigation-icon"
    assert_select "footer a[href='https://portifolio-silk-six-70.vercel.app/'][target='_blank']", "Lucas Martins"

    get quem_somos_path
    assert_response :success

    get contato_path
    assert_response :success
  end

  test "administration requires an authenticated administrator" do
    get admin_root_path
    assert_redirected_to new_admin_session_path
  end

  test "login page renders the public layout with an empty cart" do
    get new_admin_session_path

    assert_response :success
    assert_select "a.floating-cart #cart-count", "0"
    assert_select ".auth-login h1", "Acesse a administração"
    assert_select "input#admin_email[aria-describedby='admin_email_hint']"
    assert_select "input#admin_password[aria-describedby='admin_password_hint']"
  end

  test "invalid login displays a clear Portuguese message" do
    post admin_session_path, params: { admin: { email: "nao-existe@exemplo.test", password: "senha-incorreta" } }

    assert_response :unprocessable_entity
    assert_select ".flash.flash--alert", "E-mail ou senha inválidos."
  end

  test "dashboard only activates orders with a valid WhatsApp" do
    admin = Admin.create!(email: "gestora@exemplo.test", password: "senha-segura-123", password_confirmation: "senha-segura-123")
    setting = StoreSetting.create!(singleton_key: StoreSetting::SINGLETON_KEY, store_name: "Loja de teste", accepting_orders: false, minimum_order_value: 0, default_delivery_fee: 10)

    post admin_session_path, params: { admin: { email: admin.email, password: "senha-segura-123" } }
    post admin_toggle_orders_path

    assert_redirected_to admin_root_path
    assert_not setting.reload.accepting_orders
    follow_redirect!
    assert_select ".flash.flash--alert", "Não foi possível ativar os pedidos. Atualize o WhatsApp válido da loja antes de continuar."

    setting.update!(whatsapp_number: "5511999999999")
    post admin_toggle_orders_path

    assert_redirected_to admin_root_path
    assert setting.reload.accepting_orders
    follow_redirect!
    assert_select ".flash", "Loja habilitada para receber pedidos."
  end

  test "administrator can sign in and out" do
    admin = Admin.create!(email: "admin@exemplo.test", password: "senha-segura-123", password_confirmation: "senha-segura-123")

    post admin_session_path, params: { admin: { email: admin.email, password: "senha-segura-123" } }
    assert_redirected_to admin_root_path

    follow_redirect!
    assert_response :success
    assert_select ".admin-overview", /Loja pausada/
    assert_select ".admin-overview__metrics article", 4

    delete destroy_admin_session_path
    assert_redirected_to root_path
  end

  test "health checks are public" do
    get "/health"
    assert_response :success
    assert_equal "ok", response.parsed_body["status"]

    get "/up"
    assert_response :success
  end

  test "public admin registration is unavailable" do
    get "/admins/sign_up"
    assert_response :not_found
  end
end
