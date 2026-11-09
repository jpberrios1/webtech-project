class ReviewsController < ApplicationController
  def create
    @review = Review.new(review_params)
    @review.user = current_user 

    authorize @review
    
    if @review.save
      redirect_to @review.property, notice: "Review submitted successfully."
    else
      redirect_to @review.property, alert: "Could not submit review. Please make sure all fields are filled."
    end
  end

  def edit
    @review = Review.find(params[:id])
    authorize @review
  end

  def update
    @review = Review.find(params[:id])
    authorize @review

    if @review.update(review_params)
      redirect_to property_path(@review.property), notice: "Review updated successfully."
    else

      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @review = Review.find(params[:id])
    authorize @review

    property = @review.property
    @review.destroy
    redirect_to property_path(property), notice: "Review deleted successfully.", status: :see_other
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment, :property_id, :visit_id)
  end
end
