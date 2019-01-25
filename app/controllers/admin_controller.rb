class AdminController < BaseStoreController

  before_action :authenticate_user!

  layout 'admin'
end
