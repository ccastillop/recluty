class QuizzesController < ApplicationController
  before_action :set_quiz, only: [:show, :edit, :update, :destroy]

  # GET /quizzes
  # GET /quizzes.json
  def index
    quizzes = policy_scope(Quiz.all)
                .joins(:user)
                .includes(:user)
                .order(created_at: :desc)

    @quiz_filter = QuizFilter.new quiz_filter_params
    quizzes = @quiz_filter.filter(quizzes)

    @pagy, @quizzes = pagy(quizzes)

  end

  # GET /quizzes/1
  # GET /quizzes/1.json
  def show
  end

  # GET /quizzes/new
  def new
    questionnaire = Questionnaire.find params[:questionnaire_id]
    @quiz = questionnaire.quizzes.new
    @quiz.user = current_user
    authorize @quiz
  end

  # GET /quizzes/1/edit
  def edit
  end

  # POST /quizzes
  # POST /quizzes.json
  def create
    @quiz = Quiz.new()
    @quiz.attributes = permitted_attributes(@quiz)
    @quiz.user = current_user
    authorize @quiz
    respond_to do |format|
      if @quiz.save
        format.html { redirect_to edit_quiz_path(@quiz), notice: '¡Gracias! Registré sus respuestas' }
        format.json { render :show, status: :created, location: edit_quiz_path(@quiz) }
      else
        #@quiz.prepare_answers!
        format.html { render :new }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quizzes/1
  # PATCH/PUT /quizzes/1.json
  def update
    respond_to do |format|
      if @quiz.update(permitted_attributes(@quiz))
        format.html { redirect_to edit_quiz_path(@quiz), notice: '¡Gracias! guardé sus cambios' }
        format.json { render :show, status: :ok, location: edit_quiz_path(@quiz) }
      else
        #@quiz.prepare_answers!
        format.html { render :edit }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quizzes/1
  # DELETE /quizzes/1.json
  def destroy
    @quiz.destroy
    respond_to do |format|
      format.html { redirect_to quizzes_path, notice: 'Se destruyeron sus respuestas.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quiz
      @quiz = Quiz.find(params[:id])
      authorize @quiz
    end

    def quiz_filter_params
      if params[:quiz_filter]
        params.require(:quiz_filter).permit(:terms,
          :start_date, :end_date)
      else
        {}
      end
    end

end
