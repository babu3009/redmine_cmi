require_dependency 'journal_observer'
#require 'dispatcher'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

module CMI
  module JournalObserverPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will be reloaded in development

        alias_method_chain :after_create, :cmi
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def after_create_with_cmi(journal)
        unless [ 'CmiCheckpoint', 'CmiExpenditure'].include? journal.journalized_type
          after_create_without_cmi(journal)
        end
      end
    end
  end
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    JournalObserver.send(:include, CMI::JournalObserverPatch)
  end
else
  Dispatcher.to_prepare do
    JournalObserver.send(:include, CMI::JournalObserverPatch)
  end
end
