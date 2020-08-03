defmodule PlayerMatches do
    @moduledoc """
    Documentation for `PlayerMatches`.

    Create an application that has one method:

        find_recently_played_with_matches(region, summoner_name)

    This method should call riot’s summoner api to get summoner information. Use their account id to find 
    their latest 5 matches with riot’s matchlist api. For each of those 5 matches, take each player that 
    was in the match and monitor that player for new matches every minute for the next 5 minutes. Log any 
    new match.
    """

    require Logger
    require SummonerClient

    @doc """
    """
    def find_recently_played_with_matches(region, summoner_name) do
        Logger.info("PlayerMatches: getting summoner by name: #{summoner_name}")
        case SummonerClient.get_summoner_by_name(region, summoner_name) do
            {:ok, player } -> 
                case SummonerClient.get_last_n_matches(region, player.accountId, 5) do
                    {:ok, match_list} -> monitor_players_in_matches(region, match_list.matches)
                    {:error, _error} -> Logger.error("Error getting matches.")
                end
            {:error, _error} -> Logger.error("Error getting summoner.")
        end
    end

    @doc """
    """
    def find_recent_tournaments(region) do
        Logger.info("PlayerMatches: getting recent tournaments")
        SummonerClient.get_tournaments(region)
    end

    @doc """
    """
    def start(_type, _args) do
        find_recently_played_with_matches("br1", "King")
        Task.start(fn -> :timer.sleep(1000); IO.puts("done sleeping") end)
    end

    @doc """
    """
    def monitor_players_in_matches(region, matches) do
        Logger.info("PlayerMatches: monitoring players in last 5 matches ...")

        last_game = Enum.at(matches, 0)

        player_set = MapSet.new(List.flatten(Enum.map(matches, fn match -> 
            case SummonerClient.get_match_details(region, match.gameId) do
                {:ok, match_details} -> Enum.map(match_details.participantIdentities, fn player -> player end)
                {:error, _error} -> nil
            end
        end)))

        {:ok, date_time} = DateTime.from_unix(last_game.timestamp, :millisecond)

        Logger.info("Logging new games for players since: #{DateTime.to_string(date_time)}")

        poll(region, player_set, last_game.timestamp, 0)
    end

    @doc """
    """
    def poll(region, players, log_since, count) do
        if count <= 5 do
            receive do
            after
            60_000 ->
                log_matches(region, players, log_since)
                poll(region, players, log_since, count + 1)
            end
        end
    end

    @doc """
    """
    def log_matches(region, players, log_since) do
        Enum.map(players, fn player ->
            case SummonerClient.get_last_n_matches(region, player.accountId, 5) do
                {:ok, match_list} -> 
                    Enum.map(match_list.matches, fn match ->
                        if match.timestamp > log_since do
                            player_name = player.summonerName
                            match_id = match.gameId
                            {:ok, date_time} = DateTime.from_unix(match.timestamp, :millisecond)
                            Logger.info("New Match for Player: #{player_name}, Match ID: #{match_id}, At: #{DateTime.to_string(date_time)}")
                        end
                    end)
                {:error, _error} -> Logger.error("Error getting matches.")
            end
        end)
    end
end
