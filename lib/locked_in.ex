defmodule LockedIn do
  @moduledoc """
  LockedIn keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def upload_dir do
    Path.expand("./"<>Application.get_env(:locked_in, :upload_path))
  end

  def admin_email do
    Application.get_env(:locked_in, :admin_email)
  end

  def admin_password do
    Application.get_env(:locked_in, :admin_password)
  end

end
