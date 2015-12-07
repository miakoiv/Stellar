Ransack.configure do |config|
  config.add_predicate 'match', arel_predicate: 'match', type: :string
end
