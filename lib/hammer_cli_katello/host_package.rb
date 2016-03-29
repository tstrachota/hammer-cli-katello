class String
  def remove_first_line!
    first_newline = (index("\n") || size - 1) + 1
    slice!(0, first_newline).sub("\n",'')
  end
end

module HammerCLIKatello

  class HostPackage < HammerCLIKatello::Command

    desc "Manage packages on your hosts"

    class ListCommand < HammerCLIKatello::ListCommand
      resource :host_packages, :index

      output do
        field :nvra, _("NVRA")
      end

      build_options
    end

    class InstallCommand < HammerCLIKatello::SingleResourceCommand
      include HammerCLIForemanTasks::Async
      resource :host_packages, :install
      command_name "install"
      success_message "Packages install successfully"
      failure_message "Could not install packages"

      validate_options do
        option(:option_packages).required
      end

      def progress_bar
        bar                                      = PowerBar.new
        @closed = false
        bar.settings.tty.finite.template.main    = '[${<bar>}] [${<percent>%}]'
        bar.settings.tty.finite.template.padchar = ' '
        bar.settings.tty.finite.template.barchar = '.'
        # bar.settings.tty.finite.output           = Proc.new { |s| $stderr.print s }
        # bar.settings.tty.finite.wipe             = "\e[0m\e[1G\e[K"
        # bar.settings.tty.finite.template.wipe             = "\e[0m"
        # bar.settings.tty.finite.template.post             = "\e[3A\e[K"
        yield bar
      ensure
        bar.close
      end

      class Message
        def initialize
          @printed = false
          @lines_count = 0
        end

        def show(msg)
          puts eraser if @printed

          cnt = msg.split("\n").count + 1
          @lines_count = cnt if cnt > @lines_count

          spacer = "\n" * (@lines_count - cnt)

          puts "#{spacer}#{msg}"
          @printed = true
        end

        def eraser
          ("\e[1G\e[K\e[1A" * @lines_count)
        end
      end

      def execute
        progress_bar do |bar|
          progress = 0.0
          begin
            str = "Message\non multiple\nlines\n"
            msg = Message.new
            while true


              msg.show(str)

              bar.show(:msg => msg, :done => progress, :total => 1)
              sleep 1
              progress += 0.1

              break if progress > 1
              if progress > 0.39
                str.remove_first_line!
              else
                str += "lines #{progress}\n"
              end
            end
          rescue Interrupt
            # Inerrupting just means we stop rednering the progress bar
          end
        end
        HammerCLI::EX_OK
      end

      build_options :without => [:groups]
    end

    class UpgradeCommand < HammerCLIKatello::SingleResourceCommand
      include HammerCLIForemanTasks::Async
      resource :host_packages, :upgrade
      command_name "upgrade"
      success_message "Packages upgraded successfully"
      failure_message "Could not upgrade packages"

      build_options
    end

    class UpgradeAllCommand < HammerCLIKatello::SingleResourceCommand
      include HammerCLIForemanTasks::Async
      resource :host_packages, :upgrade_all
      command_name "upgrade-all"
      success_message "All packages upgraded successfully"
      failure_message "Could not upgrade all packages"

      build_options
    end

    class RemoveCommand < HammerCLIKatello::SingleResourceCommand
      include HammerCLIForemanTasks::Async
      resource :host_packages, :remove
      command_name "remove"
      success_message "Packages removed successfully"
      failure_message "Could not remove packages"

      validate_options do
        option(:option_packages).required
      end

      build_options :without => [:groups]
    end

    autoload_subcommands
  end

end
