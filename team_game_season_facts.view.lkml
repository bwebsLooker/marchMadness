view: team_game_season_facts {
  derived_table: {
    sql:
      SELECT
        CONCAT( STRING(season) , "_" ,  game_type , "_",
        STRING(daynum)  , "_" , STRING(team) ) as primary_key,
        teams.team_id as team_id,
        allRecords.daynum  AS daynum,
        teams.team_name  AS team_name,
        allRecords.game_type  AS game_type,
        allRecords.season  AS season,
        allRecords.opponent  AS opponent,
        allRecords.result  AS result,
        SUM(CASE WHEN (allRecords.result = 'W') THEN 1 ELSE NULL END) OVER (PARTITION BY teams.team_id, allRecords.season ORDER BY allRecords.daynum ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sum_wins,
        SUM(CASE WHEN (allRecords.result = 'L') THEN 1 ELSE NULL END)  OVER (PARTITION BY teams.team_id, allRecords.season ORDER BY allRecords.daynum ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sum_losses,
        ROW_NUMBER() OVER (PARTITION BY teams.team_id, allRecords.season ORDER BY allRecords.daynum) as game_num,
        SUM(allRecords.score) OVER (PARTITION BY teams.team_id, allRecords.season ORDER BY allRecords.daynum) as running_score,
        SUM(allRecords.opponent_score) OVER (PARTITION BY teams.team_id, allRecords.season ORDER BY allRecords.daynum) as running_opponent_score
      FROM ${allRecords.SQL_TABLE_NAME} AS allRecords
      LEFT JOIN marchMadness2017.teams  AS teams ON allRecords.team = teams.team_id
      WHERE {% condition game_by_game_comparison.season %} STRING(allRecords.season) {% endcondition %}
       AND ( {% condition game_by_game_comparison.team_1 %} teams.team_name {% endcondition %}  )
      ORDER BY teams.team_name, allRecords.season, allRecords.daynum
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    type: string
    sql: ${TABLE}.primary_key ;;
    primary_key: yes
  }

  dimension: team_id {
    type: number
    sql: ${TABLE}.team_id ;;
  }

  dimension: team_name {
    type: string
    sql: ${TABLE}.team_name ;;
  }

  dimension: game_type {
    type: string
    sql: ${TABLE}.game_type ;;
  }

  dimension: season {
    type: number
    sql: ${TABLE}.season ;;
  }

  dimension: opponent {
    type: number
    sql: ${TABLE}.opponent ;;
  }

  dimension: daynum {
    type: number
    sql: ${TABLE}.daynum ;;
  }

  dimension: result {
    type: string
    sql: ${TABLE}.result ;;
  }

  dimension: sum_wins {
    type: number
    sql: COALESCE ( ${TABLE}.sum_wins , 0 ) ;;
  }

  dimension: sum_losses {
    type: number
    sql: COALESCE ( ${TABLE}.sum_losses , 0 ) ;;
  }

  dimension: record {
    type: string
    sql: CONCAT( STRING(${sum_wins}),'-',STRING(${sum_losses}) ) ;;
  }

  dimension: win_percentage {
    type: number
    sql: 1.0 * ${sum_wins} / ${game_num} ;;
    value_format_name: percent_2
  }

  measure: win_percentage_2 {
    type: average
    sql: ${win_percentage} ;;
    value_format_name: percent_2
  }

  dimension: game_num {
    type: number
    sql: ${TABLE}.game_num ;;
  }

  dimension: running_score {
    type: number
    sql: ${TABLE}.running_score ;;
  }

  dimension: running_opponent_score {
    type: number
    sql: ${TABLE}.running_opponent_score ;;
  }


  set: detail {
    fields: [
      team_id,
      team_name,
      game_type,
      season,
      opponent,
      daynum,
      result,
      sum_wins,
      sum_losses,
      game_num,
      running_score,
      running_opponent_score
    ]
  }
}
