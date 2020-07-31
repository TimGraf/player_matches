# PlayerMatches

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `player_matches` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:player_matches, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/player_matches](https://hexdocs.pm/player_matches).


## Requirements

Create an application that has one method:

  `find_recently_played_with_matches(region, summoner_name)`

This method should call riot’s summoner api to get summoner information. Use their account id to find 
their latest 5 matches with riot’s matchlist api. For each of those 5 matches, take each player that 
was in the match and monitor that player for new matches every minute for the next 5 minutes. Log any 
new match.