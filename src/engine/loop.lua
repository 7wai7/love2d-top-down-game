local Loop = {}
Loop.__index = Loop

function Loop.new(options)
    local self = setmetatable({}, Loop)

    options = options or {}

    self.fixedDt = options.fixedDt or (1 / 60)
    self.maxDelta = options.maxDelta or 0.25
    self.maxFixedSteps = options.maxFixedSteps or 5

    self.accumulator = 0
    self.frame = 0
    self.fixedFrame = 0
    self.time = 0
    self.lastDt = 0
    self.lastFixedSteps = 0

    return self
end

function Loop:reset()
    self.accumulator = 0
    self.frame = 0
    self.fixedFrame = 0
    self.time = 0
    self.lastDt = 0
    self.lastFixedSteps = 0
end

function Loop:update(dt, onFixedUpdate, onFrameUpdate)
    dt = math.min(dt or 0, self.maxDelta)

    self.frame = self.frame + 1
    self.time = self.time + dt
    self.lastDt = dt
    self.lastFixedSteps = 0
    self.accumulator = self.accumulator + dt

    while self.accumulator >= self.fixedDt and self.lastFixedSteps < self.maxFixedSteps do
        self.fixedFrame = self.fixedFrame + 1
        self.lastFixedSteps = self.lastFixedSteps + 1
        self.accumulator = self.accumulator - self.fixedDt

        if onFixedUpdate then
            onFixedUpdate(self.fixedDt)
        end
    end

    if self.lastFixedSteps == self.maxFixedSteps then
        self.accumulator = math.min(self.accumulator, self.fixedDt)
    end

    if onFrameUpdate then
        onFrameUpdate(dt, self.accumulator / self.fixedDt)
    end
end

function Loop:getStats()
    return {
        frame = self.frame,
        fixedFrame = self.fixedFrame,
        time = self.time,
        lastDt = self.lastDt,
        fixedSteps = self.lastFixedSteps,
        alpha = self.accumulator / self.fixedDt,
    }
end

return Loop
