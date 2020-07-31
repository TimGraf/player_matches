defmodule PlayerMatchesTest do
  use ExUnit.Case
  doctest PlayerMatches

  test "region and summoner name" do
    assert PlayerMatches.find_recently_played_with_matches("region", "summoner name") == "summoner name_region" 
  end
end
