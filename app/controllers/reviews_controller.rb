class ReviewsController < ApplicationController
  def create
    @review = Review.new(review_params)
    @review.user = current_user # Asume que tu modelo Review tiene belongs_to :user

    if @review.save
      redirect_to @review.property, notice: "Review submitted successfully."
    else
      redirect_to @review.property, alert: "Could not submit review. Please make sure all fields are filled."
    end
  end

  def edit
    @review = Review.find(params[:id])
  end

  def update
    @review = Review.find(params[:id])

    if @review.update(review_params)
      redirect_to property_path(@review.property), notice: "Review updated successfully."
    else
      # Si hay error de validación, vuelve a mostrar el formulario
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @review = Review.find(params[:id])
    property = @review.property

    # Solo el creador de la reseña o un moderador pueden borrarla
    if @review.user == current_user || current_user.name.downcase.include?("mod")
      @review.destroy
      redirect_to property_path(property), notice: "Review deleted successfully.", status: :see_other
    else
      redirect_to property_path(property), alert: "You are not authorized to delete this review.", status: :see_other
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment, :property_id, :visit_id)
  end
end
