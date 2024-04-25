require_relative 'less_active_record'

class Post < LessActiveRecord
  column :title, 'text'
  column :content, 'text'
  column :likes, 'integer'

  validates :title, :content
end
