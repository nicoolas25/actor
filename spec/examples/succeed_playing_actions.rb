# frozen_string_literal: true

class SucceedPlayingActions < Actor
  play ->(ctx) { ctx.count = 1 },
       SucceedEarly,
       ->(ctx) { ctx.count = 2 }
end

# Actually, I think an early return can be misleading.
# It is a way a way to introduce a conditional in the plan.
