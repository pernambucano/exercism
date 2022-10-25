class Game
  attr_accessor :host_team, :guest_team, :host_result

  def initialize(host_team, guest_team, host_result)
    @host_team = host_team
    @guest_team = guest_team
    @host_result = host_result.strip
  end

  def guest_result
    case @host_result
    when 'win'
      'loss'
    when 'loss'
      'win'
    else
      'draw'
    end
  end

  def compute_data
    if @host_result == 'win'
      host_team.add_win
      guest_team.add_loss
    elsif @host_result == 'loss'
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
    @games = []
    @wins = 0
    @losses = 0
    @draws = 0
    @matches_played = 0
  end

  def add_game
    @matches_played += 1
  end

  def add_win
    @wins += 1
  end

  def add_loss
    @losses += 1
  end

  def add_draw
    @draws += 1
  end

  def points
    3 * wins + draws
  end
end

class TeamRepository
  def initialize
    @repository = {}
  end

  def get_team(name)
    @repository[name] = Team.new(name) unless @repository.key?(name)

    @repository[name]
  end

  def teams
    @repository.values
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
  def initialize(teams)
    @teams = teams
  end

  def header
    <<~TALLY
      Team                           | MP |  W |  D |  L |  P
    TALLY
  end

  def order_teams(teams)
    teams.sort do |team_a, team_b|
      (team_b.points <=> team_a.points).nonzero? || team_a.name <=> team_b.name
    end
  end

  def create_row(team)
    name = team.name.ljust(31)
    matches_played = team.matches_played.to_s.rjust(2).center(4)
    wins = team.wins.to_s.rjust(2).center(4)
    draws = team.draws.to_s.rjust(2).center(4)
    losses = team.losses.to_s.rjust(2).center(4)
    points = team.points.to_s.rjust(3)

    <<~ROW
      #{name}|#{matches_played}|#{wins}|#{draws}|#{losses}|#{points}
    ROW
  end

  def tally
    result = ''
    result << header

    return result if @teams.empty?

    ordered_teams = order_teams(@teams)

    ordered_teams.each do |team|
      result << create_row(team)
    end

    result
  end
end
