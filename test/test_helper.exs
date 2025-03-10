ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier]
++ [Bonfire.Common.TestSummary]
# ++ [Bonfire.UI.Kanban.TestDrivenCoordination]

# Code.put_compiler_option(:nowarn_unused_vars, true)

skip = if System.get_env("TEST_INSTANCE")=="yes", do: [], else: [:test_instance]

ExUnit.start(
  exclude: [:skip, :todo, :fixme] ++ skip,
  capture_log: true # only show log for failed tests (Can be overridden for individual tests via `@tag capture_log: false`)
)

# Mix.Task.run("ecto.create")
# Mix.Task.run("ecto.migrate")

# Ecto.Adapters.SQL.Sandbox.mode(Bonfire.Repo, :manual)

# if System.get_env("START_SERVER") !="true" do
  Ecto.Adapters.SQL.Sandbox.mode(Bonfire.Repo, :auto)
# end

# ExUnit.after_suite(fn results ->
#     # do stuff
#     IO.inspect(test_results: results)

#     :ok
# end)
