# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  author_id  :bigint           not null
#  photo_id   :bigint           not null
#
# Indexes
#
#  index_comments_on_author_id  (author_id)
#  index_comments_on_photo_id   (photo_id)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (photo_id => photos.id)
#
class Comment < ApplicationRecord
  belongs_to :author, class_name: "User", counter_cache: true
  belongs_to :photo, counter_cache: true

  validates :body, presence: true

  scope :default_order, -> { order(created_at: :asc) }

  # after_create_commit -> { broadcast_after_to "comments_photo_#{photo.id}", target: "comment_#{photo.comments.default_order.first.id}", partial: "comments/placeholder", locals: { comment: self } }
  after_create_commit -> { broadcast_before_to "comments_photo_#{photo_id}", target: "comments_form_photo_#{photo_id}", partial: "comments/placeholder", locals: { comment: self } }
  after_update_commit -> { broadcast_replace_to "comment_#{id}", partial: "comments/placeholder", locals: { comment: self } }
  after_destroy_commit -> { broadcast_remove_to "comment_#{id}" }
end
