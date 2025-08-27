--[[
    Spring
	─────────────────────────────────────────────
	Author: Matthew (Creaco) · License: License.luau
	Version: 1.0.0
	Last Updated: 2025-07-16

    Springs are a powerful tool for creating smooth and responsive animations.
    
    Restrictions:
        1- Type T must support the following operations:
            i-   Addition (+)       | > add(T, T)      -> T
            ii-  Substraction (-)   | > sub(T, T)      -> T
            iii- Multiplication (×) | > mul(T, number) -> T
            iv-  Division (÷)       | > div(T, number) -> T
        (Note: This is achievable using metamethods __add, __sub, __mul, and __div
            if needed for special types)

    Recommendations:
        1- The developer is responsible for handling render loops:
            i-   You can keep a spring connected at all times, but computations may be heavy.
            ii-  I recommend making a SpringHandler module to keep track of connections.
            iii- Disconnect unused springs to avoid unnecessary performance cost.

    References:
        1- https://en.wikipedia.org/wiki/Damping
        2- https://www.lua.org/gems/sample.pdf
        3- https://create.roblox.com/docs/luau/native-code-gen
        4- https://devforum.roblox.com/t/new-type-solver-beta/3155804
--]]

--!strict
--!native

local Spring = {}
Spring.__index = Spring

-- Library ------------
local pi   = math.pi
local exp  = math.exp
local sin  = math.sin
local cos  = math.cos
local sqrt = math.sqrt

-- Types ------------
type ArithGeneric<T> = T -- Temporary until ROBLOX adds Generic Constraints

type SpringData<T> = {
    damping: 	number,
    frequency: 	number,
	position: 	ArithGeneric<T>,
	goal: 		ArithGeneric<T>,
	velocity: 	ArithGeneric<T>
}

export type Spring<T> = setmetatable<SpringData<T>, typeof(Spring)>

-- Constructor ------------
function Spring.new<T>(
    damping : number	, frequency: number,
	position: ArithGeneric<T>, goal: ArithGeneric<T>?,
	velocity: ArithGeneric<T>?
): Spring<T>

    local self: SpringData<T> = {
        damping 	= damping,
        frequency 	= frequency,
        position 	= position,
        goal 		= goal or position,
        velocity 	= velocity or (position * 0),
    }

    return setmetatable(self, Spring) :: any
end

-- Public Methods ------------
function Spring.Impulse<T>(self: Spring<T>, impulse: ArithGeneric<T>)
    self.velocity += impulse
end

function Spring.Step<T>(self: Spring<T>, dt: number): ArithGeneric<T>
    -- Locals
    local d, f = self.damping, self.frequency
    local p, g = self.position, self.goal
    local v = self.velocity

    -- Variables
    local dT = p - g
    local o = 2 * pi * f

    if d < 1 then
        -- Underdamped spring (ζ < 1)
        -- Reference: e^(−ζωt) × (c₁ × cos(ω_d × t) + c₂ × sin(ω_d × t))
        local od = o * sqrt(1-d^2)

        local sinTerm = sin(od * dt)
        local cosTerm = cos(od * dt)
        local expTerm = exp(-d * o * dt)

        local c1 = dT
        local c2 = (v + d * o * dT) / od

        p = g + expTerm * (c1 * cosTerm + c2 * sinTerm)
        v = expTerm * (
            (-c1 * o * d + c2 * od) * cosTerm +
            (-c2 * o * d - c1 * od) * sinTerm
        )
    elseif d == 1 then
        -- Critically damped (ζ = 1)
        -- Reference: e^(−ω t) × (c₁ + c₂ × t)
        local c1 = dT
        local c2 = (v + o * dT)

        local expTerm = exp(-o * dt)

        p = g + expTerm * (c1 + c2 * dt)
        v = expTerm * (v - c2 * o * dt)
    else
        -- Overdamped (ζ > 1)
        -- Reference: c₁ × e^(r₁ t) + c₂ × e^(r₂ t)
        local sqrtTerm = sqrt(d^2 - 1)

        local r1 = -o * (d - sqrtTerm)
        local r2 = -o * (d + sqrtTerm)

        local c2 = (v - r1 * dT) / (r2 - r1)
        local c1 = (dT - c2)

        local expTerm1 = exp(r1 * dt)
        local expTerm2 = exp(r2 * dt)

        p = g + c1 * expTerm1 + c2 * expTerm2
        v = c1 * r1 * expTerm1 + c2 * r2 * expTerm2
    end

    self.position = p
    self.velocity = v
    
    return p
end

return Spring