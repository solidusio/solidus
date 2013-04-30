module SpreeI18n
  class Locale
    class << self
      def all
        Dir["#{dir}/*.yml"].map { |f| File.basename(f, '.yml').to_sym }
      end

      def dir
        File.join(File.dirname(__FILE__), "/../../config/locales")
      end
    end
  end
end
