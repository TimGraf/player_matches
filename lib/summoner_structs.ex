defmodule SummonerStructs do
    @moduledoc """
    """

    import ExConstructor

    defmodule Schedule do
        defstruct id: nil, registrationTime: nil, startTime: nil, cancelled: false
        use ExConstructor
    end
    
    defmodule Tournament do
        defstruct id: nil, themeId: nil, nameKey: "", nameKeySecondary: false, schedule: []
        use ExConstructor
    end

    defimpl Poison.Decoder, for: Tournament do
        def decode(payload, _options) do
            %{payload | schedule: decode_schedules(payload)}
        end    

        defp decode_schedules(%Tournament{schedule: schedules}) do
            Enum.map(schedules, &(populate_struct(%Schedule{}, &1)))
        end
    end

    defmodule Summoner do
        defstruct id: "", accountId: "", puuid: "", name: "", profileIconId: nil, revisionDate: nil, summonerLevel: nil
        use ExConstructor
    end

    defmodule MatchList do
        defstruct startIndex: nil, totalGames: nil, endIndex: nil, matches: []
        use ExConstructor
    end

    defmodule Match do
        defstruct gameId: nil, role: "", season: nil, platformId: "", champion: nil, queue: nil, lane: "", timestamp: nil
        use ExConstructor
    end

    defimpl Poison.Decoder, for: MatchList do
        def decode(payload, _options) do
            %{payload | matches: decode_matches(payload)}
        end    

        defp decode_matches(%MatchList{matches: matches}) do
            Enum.map(matches, &(populate_struct(%Match{}, &1)))
        end
    end

    defmodule SimplePlayer do
        defstruct accountId: nil, summonerName: ""
        use ExConstructor
    end

    defmodule SimpleMatch do
        defstruct participantIdentities: []
        use ExConstructor
    end

    defimpl Poison.Decoder, for: SimpleMatch do
        def decode(payload, _options) do
            %{payload | participantIdentities: decode_participants(payload)}
        end    

        defp decode_participants(%SimpleMatch{participantIdentities: participantIdentities}) do
            Enum.map(participantIdentities, fn participant ->
                populate_struct(%SimplePlayer{}, participant["player"])
            end)
        end
    end
end