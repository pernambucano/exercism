class Game
  attr_accessor :host_team, :guest_team, :host_result

  def initialize(host_team, guest_team, host_result)
    @host_team = host_team
    @guest_team = guest_team
    @host_result = host_result
  end

  def compute_data
    case host_result.strip
    when 'win'
      host_team.add_win
      guest_team.add_loss
    when 'loss'
      guest_team.add_win
      host_team.add_loss
    else
      host_team.add_draw
      guest_team.add_draw
    end

    host_team.add_game
    guest_team.add_game
  end
end

class Team
  attr_accessor :name, :wins, :losses, :draws, :matches_played

  def initialize(name)
    @name = name
    @wins = 0
    @losses = 0
    @draws = 0
    @matches_played = 0
  end

  def add_game
    self.matches_played += 1
  end

  def add_win
    self.wins += 1
  end

  def add_loss
    self.losses += 1
  end

  def add_draw
    self.draws += 1
  end

  def points
    3 * wins + draws
  end
end

class TeamRepository
  attr_reader :repository

  def initialize
    @repository = {}
  end

  def get_team(name)
    repository[name] = Team.new(name) unless repository.key?(name)

    repository[name]
  end

  def teams
    repository.values
  end
end

class Tournament
  def self.tally(input)
    lines = input.split("\n")
    repository = TeamRepository.new

    lines.each do |line|
      data = line.split(';')
      host_team_name = data[0]
      guest_team_name = data[1]
      host_result = data[2].strip

      host_team = repository.get_team(host_team_name)
      guest_team = repository.get_team(guest_team_name)

      Game.new(host_team, guest_team, host_result).compute_data
    end

    Tally.new(repository.teams).tally
  end
end

class Tally
  attr_reader :teams

  def initialize(teams)
    @teams = teams
  end

  def header
    <<~TALLY
      Team                           | MP |  W |  D |  L |  P
    TALLY
  end

  def order_teams(teams)
    teams.sort_by { |team| [-team.points, team.name] }
  end

  def centered(str)
    str.to_s.rjust(2).center(4)
  end

  def format_row(team)
    name = team.name.ljust(31)
    matches_played = centered(team.matches_played)
    wins = centered(team.wins)
    draws = centered(team.draws)
    losses = centered(team.losses)
    points = team.points.to_s.rjust(3)

    <<~ROW
      #{name}|#{matches_played}|#{wins}|#{draws}|#{losses}|#{points}
    ROW
  end

  def tally
    result = ''
    result << header

    return result if teams.empty?

    ordered_teams = order_teams(teams)

    ordered_teams.each do |team|
      result << format_row(team)
    end

    result
  end
end
