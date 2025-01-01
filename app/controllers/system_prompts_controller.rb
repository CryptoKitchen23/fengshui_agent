class SystemPromptsController < ApplicationController
  def edit
    @prompts = load_prompts
  end

  def update
    @prompts = {
      'system_prompt' => {
        'role' => params[:role],
        'content' => params[:system_prompt_content]
      },
      'pump_fun_prompt' => {
        'content' => params[:pump_fun_prompt_content]
      }
    }
    if save_prompts(@prompts)
      redirect_to edit_system_prompt_path, notice: 'Prompts were successfully updated.'
    else
      render :edit, alert: 'Failed to update prompts.'
    end
  end

  private

  def load_prompts
    YAML.load_file(Rails.root.join('config', 'prompts', 'prompts.yml'))
  end

  def save_prompts(prompts)
    File.open(Rails.root.join('config', 'prompts', 'prompts.yml'), 'w') do |file|
      file.write(prompts.to_yaml)
    end
  rescue
    false
  end
end
