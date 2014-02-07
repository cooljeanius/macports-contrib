class OsStatistic < ActiveRecord::Base
  belongs_to :user, :validate => true

  attr_accessible :macports_version
  attr_accessible :osx_version
  attr_accessible :os_arch
  attr_accessible :os_platform
  attr_accessible :build_arch
  attr_accessible :gcc_version
  attr_accessible :xcode_version

  validates :macports_version,  :presence => true
  validates :osx_version,       :presence => true
  validates :os_arch,           :presence => true
  validates :os_platform,       :presence => true
  validates :build_arch,        :presence => true
  validates :gcc_version,       :presence => true
  validates :xcode_version,     :presence => true

  # Populate an OsStatistics row with data
  def self.add_os_data(user, os)
    # os and user must not be nil
    # Also, user must not be a new record (i.e. it should be in the database)
    if os.nil? || user.nil? || user.new_record?
      return false
    end
    
    macports_version = os['macports_version']
    osx_version      = os['osx_version']
    os_arch          = os['os_arch']
    os_platform      = os['os_platform']
    build_arch       = os['build_arch']
    gcc_version      = os['gcc_version']
    xcode_version    = os['xcode_version']
   
    # Try to find an existing entry
    os_stats = user.os_statistic
     
    if os_stats.nil?
      # No entry for this user - create a new one
      os_stats = OsStatistic.new()
    end
    
    os_stats[:user_id]          = user.id
    os_stats[:macports_version] = macports_version
    os_stats[:osx_version]      = osx_version
    os_stats[:os_arch]          = os_arch
    os_stats[:os_platform]      = os_platform
    os_stats[:build_arch]       = build_arch
    os_stats[:gcc_version]      = gcc_version
    os_stats[:xcode_version]    = xcode_version
    
    return os_stats.save
  end

  # Returns a hash of frequency hashes with a key for each column
  # The frequency hash contains counts of the number of times a value has 
  # appeared in its column.
  # e.g. If "2.0.0" appears 8 times in the "macports_version" column then
  # frequencies["macports_version"]["2.0.0"] == 8
  def self.frequencies
                           
    columns = { "macports_version" => Hash.new(0),
                "osx_version" => Hash.new(0),
                "os_arch" => Hash.new(0),
                "os_platform" => Hash.new(0),
                "build_arch" => Hash.new(0),
                "gcc_version" => Hash.new(0),
                "xcode_version" => Hash.new(0)
              }
    
    OsStatistic.find_each do |os_stat|
      # For each column in OsStatistics count the number of occurrences of a particular value
      columns.each do |column, hash|
        value = os_stat.attributes[column]
        hash[value] = hash[value] + 1
      end
    end
    
    return columns
  end

end