# This file contains descriptions of all your stripe plans

# Example
# Stripe::Plans::PRIMO #=> 'primo'

# Stripe.plan :primo do |plan|
#   # plan name as it will appear on credit card statements
#   plan.name = 'Acme as a service PRIMO'
#
#   # amount in cents. This is 6.99
#   plan.amount = 699
#
#   # currency to use for the plan (default 'usd')
#   plan.currency = 'usd'
#
#   # interval must be either 'day', 'week', 'month' or 'year'
#   plan.interval = 'month'
#
#   # only bill once every three months (default 1)
#   plan.interval_count = 3
#
#   # number of days before charging customer's card (default 0)
#   plan.trial_period_days = 30
# end

Stripe.plan :platform_commercial do |plan|
  plan.nickname = 'Platform commercial'
  plan.product_id = 'prod_E5SH2kx56pW5EW'
  #plan.product_id = 'prod_E5Rl4jx1zZr339'
  plan.amount = 2000
  plan.currency = 'eur'
  plan.interval = 'month'
  plan.trial_period_days = 30
end

Stripe.plan :storefront_starter do |plan|
  plan.nickname = 'Storefront starter'
  plan.product_id = 'prod_E5SHuFhYf9Z2O3'
  #plan.product_id = 'prod_E5RvKgWSbpBCH3'
  plan.amount = 4900
  plan.currency = 'eur'
  plan.interval = 'month'
  plan.trial_period_days = 30
end

Stripe.plan :storefront_advanced do |plan|
  plan.nickname = 'Storefront advanced'
  plan.product_id = 'prod_E5SHuFhYf9Z2O3'
  #plan.product_id = 'prod_E5RvKgWSbpBCH3'
  plan.amount = 9900
  plan.currency = 'eur'
  plan.interval = 'month'
  plan.trial_period_days = 30
end

Stripe.plan :platform_nonprofit do |plan|
  plan.nickname = 'Platform nonprofit'
  plan.product_id = 'prod_E5SH2kx56pW5EW'
  #plan.product_id = 'prod_E5Rl4jx1zZr339'
  plan.amount = 1500
  plan.currency = 'eur'
  plan.interval = 'month'
  plan.trial_period_days = 30
end

Stripe.plan :storefront_nonprofit do |plan|
  plan.nickname = 'Storefront nonprofit'
  plan.product_id = 'prod_E5SHuFhYf9Z2O3'
  #plan.product_id = 'prod_E5RvKgWSbpBCH3'
  plan.amount = 3500
  plan.currency = 'eur'
  plan.interval = 'month'
  plan.trial_period_days = 30
end

# Once you have your plans defined, you can run
#
#   rake stripe:prepare
#
# This will export any new plans to stripe.com so that you can
# begin using them in your API calls.
