class Comment < LessActiveRecord
  column :content, 'text'
  column :post_id, 'integer'

  belongs_to :post
end
