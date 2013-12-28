module Runoff
  # Contains class methods for finding out the appropriate file paths.
  #
  # Examples
  #
  #   Location::default_skype_data_location skype_username
  #   # => /home/user/.Skype/skype_username/main.db
  class Location
    # Public: Gets a path to the Skype's main.db file.
    #
    # username - A String containing Skype username
    # options  - A hash containing command-line options passed to the command.
    #            If the username is empty, then the hash must contain :from key.
    #
    # Examples
    #
    #   get_database_path('john_doe', {})
    #   # => Path to the default Skype database location depending on the operating system.
    #
    #   get_database_path('', { from: '~/Desktop/main.db' })
    #   # => '~/Desktop/main.db'
    #
    # Returns a String
    def self.get_database_path(username, options)
      if options.has_key?(:from)
        options[:from]
      else
        self.default_skype_data_location username
      end
    end

    # Public: Composes the default Skype database location depending on the operating system.
    #
    # skype_username - A String that contains a username of the Skype account,
    #                  which database we want to access.
    #
    # Examples
    #
    #   On Linux:
    #   default_skype_data_location skype_username
    #   # => /home/user/.Skype/skype_username/mai.db
    #
    #   On Windows:
    #   default_skype_data_location skype_username
    #   # =>  /Users/user/AppData/Roaming/Skype/skype_username/main.db
    #
    # Returns a String that contains the path to the Skype database file.
    def self.default_skype_data_location(skype_username)
      case RbConfig::CONFIG['host_os']
      when /mingw/
        if File.exist?("#{ENV['APPDATA']}\\Skype")
          format_windows_path "#{ENV['APPDATA']}\\Skype\\#{skype_username}\\main.db"
        else
          format_windows_path self.get_default_skype_data_location_on_windows_8(skype_username)
        end
      when /linux/
        "#{ENV['HOME']}/.Skype/#{skype_username}/main.db"
      else
        "#{ENV['HOME']}/Library/Application Support/Skype/#{skype_username}/main.db"
      end
    end

    private

    # Internal: Replaces backslashes with forward slashes and removes drive letter.
    #
    # path - String containing a directory path.
    #
    # Examples
    #
    #   format_windows_path 'C:\Users\username\AppData\Roaming\Skype\skype_username\main.db'
    #   # => /Users/username/AppData/ROaming/Skype/skype_username/main.db
    #
    # Returns a String with modified directory path.
    def self.format_windows_path(path)
      path = path.gsub(/\\/, '/')
      path.gsub(/^[a-zA-Z]:/, '')
    end

    # Internal: Composes the default Skype database location for the Windows 8 operating system.
    #
    # skype_username - A String that contains a username of the Skype account,
    #                  which database we want to access.
    #
    # Examples
    #
    #   get_default_skype_data_location_on_windows_8 skype_username
    #   # => C:/Users/user/AppData/Local/Packages/Microsoft.SkypeApp_sakjhds8asd/LocalState/skype_username/main.db
    #
    # Returns a String that contains the path to the Skype database file.
    def self.get_default_skype_data_location_on_windows_8(skype_username)
      location = "#{ENV['HOME']}/AppData/Local/Packages"
      skype_folder = Dir["#{location}/Microsoft.SkypeApp*"].first

      raise IOError.new "The default Skype directory doesn't exist." unless skype_folder

      "#{skype_folder}/LocalState/#{skype_username}/main.db"
    end
  end
end
