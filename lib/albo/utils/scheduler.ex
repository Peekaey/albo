defmodule Albo.Utils.Scheduler do
  use GenServer
  require Logger



  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options, [])
  end

  # Server callbacks
  @impl true
  def init(_opts) do
    schedule_next_5pm()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:run_job, state) do
    # Use Timex to get current time in AEST
    now = Timex.now("Australia/Sydney")
    Logger.info("Running 5pm job at #{Timex.format!(now, "{RFC3339}")}")

    execute_reminder()
    schedule_next_5pm()
    {:noreply, state}
  end

  def schedule_next_5pm() do
    now = Timex.now("Australia/Sydney")

    # Get today at 5PM AEST
    target_today =
      now
      |> Timex.beginning_of_day()
      |> Timex.shift(hours: 17)

    target = cond do
      # If before 5PM today and it's a weekday, schedule to run today
      Timex.before?(now, target_today) and is_weekday?(now) ->
        target_today

      # Otherwise find next weekday at 5pm
      true ->
        find_next_weekday_5pm(target_today)
    end

    ms_until = Timex.diff(target, now, :milliseconds)

    ms_until = if ms_until < 0 do
      Logger.warning("Calculated time was in the past, finding next weekday")
      next_target = find_next_weekday_5pm(Timex.shift(now, days: 1))
      Timex.diff(next_target, now, :milliseconds)
    else
      ms_until
    end

    Logger.info("Next job in #{Float.round(ms_until / 1000 / 60 / 60, 2)} hours")
    Process.send_after(self(), :run_job, ms_until)
  end

  defp find_next_weekday_5pm(datetime) do
    # Set to 5pm on this day
    target =
      datetime
      |> Timex.beginning_of_day()
      |> Timex.shift(hours: 17)

    if is_weekday?(datetime) do
      target
    else
      # Move to next day and check again
      find_next_weekday_5pm(Timex.shift(datetime, days: 1))
    end
  end

  defp is_weekday?(datetime) do
    Timex.weekday(datetime) in 1..5
  end

  defp execute_reminder do
    Logger.info("Executing - Reminding everyone about the right to disconnect")
    channel_id = Application.fetch_env!(:nostrum, :channel_id)
    Albo.Commands.RemindEveryoneToDisconnect.remind_everyone_to_disconnect_background_job(channel_id)
    Logger.info("Reminder sent successfully")
  end
end
