---------------------------------------------------------------
-- Animation queue (see AnimationSystem.lua)
---------------------------------------------------------------
local AnimationQueue = {
	Fraction = function(_, elapsed) return elapsed end;
};

function CPAPI.CreateAnimationQueue()
	return CreateAndInitFromMixin(AnimationQueue)
end

function AnimationQueue:Init()
	self.queue, self.currentIndex = {}, 1;
end

function AnimationQueue:PlayNextAnimation()
	if self.currentIndex > #self.queue then
		return;
	end

	local animGroup = self.queue[self.currentIndex];
	local animsCompleted = 0;

	local function OnAnimationComplete()
		animsCompleted = animsCompleted + 1;
		if animsCompleted == #animGroup then
			self.currentIndex = self.currentIndex + 1;
			self:PlayNextAnimation()
		end
	end

	for _, animData in ipairs(animGroup) do
		local frame, animTable, postFunc, reverse = unpack(animData)
		if animTable.resetFunc then
			animTable.resetFunc(animTable);
		end
		local wrappedPostFunc = function(...)
			if postFunc then
				securecallfunction(postFunc, ...)
			end
			OnAnimationComplete()
		end
		SetUpAnimation(frame, animTable, wrappedPostFunc, reverse)
	end
end

function AnimationQueue:AddAnimation(frame, animTable, postFunc, reverse)
	tinsert(self.queue, {{frame, animTable, postFunc, reverse}})
end

function AnimationQueue:AddAnimations(...)
	local animGroup = {...};
	tinsert(self.queue, animGroup)
end

function AnimationQueue:CreateAnimation(totalTime, updateFunc, getPosFunc, easingFunc) return {
	totalTime  = totalTime;
	updateFunc = updateFunc;
	getPosFunc = easingFunc and function(self, elapsedFraction)
		return easingFunc(getPosFunc(self, elapsedFraction));
	end or getPosFunc or self.Fraction;
	resetFunc  = function(self)
		self.updateFunc = updateFunc;
	end;
} end

function AnimationQueue:CreateCallback(totalTime, fireAfter, callback, ...)
	fireAfter = ClampedPercentageBetween(fireAfter, 0, totalTime);
	local animation = {
		args       = {...};
		callback   = callback;
		original   = callback;
		totalTime  = totalTime;
	};
	animation.getPosFunc = function(_, elapsedFraction)
		return elapsedFraction >= fireAfter;
	end;
	animation.updateFunc = function(self, shouldFire)
		if shouldFire then
			animation.callback(self, unpack(animation.args));
			animation.callback = nop;
		end
	end;
	animation.resetFunc = function(self)
		self.callback = self.original;
	end;
	return animation;
end

function AnimationQueue:Play()
	self.currentIndex = 1;
	self:PlayNextAnimation()
end

function AnimationQueue:Cancel()
	local animatingFrames = {};
	for _, animGroup in ipairs(self.queue) do
		for _, animData in ipairs(animGroup) do
			animatingFrames[animData[1]] = true;
		end
	end
	for frame in pairs(animatingFrames) do
		CancelAnimations(frame)
	end
	self.currentIndex = #self.queue + 1;
end