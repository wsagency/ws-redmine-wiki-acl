class WikiPageAcl < ActiveRecord::Base
  belongs_to :wiki_page
  belongs_to :user

  validates :access_level, inclusion: { in: %w[view edit] }
  validates :wiki_page_id, uniqueness: { scope: :user_id }

  scope :viewers, -> { where(access_level: %w[view edit]) }
  scope :editors, -> { where(access_level: 'edit') }

  def self.restricted?(wiki_page)
    where(wiki_page_id: wiki_page.id).exists?
  end

  def self.user_can_view?(wiki_page, user)
    return true if user.admin?
    acls = where(wiki_page_id: wiki_page.id)
    return true if acls.empty?
    acls.exists?(user_id: user.id)
  end

  def self.user_can_edit?(wiki_page, user)
    return true if user.admin?
    acls = where(wiki_page_id: wiki_page.id)
    return true if acls.empty?
    acls.exists?(user_id: user.id, access_level: 'edit')
  end
end
