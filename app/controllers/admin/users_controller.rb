module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :show, :edit, :update, :destroy ]

    def index
      @users = User.all.includes(:department).order(:name)
      @users = @users.where(role: params[:role]) if params[:role].present?
    end

    def show
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(create_params)
      if @user.save
        flash[:notice] = "User created successfully."
        redirect_to admin_users_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      # Remove password fields if blank
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      if @user.update(update_params)
        flash[:notice] = "User updated successfully."
        redirect_to admin_users_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user.destroy
        flash[:notice] = "User deleted."
      else
        flash[:alert] = @user.errors.full_messages.to_sentence
      end
      redirect_to admin_users_path
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :department_id)
    end

    def create_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :department_id)
    end

    def update_params
      permitted = params.require(:user).permit(:name, :email, :password, :password_confirmation, :department_id)
      # Admins can also update the role
      permitted[:role] = params[:user][:role] if params[:user][:role].present?
      permitted
    end
  end
end
