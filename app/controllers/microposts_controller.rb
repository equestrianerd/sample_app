class MicropostsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy
  before_filter :find_user, :only => :index
  
  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = 'Micropost created!'
      redirect_to root_path
    else
      @feed_items = []
      render 'pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_back_or root_path
  end
  
  def index
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name + ' | Microposts'
  end

  private
    def authorized_user
      @micropost = Micropost.find(params[:id])
      redirect_to root_path unless current_user?(@micropost.user)
    end
  
    def find_user
      @user = User.find(params[:user_id])
    end
end
