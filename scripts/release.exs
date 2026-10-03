defmodule Presswerk.Release do
  @root Path.expand("..", __DIR__)
  @mix_exs Path.join(@root, "mix.exs")

  def run([part]) when part in ~w(patch minor major) do
    {status, 0} = System.cmd("git", ["status", "--porcelain"], cd: @root)

    if status != "" do
      raise "Commit or stash all changes before releasing."
    end

    contents = File.read!(@mix_exs)

    [_, current] =
      Regex.run(~r/^\s*version: "(\d+\.\d+\.\d+(?:-dev)?)",$/m, contents) ||
        raise "Expected a version like 0.1.0 or 0.1.1-dev in mix.exs."

    %Version{major: major, minor: minor, patch: patch, pre: pre} = Version.parse!(current)

    {major, minor, patch} =
      case part do
        "major" -> {major + 1, 0, 0}
        "minor" -> {major, minor + 1, 0}
        "patch" -> {major, minor, patch + if(pre == ["dev"], do: 0, else: 1)}
      end

    release = "#{major}.#{minor}.#{patch}"
    tag = "v#{release}"
    {existing_tag, 0} = System.cmd("git", ["tag", "--list", tag], cd: @root)

    if existing_tag != "" do
      raise "Tag #{tag} already exists."
    end

    update_version(contents, current, release)
    run!("mix", ["precommit"])
    run!("git", ["add", "--", "mix.exs"])
    run!("git", ["commit", "-m", "chore: release #{tag}"])
    run!("git", ["tag", "-a", tag, "-m", "Release #{tag}"])

    next_dev = "#{major}.#{minor}.#{patch + 1}-dev"
    update_version(File.read!(@mix_exs), release, next_dev)
    run!("git", ["add", "--", "mix.exs"])
    run!("git", ["commit", "-m", "chore: start #{next_dev} development"])
    IO.puts("Created #{tag}; now on #{next_dev}. Push the commits and tag when ready.")
  end

  defp update_version(contents, from, to) do
    File.write!(
      @mix_exs,
      String.replace(contents, ~s(version: "#{from}"), ~s(version: "#{to}"), global: false)
    )
  end

  defp run!(command, args) do
    {output, exit_code} = System.cmd(command, args, cd: @root, stderr_to_stdout: true)
    IO.write(output)

    if exit_code != 0 do
      raise "#{command} #{Enum.join(args, " ")} failed (exit #{exit_code})."
    end
  end
end

Presswerk.Release.run(System.argv())
