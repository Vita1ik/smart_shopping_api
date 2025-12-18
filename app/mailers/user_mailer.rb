class UserMailer < ApplicationMailer
  # default from: 'Shoe Store <info@smartshopping.pp.ua>'
  default from: 'onboarding@resend.dev'

  def discount_alert(user, shoe, current_price, previous_price)
    @user = user
    @shoe = shoe
    @savings = previous_price - current_price
    @previous_price = previous_price
    @current_price = current_price

    @percentage = ((@savings.to_f / previous_price) * 100).round

    mail(
      to: @user.email,
      subject: "Price Drop! #{@shoe.name} is now #{@percentage}% off"
    )
  end
end