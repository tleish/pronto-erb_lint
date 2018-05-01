require 'pronto'
require 'erb_lint'
require 'erb_lint/cli'
require 'erb_lint/file_loader'

module Pronto
  class ERBLint < Runner
    DEFAULT_CONFIG_FILENAME = '.erb-lint.yml'

    def initialize(_, _ = nil)
      super
      @options = {}
      load_config
      @inspector = ::ERBLint::Runner.new(file_loader, @config)
    end

    def run
      return [] unless @patches

      @patches.select { |patch| valid_patch?(patch) }
        .map { |patch| inspect(patch) }
        .flatten.compact
    end

    def load_config
      if File.exist?(config_filename)
        config = ::ERBLint::RunnerConfig.new(file_loader.yaml(config_filename))
        @config = ::ERBLint::RunnerConfig.default.merge(config)
      else
        warn "#{config_filename} not found: using default config".yellow
        @config = RunnerConfig.default
      end
      @config.merge!(runner_config_override)
    rescue Psych::SyntaxError => e
      failure!("error parsing config: #{e.message}")
    end

    def config_filename
      @config_filename ||= @options[:config] || ::ERBLint::CLI::DEFAULT_CONFIG_FILENAME
    end

    def file_loader
      @file_loader ||= ::ERBLint::FileLoader.new(Dir.pwd)
    end

    def runner_config_override
      ::ERBLint::RunnerConfig.new(
          linters: {}.tap do |linters|
            ::ERBLint::LinterRegistry.linters.map do |klass|
              linters[klass.simple_name] = { 'enabled' => enabled_linter_classes.include?(klass) }
            end
          end
      )
    end

    def enabled_linter_names
      @enabled_linter_names ||=
          @options[:enabled_linters] ||
              known_linter_names
                  .select { |name| @config.for_linter(name.camelize).enabled? }
    end
    
    def enabled_linter_classes
      @enabled_linter_classes ||= ::ERBLint::LinterRegistry.linters
                                      .select { |klass| linter_can_run?(klass) && enabled_linter_names.include?(klass.simple_name.underscore) }
    end

    def known_linter_names
      @known_linter_names ||= ::ERBLint::LinterRegistry.linters
                                  .map(&:simple_name)
                                  .map(&:underscore)
    end

    def linter_can_run?(klass)
      !autocorrect? || klass.support_autocorrect?
    end

    def autocorrect?
      @options[:autocorrect]
    end

    def valid_patch?(patch)
      return false if patch.additions < 1
      path = patch.new_file_full_path
      erb_file?(path)
    end

    def inspect(patch)
      processed_source = processed_source_for(patch)
      @inspector.run(processed_source)
      offences = @inspector.offenses
      offences.map do |offence|
        patch.added_lines
          .select { |line| offence.line_range.include? line.new_lineno }# line.new_lineno == offence.line
          .map { |line| new_message(offence, line) }
      end
    end

    def new_message(offence, line)
      path = line.patch.delta.new_file[:path]
      level = :error

      Message.new(path, line, level, offence.message, nil, self.class)
    end

    def erb_file?(path)
      File.extname(path) == '.erb'
    end

    def processed_source_for(patch)
      path = patch.new_file_full_path.to_s
      file_content = File.read(path)
      ::ERBLint::ProcessedSource.new(path, file_content)
    end
  end
end
