# filepath: /Users/fzhang3/Projects/ruby-box/fengshui_agent/app/controllers/pump_fun_prompts_controller.rb
class PumpFunPromptsController < ApplicationController
  before_action :set_prompts, only: [:edit, :update]
  before_action :set_selected_prompt, only: [:edit, :update]

  def edit
  end

  def update
    new_prompt = @selected_prompt.dup
    new_prompt.content = prompt_params[:content]
    new_prompt.version = @selected_prompt.version + 1

    if new_prompt.save
      redirect_to edit_pump_fun_prompt_path, notice: 'Pump fun prompt was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_prompts
    @prompts = Prompt.where(role: 'pump_fun').order(version: :desc)
  end

  def set_selected_prompt
    @selected_prompt = Prompt.find_by(id: params[:id]) || @prompts.first
  end

  def prompt_params
    params.require(:prompt).permit(:content)
  end
end