# frozen_string_literal: true

require "date"

PUBLIC_HOLIDAYS = {
  2026 => [
    Date.new(2026, 1, 26),  # Republic Day
    Date.new(2026, 8, 15),  # Independence Day
    Date.new(2026, 10, 2)   # Gandhi Jayanti
  ],

  2027 => [
    Date.new(2027, 1, 26),
    Date.new(2027, 8, 15),
    Date.new(2027, 10, 2)
  ]
}.freeze
