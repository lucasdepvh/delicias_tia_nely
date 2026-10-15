require "test_helper"

class StoreSettingTest < ActiveSupport::TestCase
  test "default setting keeps orders paused and applies the minimum floor" do
    setting = StoreSetting.current

    assert_not setting.accepting_orders?
    assert_equal BigDecimal("20"), setting.effective_minimum_order_value
  end

  test "commercial details are required before orders can be accepted" do
    setting = StoreSetting.current
    setting.accepting_orders = true

    assert_not setting.accepting_orders?
    setting.whatsapp_number = "5500000000000"
    assert setting.accepting_orders?
  end
end
