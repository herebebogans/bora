require 'thor'
require 'bora'
require 'bora/cli_base'
require 'bora/cli_change_set'

class Bora
  class Cli < CliBase
    class_option(
      :file,
      type: :string,
      aliases: :f,
      default: Bora::DEFAULT_CONFIG_FILE,
      desc: 'The Bora config file to use'
    )
    class_option(
      :region,
      type: :string,
      aliases: :r,
      default: nil,
      desc: 'The region to use for the stack operation. Overrides any regions specified in the Bora config file.'
    )
    class_option(
      'cfn-stack-name',
      type: :string,
      aliases: :n,
      default: nil,
      desc: 'The name to give the stack in CloudFormation. Overrides any CFN stack name setting in the Bora config file.'
    )

    desc 'list', 'Lists the available stacks'
    def list
      templates = bora(options.file).templates
      stacks = templates.collect(&:stacks).flatten
      stack_names = stacks.collect(&:stack_name)
      puts stack_names.join("\n")
    end

    desc 'apply STACK_NAME', 'Creates or updates the stack'
    option :params, type: :array, aliases: :p, desc: "Parameters to be passed to the template, eg: --params 'instance_type=t2.micro'"
    option :pretty, type: :boolean, default: false, desc: 'Send pretty (formatted) JSON to AWS (only works for cfndsl templates)'
    def apply(stack_name)
      stack(options.file, stack_name).apply(params, options.pretty)
    end

    desc 'delete STACK_NAME', 'Deletes the stack'
    def delete(stack_name)
      stack(options.file, stack_name).delete
    end

    desc 'diff STACK_NAME', "Diffs the new template with the stack's current template"
    option :params, type: :array, aliases: :p, desc: "Parameters to be passed to the template, eg: --params 'instance_type=t2.micro'"
    option :context, type: :numeric, aliases: :c, default: 3, desc: 'Number of lines of context to show around the differences'
    def diff(stack_name)
      stack(options.file, stack_name).diff(params, options.context)
    end

    desc 'events STACK_NAME', 'Outputs the latest events from the stack'
    def events(stack_name)
      stack(options.file, stack_name).events
    end

    desc 'outputs STACK_NAME', 'Shows the outputs from the stack'
    def outputs(stack_name)
      stack(options.file, stack_name).outputs
    end

    desc 'parameters STACK_NAME', 'Shows the parameters from the stack'
    def parameters(stack_name)
      stack(options.file, stack_name).parameters
    end

    desc 'recreate STACK_NAME', 'Recreates (deletes then creates) the stack'
    option :params, type: :array, aliases: :p, desc: "Parameters to be passed to the template, eg: --params 'instance_type=t2.micro'"
    def recreate(stack_name)
      stack(options.file, stack_name).recreate(params)
    end

    desc 'show STACK_NAME', 'Shows the new template for stack'
    option :params, type: :array, aliases: :p, desc: "Parameters to be passed to the template, eg: --params 'instance_type=t2.micro'"
    def show(stack_name)
      stack(options.file, stack_name).show(params)
    end

    desc 'show_current STACK_NAME', 'Shows the current template for the stack'
    def show_current(stack_name)
      stack(options.file, stack_name).show_current
    end

    desc 'status STACK_NAME', 'Displays the current status of the stack'
    def status(stack_name)
      stack(options.file, stack_name).status
    end

    desc 'validate STACK_NAME', "Checks the stack's template for validity"
    option :params, type: :array, aliases: :p, desc: "Parameters to be passed to the template, eg: --params 'instance_type=t2.micro'"
    def validate(stack_name)
      stack(options.file, stack_name).validate(params)
    end

    desc 'changeset SUBCOMMAND ...ARGS', 'Manage CloudFormation change sets'
    subcommand 'changeset', CliChangeSet
  end
end
