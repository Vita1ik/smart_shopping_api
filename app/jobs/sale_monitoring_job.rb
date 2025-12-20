class SaleMonitoringJob
  include Sidekiq::Job

  sidekiq_options queue: :scrapers

  def perform(user_shoe_id)
    user_shoe = UserShoe.find(user_shoe_id)
    return unless user_shoe.liked

    price = Scrapers.get_shoe_price(user_shoe.shoe)
    return unless price

    if user_shoe.current_price > price
      current_price = user_shoe.current_price
      discounted_price = price
      user_shoe.discount!(price)
      UserMailer.discount_alert(user_shoe.user, user_shoe.shoe, discounted_price, current_price).deliver_later
    else
      SaleMonitoringJob.perform_in(24.hours, user_shoe_id)
    end
  end
end