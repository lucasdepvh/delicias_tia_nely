class PagesController < PublicController
  def about; end

  def contact
    @store_setting = StoreSetting.current
  end
end
