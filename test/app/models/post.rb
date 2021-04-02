# frozen_string_literal: true

class Post
  include ActiveModel::Model
  include ActiveModel::Conversion

  attr_accessor :id, :title

  def persisted?
    id.present?
  end
end
