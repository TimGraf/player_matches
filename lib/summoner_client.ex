defmodule SummonerClient do
    @moduledoc """
    """
    use HTTPoison.Base
    require Logger
    alias SummonerStructs.Tournament, as: Tournament
    alias SummonerStructs.Schedule, as: Schedule
    alias SummonerStructs.Summoner, as: Summoner
    alias SummonerStructs.MatchList, as: MatchList
    alias SummonerStructs.Match, as: Match
    alias SummonerStructs.SimpleMatch, as: SimpleMatch
    alias SummonerStructs.SimpleParticipant, as: SimpleParticipant
    alias SummonerStructs.SimplePlayer, as: SimplePlayer

    @protocol "https://"
    @base_url "api.riotgames.com"

    @doc """
    """
    def get_tournaments(region) do
        url = @protocol <> "#{region}." <> @base_url <> "/lol/clash/v1/tournaments/"
        api_key = Application.fetch_env!(:player_matches, :api_key)
        headers = ["X-Riot-Token": api_key]

        Logger.debug("URL: #{url}")
        Logger.debug("API Key: #{api_key}")
        Logger.debug("Headers: #{headers |> Enum.map_join("&", fn {k, v} -> "#{k}: #{v}" end)}")

        case HTTPoison.get(url, headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                Logger.debug("Response: #{body}")
                tournaments = process_tournament_response(body)
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
    def process_tournament_response(response) do
        tournament_structs = Poison.decode!(response, as: [%Tournament{schedule: [%Schedule{}]}])

        tournament_structs |> inspect() |> Logger.debug()

        tournament_structs
    end

    @doc """
    """
    def get_last_n_matches(region, account_id, n) do
        url = @protocol <> "#{region}." <> @base_url <> "/lol/match/v4/matchlists/by-account/" <> account_id
        api_key = Application.fetch_env!(:player_matches, :api_key)
        headers = ["X-Riot-Token": api_key]
        options = [params: [beginIndex: 0, endIndex: n]]

        Logger.debug("Region: #{region}")
        Logger.debug("Account ID: #{account_id}")
        Logger.debug("Matches: #{n}")
        
        case HTTPoison.get(url, headers, options) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                Logger.debug("Response: #{body}")
                matches = process_summoner_matches(body)
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
    def process_summoner_matches(response) do
        matches_struct = Poison.decode!(response, as: %MatchList{})

        matches_struct |> inspect() |> Logger.debug()

        matches_struct
    end

    @doc """
    """
    def get_summoner_by_name(region, sommoner_name) do
        url = @protocol <> "#{region}." <> @base_url <> "/lol/summoner/v4/summoners/by-name/" <> sommoner_name
        api_key = Application.fetch_env!(:player_matches, :api_key)
        headers = ["X-Riot-Token": api_key]

        Logger.debug("API Key: #{api_key}")
        Logger.debug("Region: #{region}")
        Logger.debug("Summoner Name: #{sommoner_name}")
        
        case HTTPoison.get(url, headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                Logger.debug("Response: #{body}")
                summoner = process_summoner_response(body)
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
    def process_summoner_response(response) do
        summoner_struct = Poison.decode!(response, as: %Summoner{})

        summoner_struct |> inspect() |> Logger.debug()

        summoner_struct
    end

    @doc """
    """
    def get_match_details(region, match_id) do
        url = @protocol <> "#{region}." <> @base_url <> "/lol/match/v4/matches/#{match_id}"
        api_key = Application.fetch_env!(:player_matches, :api_key)
        headers = ["X-Riot-Token": api_key]

        Logger.debug("API Key: #{api_key}")
        Logger.debug("Region: #{region}")
        Logger.debug("Match ID: #{match_id}")
        
        case HTTPoison.get(url, headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                Logger.debug("Response: #{body}")
                match = process_match_response(body)
                {:ok, match}
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
    def process_match_response(response) do
        match_struct = Poison.decode!(response, as: %SimpleMatch{})

        match_struct |> inspect() |> Logger.debug()

        match_struct
    end
end