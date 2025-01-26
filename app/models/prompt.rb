class Prompt < ApplicationRecord
  before_create :set_version

  private

  def set_version
    self.version = Prompt.where(role: role).maximum(:version).to_i + 1
  end
end