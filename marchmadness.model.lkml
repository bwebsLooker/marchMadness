# From Geoff
# Who has a team played,
# their record,
# the scores
# what's their momentum?
# Historical, coaching+previous year performance
#
# He looks at ESPN and CBS because the y are more in depth and have season recap paragraph
# Individual PLayers? Maybe?


connection: "zz_bq_test"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

#explore: regular_season_compact_results {}

explore: head_to_head {
  extends: [game_by_game_comparison]
  always_join: [opponent_facts]
  join: opponent_facts {
    from: team_game_season_h2h
    sql_on: ${team_game_season_facts.primary_key} = ${opponent_facts.primary_key} ;;
    relationship: one_to_one
    type: inner
    fields: []
  }

}
explore: source_key_table {}

explore: allRecords {
  join: teams {
    from: teams
    view_label: "Teams"
    type: left_outer
    sql_on: ${allRecords.team} = ${teams.team_id}  ;;
    relationship: many_to_one
  }
  join: opponent {
    from: teams
    view_label: "Opponents"
    type: left_outer
    sql_on: ${allRecords.opponent} = ${opponent.team_id}  ;;
    relationship: many_to_one
  }
  join: seasons {
    view_label: "Allrecords"
    type: left_outer
    relationship: many_to_one
    sql_on: ${allRecords.season} = ${seasons.season} ;;
    fields: [seasons.game_date_date]
  }
  join: team_game_season_facts {
    type: left_outer
    relationship: one_to_one
    sql_on: ${allRecords.primary_key} = ${team_game_season_facts.primary_key} ;;
  }
}
explore: game_by_game_comparison {
  view_name: game_by_game_comparison
  from: game_nums
  always_filter: {
    filters: {
      field: game_by_game_comparison.team_1
      value: "Villanova, North Carolina"
    }
    filters: {
      field: game_by_game_comparison.season
      value: "2016"
    }
  }
  join: team_game_season_facts {
    sql_on: ${game_by_game_comparison.game_num} = ${team_game_season_facts.game_num} ;;
    relationship: one_to_one
    type: inner
  }
  join: allRecords {
    sql_on: ${team_game_season_facts.primary_key} = ${allRecords.primary_key} ;;
    relationship: one_to_one
    type: left_outer
  }
  join: strength_of_schedule {
    sql_on: ${team_game_season_facts.team_id} = ${strength_of_schedule.team_id} AND ${allRecords.season} = ${strength_of_schedule.season};;
    relationship: many_to_one
    type: left_outer
  }
  join: source_key_table {
    sql_on: ${team_game_season_facts.team_id} = ${source_key_table.primary_key} ;;
    type: left_outer
    relationship: many_to_one
  }
}


#   join: team_2_facts2 {
#     from: team_game_season_facts2
#     sql_on: ${game_nums.game_num} = ${team_2_facts2.game_num}  ;;
#     relationship: one_to_one
#     type: left_outer
#   }
#   sql_always_where: ${team_1_facts.primary_key} is not null OR ${team_2_facts2.primary_key} is not null ;;


# explore: seasons {
#   join: allRecords {
#     type: left_outer
#     sql_on: ${seasons.season}=${allRecords.season} ;;
#     relationship: one_to_many
#   }
# }

#explore: teams {}
#
# #explore: tourney_compact_results {}
#
# explore: tourneyRecords {
#   join: teams {
#     from: teams
#     view_label: "Teams"
#     type: left_outer
#     sql_on: ${tourneyRecords.team} = ${teams.team_id}  ;;
#     relationship: many_to_one
#   }
#   join: opponent {
#     from: teams
#     view_label: "Opponents"
#     type: left_outer
#     sql_on: ${tourneyRecords.opponent} = ${opponent.team_id}  ;;
#     relationship: many_to_one
#   }
# }

#explore: tourney_seeds {}

#explore: tourney_slots {}
