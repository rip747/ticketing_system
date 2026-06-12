class CommentsController < ApplicationController
  before_action :require_login

  def create
    @ticket = current_organization.tickets.find(params[:ticket_id])
    @comment = @ticket.comments.build(comment_params)
    @comment.user = current_user
    @comment.organization = current_organization

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @ticket, notice: "Comment added." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error, status: :unprocessable_entity }
        format.html { redirect_to @ticket, alert: @comment.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    @comment = current_organization.comments.find(params[:id])
    @ticket = @comment.ticket
    if current_user.org_admin? || @comment.user == current_user
      @comment.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @ticket, notice: "Comment deleted." }
      end
    else
      redirect_to @ticket, alert: "Not authorized."
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
