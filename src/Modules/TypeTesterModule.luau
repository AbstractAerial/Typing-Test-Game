local UserInputService = game:GetService("UserInputService")

local TypeTester = {}
TypeTester.__index = TypeTester

function TypeTester.new(UI)
    local self = setmetatable({}, TypeTester)

	self.inSession = false
    self.timerAmount = 15
    return self
end


function TypeTester:SetTimer(n : number)
    self.timerAmount = n
end

function  TypeTester:GenerateWords()
end

function TypeTester:BeginCountdown()
    self.timer = task.spawn(function()
        for i = 1, self.timerAmount do
            task.wait(1)
        end
        self:EndSession();
        self.timer = nil;
    end)


end

function TypeTester:StartSession()
    self.inSession = true
end

function TypeTester:EndSession()
    self.inSession = false
end

function TypeTester:Init()
    UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if not self.inSession then
                self:StartSession();
			end
		end
	end)
end

function TypeTester:ShowResults()
    
end

function  TypeTester:Destroy()
    
end

return TypeTester