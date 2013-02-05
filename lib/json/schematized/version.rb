# encoding: UTF-8

module JSON
  module Schematized
    class Version
      def self.gem_root
        @gem_root ||= File.expand_path("../../../..", __FILE__)
      end

      def self.version_file
        @version_file ||= File.join(gem_root, "GEM_VERSION")
      end

      def gem_root; self.class.gem_root end
      def version_file; self.class.version_file end

      def version_from_file
        File.exists?(version_file) ? File.read(version_file).chomp : nil
      end

      def version_from_gempath
        gem_root =~ /\/json-schematized-(\d+\.[\w\.]+)$/ ? $1 : nil
      end

      def version_from_stepup
        version = nil
        if File.exists?(File.join(gem_root, ".git"))
          require "step-up"
          Dir.chdir(gem_root) do
            version = StepUp::Driver::Git.new.last_version_tag("HEAD", true)
          end
          File.open(version_file, "w"){ |f| f.write version } unless File.exists?(version_file)
        end
        version
      rescue
        nil
      end

      def version
        @version ||= (
          version_from_file ||
          version_from_gempath ||
          version_from_stepup ||
          "v0.0.0+"
        )
      end
    end

    VERSION = Version.new.version.to_s.gsub(/^v?([^+]+)(?:\+\d*)?$/, '\1')
  end
end
