defmodule SummonerClient do
    @moduledoc """
    """
    use HTTPoison.Base
    require Logger
    alias SummonerStructs.Tournament, as: Tournament
    alias SummonerStructs.Schedule, as: Schedule
    alias SummonerStructs.Summoner, as: Summoner
    alias SummonerStructs.MatchList, as: MatchList
    alias SummonerStructs.SimpleMatch, as: SimpleMatch

    @protocol "https://"
    @base_url "api.riotgames.com"

    @doc """
    """
    def get_tournaments(region) do
        url = @protocol <> "#{region}." <> @base_url <> "/lol/clash/v1/tournaments/"
        api_key = Application.fetch_env!(:player_matches, :api_key)
        headers = ["X-Riot-Token": api_key]

        case HTTPoison.get(url, headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                tournaments = Poison.decode!(body, as: [%Tournament{schedule: [%Schedule{}]}])
                {:ok, tournaments}
            {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
                Logger.error("Status Code: #{status_code} - Error Reason: #{body}")
                {:error, "#{status_code} - #{body}"}
            {:error, error} ->
                Logger.error("Error: #{error}")
                {:error, error}
        end
    end

    @doc """
    """
    def get_last_n_matches(region, account_id, n) do
        url = @protocol <> "#{region}." <> @base_url <> "/lol/match/v4/matchlists/by-account/" <> account_id
        api_key = Application.fetch_env!(:player_matches, :api_key)
        headers = ["X-Riot-Token": api_key]
        options = [params: [beginIndex: 0, endIndex: n]]
        
        case HTTPoison.get(url, headers, options) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                matches = Poison.decode!(body, as: %MatchList{})
                {:ok, matches}
            {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
                Logger.error("Status Code: #{status_code} - Error Reason: #{body}")
                {:error, "#{status_code} - #{body}"}
            {:error, error} ->
                Logger.error("Error: #{error}")
                {:error, error}
        end
    end

    @doc """
    """
    def get_summoner_by_name(region, sommoner_name) do
        url = @protocol <> "#{region}." <> @base_url <> "/lol/summoner/v4/summoners/by-name/" <> sommoner_name
        api_key = Application.fetch_env!(:player_matches, :api_key)
        headers = ["X-Riot-Token": api_key]
        
        case HTTPoison.get(url, headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                summoner = Poison.decode!(body, as: %Summoner{})
                {:ok, summoner}
            {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
                Logger.error("Status Code: #{status_code} - Error Reason: #{body}")
                {:error, "#{status_code} - #{body}"}
            {:error, error} ->
                Logger.error("Error: #{error}")
                {:error, error}
        end
    end

    @doc """
    """
    def get_match_details(region, match_id) do
        url = @protocol <> "#{region}." <> @base_url <> "/lol/match/v4/matches/#{match_id}"
        api_key = Application.fetch_env!(:player_matches, :api_key)
        headers = ["X-Riot-Token": api_key]
        
        case HTTPoison.get(url, headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                match = Poison.decode!(body, as: %SimpleMatch{})
                {:ok, match}
            {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
                Logger.error("Status Code: #{status_code} - Error Reason: #{body}")
                {:error, "#{status_code} - #{body}"}
            {:error, error} ->
                Logger.error("Error: #{error}")
                {:error, error}
        end
    end
end