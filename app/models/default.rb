class Default < ActiveRecord::Base
  include StandardModelExtensions
  include AncestryExtensions
  include MetadataExtensions
  include CaptchaExtensions
  include VerifiedUserExtensions
  include SpamPreventionExtension
  include FormattingExtensions
  include DeletedItemExtensions
  include Rails.application.routes.url_helpers

  RATINGS_DISPLAY = {
    :default_remix => "Remixed",
    :bookmark => "Bookmarked",
    :add => "Added to"
  }

  acts_as_taggable_on :tags
  has_many :playlist_items, :as => :actual_object
  belongs_to :user
  validate :url_format
  has_ancestry :orphan_strategy => :restrict

  searchable(:include => [:metadatum, :tags]) do
    text :display_name 
    string :display_name, :stored => true
    string :id, :stored => true
    text :url
    text :description
    integer :karma
    integer :user_id, :stored => true

    string :tag_list, :stored => true, :multiple => true
    string :metadatum, :stored => true, :multiple => true

    string :user
    boolean :public

    time :created_at
    time :updated_at
    
    string :klass, :stored => true
    boolean :primary do
      false
    end
    boolean :secondary do
      false
    end
  end

  def url_format
    self.errors.add(:url, "URL must be an absolute path (it must contain http)") if !self.url.match(/^http/)
  end

  def display_name
    self.name
  end

  def barcode
    Rails.cache.fetch("default-barcode-#{self.id}", :compress => H2O_CACHE_COMPRESSION) do
      barcode_elements = self.barcode_bookmarked_added

      self.public_children.each do |child|
        barcode_elements << { :type => "default_remix",
                              :date => child.created_at,
                              :title => "Remixed to Link #{child.name}",
                              :link => default_path(child),
                              :rating => 1 }
      end
      
      value = barcode_elements.inject(0) { |sum, item| sum + item[:rating] }
      self.update_attribute(:karma, value)

      barcode_elements.sort_by { |a| a[:date] }
    end
  end

  def self.content_types_options
    %w(text audio video image other_multimedia).map { |i| [i.gsub('_', ' ').camelize, i] }
  end
        
  def before_import_save(row, map)
    self.valid_recaptcha = true
  end
end
