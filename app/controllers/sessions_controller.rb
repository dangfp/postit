class SessionsController < ApplicationController
  def new

  end

  def create
    user = User.find_by_username(params[:username])

    if user && user.authenticate(params[:password])
      if user.two_factor_auth?
        session[:two_factor_auth] = true
        user.generate_pin!
        user.send_pin_to_twilio
        redirect_to pin_path
      else
        login_user!(user)
      end
    else
      flash[:error] = "There's something wrong with your username or password."
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "You've logged out."
    redirect_to login_path
  end

  def pin
    access_denied if session[:two_factor_auth].nil?

    if request.post?
      user = User.find_by(pin: params[:session][:pin])
      if user
        session[:two_factor_auth] = nil
        user.remove_pin!
        login_user!(user)
      else
        flash[:error] = "Sorry, something is wrong with your pin."
        redirect_to pin_path
      end
    end
  end

  private

  def login_user!(user)
    flash[:notice] = "You've logged in."
    login!(user)
  end
end