require "test_helper"

class FoundationAccessTest < ActionDispatch::IntegrationTest
  test "public pages are accessible without an administrator" do
    get root_path
    assert_response :success
    assert_select "h1", /Delícias feitas para adoçar/
    assert_select ".storefront-empty-card", /sabores serão publicados/

    get quem_somos_path
    assert_response :success

    get contato_path
    assert_response :success
  end

  test "administration requires an authenticated administrator" do
    get admin_root_path
    assert_redirected_to new_admin_session_path
  end

  test "administrator can sign in and out" do
    admin = Admin.create!(email: "admin@exemplo.test", password: "senha-segura-123", password_confirmation: "senha-segura-123")

    post admin_session_path, params: { admin: { email: admin.email, password: "senha-segura-123" } }
    assert_redirected_to admin_root_path

    follow_redirect!
    assert_response :success
    assert_select ".admin-dashboard", /Pedidos pausados/
    assert_select ".admin-dashboard__metric", 4

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
