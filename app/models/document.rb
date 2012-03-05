require 'docsplit'

class Document < ActiveRecord::Base
  ROOT_LOCATION = '/uploads/docs'
  
  after_save :do_migration
  before_destroy :do_cleanup
  validates :path, :presence => true
  validates :name, :presence => true
  
  def uploaded_to_s3?
    self.uploaded_to_s3
  end
  
  def processed?
    self.processed
  end
  
  def migrated?
    self.migrated
  end
  
  def process(file)
    self.errors.add :base, 'Invalid file' and return unless !file.blank? and (file.respond_to? :path)
    self.errors.add :base, 'Empty file uploaded for topics' and return unless file.size > 0
    begin
      self.name = File.basename file.respond_to?(:original_filename) ? file.original_filename : file.path
      FileUtils.mkdir_p self.tmp_dir
      self.path = self.tmp_dir
      FileUtils.mv file.path, self.full_path
      self.page_count = Docsplit.extract_length self.full_path
      Docsplit.extract_images self.full_path, :output => self.path
      self.processed = true
    rescue
      self.errors.add :base, 'Unable to create temporary file and process'
    end
    self  
  end
  
  def base_url
    @base_url ||= "#{ROOT_LOCATION}/#{self.id}"
  end
  
  def slides_urls
    1.upto(self.page_count).collect{|i| "#{self.base_url}/#{File.basename(self.name, File.extname(self.name))}_#{i}.png"}
  end
  
  def self.root_dir
    @@root_folder ||= "#{Rails.root}/public#{ROOT_LOCATION}"
  end

  def tmp_dir
    @tmp_folder ||= "#{self.class.root_dir}/#{Time.now.utc.to_i}"
  end

  def final_dir
    raise Exception "Not yet saved" unless self.id
    @final_dir ||= "#{self.class.root_dir}/#{self.id}"
  end
  
  def full_path
    File.join self.path, self.name
  end
  
  def migrate
    FileUtils.mv self.tmp_dir, self.final_dir
    self.path = self.final_dir
    self.migrated = true
  end
  
  private
  
  def do_migration
    unless self.migrated
      self.migrate
      self.save
    end
  rescue
    ## SOME LOG MESSAGE
  end
  
  def do_cleanup
    FileUtils.rm_rf(self.path)
  rescue
    
  end

end
